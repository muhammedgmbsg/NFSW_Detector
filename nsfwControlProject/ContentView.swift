import SwiftUI
import CoreML
import Vision

struct ContentView: View {
    @State private var isImagePickerPresented = false
    @State private var inputImage: UIImage?
    @State private var classificationLabel = "Select an image to classify"

    var body: some View {
        VStack {
            Text(classificationLabel)
                .padding()

            if let inputImage = inputImage {
                Image(uiImage: inputImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }

            Button("Select Image") {
                isImagePickerPresented = true
            }
            .padding()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $inputImage, completion: classifyImage)
        }
    }

    func classifyImage(image: UIImage?) {
        guard let uiImage = image else { return }
        guard let ciImage = CIImage(image: uiImage) else { return }

        let model = try! VNCoreMLModel(for: OpenNSFW().model)

        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else { return }
            if let firstResult = results.first {
                DispatchQueue.main.async {
                    self.classificationLabel = "Classification: \(firstResult.identifier) Confidence: \(firstResult.confidence)"
                    if firstResult.confidence > 0.8 {
                        print("NSFW content detected")
                    }
                }
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global(qos: .userInteractive).async {
            try? handler.perform([request])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

