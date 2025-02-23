import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    let card: FlashCard
    let onTapText: () -> Void
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Create AR configuration
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        
        // Enable auto-focus and high-resolution capture
        guard let device = MTLCreateSystemDefaultDevice() else { return arView }
        config.videoFormat = ARWorldTrackingConfiguration.supportedVideoFormats.first { format in
            Int(format.imageResolution.width) <= device.maxBufferLength &&
            format.framesPerSecond <= 60
        } ?? ARWorldTrackingConfiguration.supportedVideoFormats[0]
        
        // Enable camera calibration
        config.isAutoFocusEnabled = true
        config.worldAlignment = .gravity
        
        // Configure frame semantics - only enable essential features
        if #available(iOS 13.0, *) {
            // Use basic frame semantics to ensure compatibility
            config.frameSemantics = []
        }
        
        // Run session with options
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        // Set up AR session delegate
        arView.session.delegate = context.coordinator as? ARSessionDelegate
        
        // Create and add the flashcard
        Task { @MainActor in
            let cardEntity = await FlashcardEntity.create(card: card)
            
            // Add tap gesture to the card entity
            cardEntity.generateCollisionShapes(recursive: true)
            
            // Add tap gesture
            let tapGesture = UITapGestureRecognizer(target: context.coordinator, 
                                                   action: #selector(Coordinator.handleTap(_:)))
            arView.addGestureRecognizer(tapGesture)
            
            // Store the card entity in the coordinator
            context.coordinator.cardEntity = cardEntity
            context.coordinator.arView = arView
            
            // Position the card 0.5 meters in front of the camera
            let anchor = AnchorEntity(world: [0, 0, -0.5])
            anchor.addChild(cardEntity)
            
            arView.scene.addAnchor(anchor)
        }
        
        return arView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    @MainActor
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        var cardEntity: ModelEntity?
        weak var arView: ARView?
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
            super.init()
        }
        
        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            Task { @MainActor in
                guard let arView = arView else { return }
                
                let tapLocation = recognizer.location(in: arView)
                
                // Perform hit test with the tap location
                if let result = arView.raycast(from: tapLocation, 
                                             allowing: .estimatedPlane, 
                                             alignment: .any).first,
                   let entity = cardEntity {
                    
                    // Check if tap is near the card
                    let cardPosition = entity.position
                    let tapPosition = result.worldTransform.translation
                    
                    // Calculate distance between tap and card
                    let distance = cardPosition.distance(to: tapPosition)
                    
                    // If tap is close to the card, trigger pronunciation
                    if distance < 0.2 { // Adjust this threshold as needed
                        parent.onTapText()
                    }
                }
            }
        }
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

// Helper extensions
extension SIMD3 where Scalar == Float {
    func distance(to other: SIMD3<Float>) -> Float {
        let diff = self - other
        return sqrt(diff.x * diff.x + diff.y * diff.y + diff.z * diff.z)
    }
}

extension simd_float4x4 {
    var translation: SIMD3<Float> {
        SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
    }
}