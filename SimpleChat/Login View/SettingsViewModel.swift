//
//  SettingsViewModel.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 09/06/24.
//

import PhotosUI
import SwiftUI

extension SettingsView {
    // ViewModel for creating state properties
    @MainActor class SettingsVM: ObservableObject {
        @Published var status = ""
        @Published var showLogoutAlert = false
        
        //used for image picker
        @Published var pickerItem: PhotosPickerItem?
        @Published var selectedImage: Image?
        @Published var compressedImage = ""
        
        //used for loading an image
        func loadImage() {
            Task {
                guard let imageData = try await pickerItem?.loadTransferable(type: Data.self) else { return }
                guard let inputImage = UIImage(data: imageData) else { return }
                
                //load image to view
                
                //store image to binary data
                if let thumbnail = inputImage.preparingThumbnail(of: CGSize(width: 128, height: 128)) {
                    compressedImage = thumbnail.jpegData(compressionQuality: 1.0)?.base64EncodedString() ?? ""
                    
                    let compressedImageData = Data(base64Encoded: compressedImage, options: .ignoreUnknownCharacters)
                    let compressedUIImage = UIImage(data: compressedImageData ?? Data())
                    
                    selectedImage = Image(uiImage: compressedUIImage ?? inputImage)
                }
            }
        }
        
    } // end of view model
}
