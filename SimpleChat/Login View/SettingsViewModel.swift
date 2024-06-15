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
    
    var aboutText: String {
        """
Simple Chat is a messaging application that let you contact with other user, created by Gustio and only for practice coding purpose.

This app is made with 80% of SwiftUI and 20% of UIKit framework. this app will never be put into beta stage let alone releasing it to the market, this app is also doesn't use any external package dependencies so it's fully customizable, anyone may clone this code for free and make your version based on this code.

Thank you for trying!
"""
    }
    
}

struct HelpView1: View {
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Image(.helpPicture1)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .clipShape(.rect(cornerRadius: 20))
                    .padding()
                
                Divider()
                
                Text("To delete one contact, you need to long-press the contact and it will bring the context menu to delete selected contact.")
                    .padding()
            }
        }
        .padding()
        .navigationTitle("Deleting Contact")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}

struct HelpView2: View {
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Image(.helpPicture2)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .clipShape(.rect(cornerRadius: 20))
                    .padding()
                
                Divider()
                
                Text("For message that failed to send, you can long-press to bring the context menu,you can either resend the message, copying the text to cliboard, or delete the message.")
                    .padding()
            }
        }
        .padding()
        .navigationTitle("Deleting Contact")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}

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
