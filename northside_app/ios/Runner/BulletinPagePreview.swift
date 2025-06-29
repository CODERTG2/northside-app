import SwiftUI
import Flutter

// Full Northside App Preview for Xcode
struct NorthsideAppPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> FlutterViewController {
        let flutterEngine = FlutterEngine(name: "NorthsideAppPreviewEngine")
        
        // Use main_preview.dart which runs the full app
        let dartEntrypoint = DartProject.default().dartEntrypointForBundle(Bundle.main)
        let entrypointArgs = DartEntrypoint(dartEntrypoint: dartEntrypoint)
        entrypointArgs.dartEntrypoint = "main_preview"
        
        flutterEngine.run(withEntrypoint: entrypointArgs)
        
        let controller = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        
        // Optional: Setup communication channel for preview-specific features
        let channel = FlutterMethodChannel(
            name: "preview_channel",
            binaryMessenger: flutterEngine.binaryMessenger
        )
        
        channel.invokeMethod("enablePreviewMode", arguments: [
            "mockData": true,
            "debugMode": true
        ])
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: FlutterViewController, context: Context) {
        // Updates can be handled here if needed
    }
}

// Preview provider for Xcode previews with full app and multiple devices
struct NorthsideAppPreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NorthsideAppPreview()
                .previewDevice("iPhone 15 Pro")
                .previewDisplayName("Northside App - iPhone 15 Pro")
            
            NorthsideAppPreview()
                .previewDevice("iPhone 15 Pro Max")
                .previewDisplayName("Northside App - iPhone 15 Pro Max")
            
            NorthsideAppPreview()
                .previewDevice("iPhone SE (3rd generation)")
                .previewDisplayName("Northside App - iPhone SE")
                
            NorthsideAppPreview()
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .previewDisplayName("Northside App - iPad Pro")
        }
    }
}
