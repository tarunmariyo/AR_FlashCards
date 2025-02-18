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
        arView.session.run(config)
        
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
    class Coordinator: NSObject {
        var parent: ARViewContainer
        var cardEntity: ModelEntity?
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            Task { @MainActor in
                guard let arView = recognizer.view as? ARView else { return }
                
                let location = recognizer.location(in: arView)
                let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
                
                if let result = results.first,
                   let entity = cardEntity,
                   entity.position.distance(to: result.worldTransform.translation) < 0.1 {
                    parent.onTapText()
                }
            }
        }
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

// Helper extension to calculate distance between points
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