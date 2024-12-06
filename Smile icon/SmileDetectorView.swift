import SwiftUI
import AVFoundation

class CameraManager: NSObject, ObservableObject {
    @Published var isSmilingDetected = false
        @Published var smileDuration: Double = 0
        @Published var hasReachedGoal = false
        private var lastSmileTime: Date?
        private var captureSession: AVCaptureSession?
        private var previewLayer: AVCaptureVideoPreviewLayer?
        private var smileDetector: CIDetector?
    
    override init() {
        super.init()
        setupSmileDetector()
        setupCamera()
    }
    
    private func setupSmileDetector() {
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        smileDetector = CIDetector(ofType: CIDetectorTypeFace,
                                 context: nil,
                                 options: options)
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Failed to access front camera")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            
            captureSession.addInput(input)
            captureSession.addOutput(output)
            
            DispatchQueue.global(qos: .background).async {
                captureSession.startRunning()
            }
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
        }
    }
    
    func createPreviewLayer(frame: CGRect) -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession!)
        layer.frame = frame
        layer.videoGravity = .resizeAspectFill
        return layer
    }
    
    func resetSmileTracking() {
            smileDuration = 0
            hasReachedGoal = false
            lastSmileTime = nil
        }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let smileDetector = smileDetector else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        let options: [String: Any] = [
            CIDetectorSmile: true,
            CIDetectorEyeBlink: false,
            CIDetectorImageOrientation: 6
        ]
        
        let faces = smileDetector.features(in: ciImage, options: options)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let isSmiling = faces.contains { face in
                guard let faceFeature = face as? CIFaceFeature else { return false }
                return faceFeature.hasSmile
            }
            
            self.isSmilingDetected = isSmiling
            
            if isSmiling {
                let currentTime = Date()
                if self.lastSmileTime == nil {
                    self.lastSmileTime = currentTime
                }
                
                if let lastSmile = self.lastSmileTime {
                    self.smileDuration = currentTime.timeIntervalSince(lastSmile)
                    
                    if self.smileDuration >= 5 && !self.hasReachedGoal {
                        self.hasReachedGoal = true
                    }
                }
            } else {
                self.lastSmileTime = nil
                self.smileDuration = 0
            }
        }
    }
}

struct RewardDialog: View {
    @Binding var showRedeemView: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Congratulations! You receive a gift! 🎁")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.black)
            
            Button(action: {
                showRedeemView = true
            }) {
                Text("Redeem your gift")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(minWidth: 200)
                    .background(Color(red: 0, green: 0.47, blue: 0.39))
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding(.horizontal)
    }
}

struct CameraPreview: UIViewRepresentable {
    let cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = cameraManager.createPreviewLayer(frame: view.frame)
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct SmileDetectorView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var showRedeemView = false
    
    var body: some View {
        ZStack {
            CameraPreview(cameraManager: cameraManager)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                if cameraManager.isSmilingDetected {
                    Text(String(format: "Smiling: %.1f/5.0s", min(cameraManager.smileDuration, 5.0)))
                        .font(.title)
                        .padding()
                        .background(Color(red: 0, green: 0.47, blue: 0.39))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 50)
                } else {
                    Text("No smile detected")
                        .font(.title)
                        .padding()
                        .background(Color.gray.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 50)
                }
            }
            
            if cameraManager.hasReachedGoal {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                
                RewardDialog(showRedeemView: $showRedeemView)
            }
        }
        .fullScreenCover(isPresented: $showRedeemView, onDismiss: {
                    // Reset the hasReachedGoal when RedeemView is dismissed
                    cameraManager.resetSmileTracking()
                }) {
                    RedeemView()
                }
    }
}


#Preview {
    SmileDetectorView()
}
