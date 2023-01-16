//
//  ImagePicker.swift
//  Paws Go 5
//
//  Created by Pui Ling Hon on 2022-12-10.
//

import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    //@Binding var imageUrl: URL?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            picker.dismiss(animated: true)
            
            // create a local path, to save the image again locally
            // this path is for the use of uploading the image to cloud storage
            /*
            let imageURL = info[UIImagePickerControllerReferenceURL] as NSURL
            let imageName = imageURL.path!.lastPathComponent
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as String
            let localPath = documentDirectory.stringByAppendingPathComponent(imageName)
*/
            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    /*
                    let imgName = "\(UUID().uuidString).jpeg"
                    let documentDirectory = NSTemporaryDirectory()
                    let localPath = documentDirectory.appending(imgName)
                    if image != nil {
                        let data = image!.jpegData(compressionQuality: 1.0)! as NSData
                        data.write(toFile: localPath, atomically: true)
                        self.parent.imageUrl = URL.init(fileURLWithPath: localPath)
                    }
                    */
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}
