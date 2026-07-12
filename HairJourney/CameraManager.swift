import SwiftUI
import UIKit
import AVFoundation

struct CameraManager: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    var angle: String // "Frontal", "Vertex", "Lateral"
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        // Ensure camera is available (Simulator fallback)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            picker.cameraDevice = .front // Default to front for selfie, though user can flip
            
            // Add custom overlay
            picker.showsCameraControls = true
            let overlay = createOverlayView(for: angle)
            picker.cameraOverlayView = overlay
        } else {
            picker.sourceType = .photoLibrary // Simulator fallback
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraManager
        
        init(_ parent: CameraManager) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
    
    // MARK: - Overlay Generator
    private func createOverlayView(for angle: String) -> UIView {
        let screenBounds = UIScreen.main.bounds
        let overlayView = UIView(frame: screenBounds)
        overlayView.backgroundColor = .clear
        overlayView.isUserInteractionEnabled = false 
        
        let path = UIBezierPath()
        let cx = screenBounds.width / 2
        let cy = screenBounds.height / 2 - 50 
        
        switch angle.lowercased() {
        case "vertex": 
            path.addArc(withCenter: CGPoint(x: cx, y: cy), radius: 100, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        case "lateral": 
            path.move(to: CGPoint(x: cx, y: cy - 120))
            path.addCurve(to: CGPoint(x: cx, y: cy + 150),
                          controlPoint1: CGPoint(x: cx + 120, y: cy - 80),
                          controlPoint2: CGPoint(x: cx + 100, y: cy + 100))
        default: 
            let rect = CGRect(x: cx - 110, y: cy - 150, width: 220, height: 300)
            path.append(UIBezierPath(ovalIn: rect))
        }
        
        // AR Style Glowing Guide
        let glowLayer = CAShapeLayer()
        glowLayer.path = path.cgPath
        glowLayer.strokeColor = UIColor.cyan.cgColor
        glowLayer.lineWidth = 6
        glowLayer.fillColor = UIColor.clear.cgColor
        glowLayer.opacity = 0.3
        overlayView.layer.addSublayer(glowLayer)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 2.5
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineDashPattern = [12, 6] 
        shapeLayer.opacity = 0.9
        
        // Pulsing Animation to simulate active AR tracking
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.fromValue = 0.3
        pulseAnimation.toValue = 1.0
        pulseAnimation.duration = 1.2
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        shapeLayer.add(pulseAnimation, forKey: "pulse")
        
        overlayView.layer.addSublayer(shapeLayer)
        
        // Frosted Glass Pill for the instruction label
        let pillWidth: CGFloat = 260
        let pillHeight: CGFloat = 44
        let pillView = UIView(frame: CGRect(x: cx - (pillWidth/2), y: cy - 220, width: pillWidth, height: pillHeight))
        pillView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        pillView.layer.cornerRadius = pillHeight / 2
        pillView.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: .systemThinMaterialLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = pillView.bounds
        pillView.addSubview(blurView)

        let label = UILabel(frame: pillView.bounds)
        label.text = "Align to the \(angle) guide"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        pillView.addSubview(label)
        overlayView.addSubview(pillView)
        
        return overlayView
    }
}
