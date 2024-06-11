//
//  ChatsViewModel.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 10/06/24.
//

import PhotosUI
import SwiftUI

extension ChatsView {
    // ViewModel for creating state properties
    @MainActor class ChatsVM: ObservableObject {
        @Published var selection: String?
        @Published var user: User?
        @Published var ipadUser: User?
        @Published var pickerItem: PhotosPickerItem?
        @Published var previewPhoto: PreviewPhoto?
        
        func loadImage() {
            Task {
                guard let imageData = try await pickerItem?.loadTransferable(type: Data.self) else { return }
                guard let inputImage = UIImage(data: imageData) else { return }
                
                //store image to binary data
                guard let thumbnail = inputImage.preparingThumbnail(of: CGSize(width: 512, height: 512)) else { return }
                if let compressedThumbnail = thumbnail.jpegData(compressionQuality: 0.5) {
                    if let UIImage = UIImage(data: compressedThumbnail) {
                        previewPhoto = PreviewPhoto(photo: Image(uiImage: UIImage), data: compressedThumbnail)
                    }
                }
            }
        }
    } // end of view model
    
    var sortedMessages: [Messages] {
        return vm.allMessages.sorted { $0.lastDate > $1.lastDate }
    }
    
    func convertDate(_ text: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        return dateFormatter.date(from: text) ?? .now
    }
    
    func newMessages(_ name: String, displayName: String) -> Messages {
        let messages = Messages(receiver: name, displayName: displayName)// add displayname
        vm.allMessages.append(messages)
        if let index = vm.allMessages.firstIndex(where: { $0.receiver == name }) {
            return vm.allMessages[index]
        }
        
        return Messages(receiver: "")
    }
    
    func loadContactImage(_ userName: String) -> Image? {
        guard let index = vm.contactsPicture.firstIndex(where: { $0.userName == userName }) else { return nil }
        guard let imageData = vm.contactsPicture[index].imageData else { return nil }
        if let UIImage = UIImage(data: imageData) {
            return Image(uiImage: UIImage)
        }
        return nil
    }
    
}
