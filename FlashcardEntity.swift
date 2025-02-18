import RealityKit
import UIKit

@MainActor
class FlashcardEntity {
    // Define cheerful colors for different categories
    static let cardColors: [UIColor] = [
        .init(red: 1.0, green: 0.85, blue: 0.35, alpha: 1.0),  // Sunny Yellow
        .init(red: 0.45, green: 0.83, blue: 1.0, alpha: 1.0),  // Sky Blue
        .init(red: 1.0, green: 0.6, blue: 0.8, alpha: 1.0),    // Pink
        .init(red: 0.6, green: 0.9, blue: 0.6, alpha: 1.0),    // Mint Green
        .init(red: 1.0, green: 0.75, blue: 0.5, alpha: 1.0),   // Peach
    ]
    
    static func create(width: Float = 0.3, height: Float = 0.2, card: FlashCard) async -> ModelEntity {
        // Create the card mesh with more rounded corners for a friendlier look
        let mesh = MeshResource.generatePlane(width: width, height: height, cornerRadius: 0.02)
        
        // Pick a random cheerful color for the card
        let cardColor = cardColors.randomElement() ?? .white
        
        // Create materials with a slight shine for a more playful look
        let frontMaterial = SimpleMaterial(
            color: cardColor,
            roughness: 0.3,
            isMetallic: true
        )
        
        // Create the card entity with a slight 3D effect
        let cardEntity = ModelEntity(mesh: mesh, materials: [frontMaterial])
        
        // Add a decorative border
        let borderMesh = MeshResource.generatePlane(width: width * 0.95, height: height * 0.95, cornerRadius: 0.018)
        let borderMaterial = SimpleMaterial(
            color: .white,
            roughness: 0.3,
            isMetallic: true
        )
        let borderEntity = ModelEntity(mesh: borderMesh, materials: [borderMaterial])
        borderEntity.position = [0, 0, 0.0005]
        cardEntity.addChild(borderEntity)
        
        // Add text to the card with a more playful font
        let textMesh = MeshResource.generateText(
            card.word,
            extrusionDepth: 0.002,
            font: .boldSystemFont(ofSize: 0.045),
            containerFrame: CGRect(x: -Double(width * 0.4), y: -Double(height * 0.15), 
                                 width: Double(width * 0.8), height: Double(height * 0.3)),
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        
        // Create text with a fun color that contrasts with the card
        let textMaterial = SimpleMaterial(
            color: .init(red: 0.1, green: 0.1, blue: 0.3, alpha: 1),
            roughness: 0.2,
            isMetallic: true
        )
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        textEntity.position = [0, height * 0.3, 0.003]
        
        // Add tap gesture to text
        textEntity.generateCollisionShapes(recursive: true)
        
        // Add image plane below the text
        if let image = UIImage(named: card.imageName) {
            let imageSize: Float = min(width, height) * 0.6
            let imageMesh = MeshResource.generatePlane(width: imageSize, height: imageSize)
            
            // Create CGImage from UIImage
            if let cgImage = image.cgImage {
                let imageTexture = try? TextureResource.generate(from: cgImage, options: .init(semantic: .color))
                
                var imageMaterial = SimpleMaterial()
                if let imageTexture = imageTexture {
                    imageMaterial = SimpleMaterial(
                        color: UIColor.white,
                        roughness: 0.5,
                        isMetallic: false
                    )
                    imageMaterial.color.texture = .init(imageTexture)
                } else {
                    imageMaterial = SimpleMaterial(
                        color: .white,
                        roughness: 0.5,
                        isMetallic: false
                    )
                }
                
                // Add white background for image
                let backgroundMaterial = SimpleMaterial(color: .white, roughness: 0.5, isMetallic: false)
                let backgroundEntity = ModelEntity(mesh: imageMesh, materials: [backgroundMaterial])
                backgroundEntity.position = [0, 0, -0.001]
                
                let imageEntity = ModelEntity(mesh: imageMesh, materials: [imageMaterial])
                imageEntity.position = [0, -height * 0.1, 0.002]
                
                let imageContainer = ModelEntity()
                imageContainer.addChild(backgroundEntity)
                imageContainer.addChild(imageEntity)
                cardEntity.addChild(imageContainer)
            }
        }
        
        // Add a subtle shadow effect
        let shadowMesh = MeshResource.generatePlane(width: width, height: height, cornerRadius: 0.02)
        let shadowMaterial = SimpleMaterial(
            color: .black.withAlphaComponent(0.2),
            roughness: 1,
            isMetallic: false
        )
        let shadowEntity = ModelEntity(mesh: shadowMesh, materials: [shadowMaterial])
        shadowEntity.position = [0.005, -0.005, -0.001]
        cardEntity.addChild(shadowEntity)
        
        // Add text as child of card
        cardEntity.addChild(textEntity)
        
        // Add physics collision
        cardEntity.collision = CollisionComponent(shapes: [.generateBox(width: width, height: height, depth: 0.001)])
        
        return cardEntity
    }
} 