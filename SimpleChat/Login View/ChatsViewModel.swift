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
        return vm.allMessages.sorted { $0.lastDate < $1.lastDate }
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
    
    func getLastMessage(_ messages: Messages) -> String {
        guard let text = messages.items.last?.text else { return "" }
        guard let image = messages.items.last?.image else { return text }
        
        if image.hasPrefix("http") { return "Image" }
        else { return "Location" }
    }
    
    func countUnreadMessages(_ messages: Messages) -> Int {
        var count = 0
        for item in messages.items {
            if item.read.hasPrefix("un") && !item.userRelated.hasPrefix(vm.userName) {
                count += 1
            }
        }
        return count
    }
    
}
