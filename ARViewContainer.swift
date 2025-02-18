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
        
        // Add tap gesture
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:))))
        
        // Create and add the flashcard
        Task { @MainActor in
            let cardEntity = await FlashcardEntity.create(card: card)
            
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
    
    class Coordinator: NSObject {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        @objc @MainActor func handleTap(_ recognizer: UITapGestureRecognizer) {
            Task { @MainActor in
                parent.onTapText()
            }
        }
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update logic here if needed
    }
} 