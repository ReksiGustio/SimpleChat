//
//  SettingsViewModel.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 09/06/24.
//

import PhotosUI
import SwiftUI

extension StringProtocol {
    var data: Data { Data(utf8) }
    var base64Encoded: Data { data.base64EncodedData() }
    var base64Decoded: Data? { Data(base64Encoded: string) }
}

extension LosslessStringConvertible {
    var string: String { .init(self) }
}

extension Sequence where Element == UInt8 {
    var data: Data { .init(self) }
    var base64Decoded: Data? { Data(base64Encoded: data) }
    var string: String? { String(bytes: self, encoding: .utf8) }
}

extension SettingsView {
    // ViewModel for creating state properties
    @MainActor class SettingsVM: ObservableObject {
        @Published var status = ""
        @Published var showLogoutAlert = false
        
        //used for image picker
        @Published var pickerItem: PhotosPickerItem?
        @Published var selectedImage: Image?
        @Published var compressedImage = Data()
        @Published var compressedString = ""
        
        //used for loading an image
        func loadImage() {
            Task {
                guard let imageData = try await pickerItem?.loadTransferable(type: Data.self) else { return }
                guard let inputImage = UIImage(data: imageData) else { return }
                
                //load image to view
                
                //store image to binary data
                if let thumbnail = inputImage.preparingThumbnail(of: CGSize(width: 256, height: 256)) {
                    compressedImage = thumbnail.jpegData(compressionQuality: 1.0) ?? Data()
                    compressedString = compressedImage.base64EncodedString()
                    
                    let encodedData = compressedString.base64Encoded
                    guard let stringData = encodedData.base64Decoded?.string else { return }

                    if let compressedUIImage = UIImage(data: Data(base64Encoded: stringData) ?? Data()) {
                        selectedImage = Image(uiImage: compressedUIImage)
                    }
                }
            }
        }
        
    } // end of view model
}
