import SwiftUI
import AVFoundation
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.capturedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - 自定义相机视图容器
struct CameraContainerView: View {
    @State private var capturedImage: UIImage?
    @State private var showingCamera = false
    @State private var showingTextInput = false
    @State private var photoText = ""
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .padding()
                
                TextField("添加描述...", text: $photoText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack(spacing: 20) {
                    Button("重新拍摄") {
                        capturedImage = nil
                        showingCamera = true
                    }
                    .foregroundColor(.blue)
                    
                    Button("保存记录") {
                        savePhotoRecord()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(photoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            } else {
                VStack(spacing: 30) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                    
                    Text("准备拍照")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Button("开始拍照") {
                        showingCamera = true
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.title2)
                }
            }
        }
        .navigationTitle("快速记录")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCamera) {
            CameraView(capturedImage: $capturedImage)
        }
        .onAppear {
            // 首次进入直接打开相机
            if capturedImage == nil {
                showingCamera = true
            }
        }
    }
    
    private func savePhotoRecord() {
        guard let image = capturedImage else { return }
        
        let imageData = image.jpegData(compressionQuality: 0.8)
        let photoRecord = PersistenceController.shared.createPhotoRecord(
            image: imageData,
            textDescription: photoText
        )
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("保存失败: \(error)")
        }
    }
} 