import SwiftUI
import Flutter

/// Helper for creating Xcode previews of Flutter content
/// This allows you to preview Flutter widgets in Xcode's Canvas
@available(iOS 13.0, *)
struct FlutterPreviewHelper: View {
    let flutterEngine: FlutterEngine
    let flutterViewController: FlutterViewController
    
    init() {
        // Create a Flutter engine for preview
        self.flutterEngine = FlutterEngine(name: "preview_engine")
        self.flutterEngine.run()
        
        // Create a Flutter view controller
        self.flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
    }
    
    var body: some View {
        FlutterViewControllerRepresentable(flutterViewController: flutterViewController)
            .edgesIgnoringSafeArea(.all)
    }
}

/// UIViewControllerRepresentable wrapper for Flutter
@available(iOS 13.0, *)
struct FlutterViewControllerRepresentable: UIViewControllerRepresentable {
    let flutterViewController: FlutterViewController
    
    func makeUIViewController(context: Context) -> FlutterViewController {
        return flutterViewController
    }
    
    func updateUIViewController(_ uiViewController: FlutterViewController, context: Context) {
        // Update the Flutter view controller if needed
    }
}

/// Preview providers for different screen sizes
@available(iOS 13.0, *)
struct FlutterPreviewHelper_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // iPhone 14 Pro Preview
            FlutterPreviewHelper()
                .previewDevice("iPhone 14 Pro")
                .previewDisplayName("iPhone 14 Pro")
            
            // iPhone SE Preview
            FlutterPreviewHelper()
                .previewDevice("iPhone SE (3rd generation)")
                .previewDisplayName("iPhone SE")
            
            // iPad Preview
            FlutterPreviewHelper()
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .previewDisplayName("iPad Pro")
        }
    }
}

/// Simple preview helper for testing
@available(iOS 13.0, *)
struct SimplePreview: View {
    var body: some View {
        VStack {
            Text("Northside App")
                .font(.largeTitle)
                .padding()
            
            Text("Flutter Preview Ready")
                .font(.headline)
                .foregroundColor(.blue)
            
            Text("Run './run_flutter.sh' in terminal to start the Flutter app")
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

@available(iOS 13.0, *)
struct SimplePreview_Previews: PreviewProvider {
    static var previews: some View {
        SimplePreview()
            .previewDevice("iPhone 14 Pro")
            .previewDisplayName("Simple Preview")
    }
}
