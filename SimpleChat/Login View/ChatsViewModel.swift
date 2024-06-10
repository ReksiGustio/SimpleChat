//
//  ChatsViewModel.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 10/06/24.
//

import Foundation
import SwiftUI

extension ChatsView {
    // ViewModel for creating state properties
    @MainActor class ChatsVM: ObservableObject {
        @Published var selection: String?
        @Published var user: User?
        @Published var ipadUser: User?
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
