//
//  NewChatViewModel.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 10/06/24.
//

import Foundation
import SwiftUI

extension NewChatView {
    var filteredContacts: [User] {
        if searchText.isEmpty {
            contacts.users.sorted { $0.name < $1.name }
        } else {
            contacts.users
                .sorted { $0.name < $1.name }
                .filter { $0.name.localizedCaseInsensitiveContains(searchText)}
        }
    }
    
    //load one contact image
    func loadContactImage(_ userName: String) -> Image? {
        guard let index = vm.contactsPicture.firstIndex(where: { $0.userName == userName }) else { return nil }
        guard let imageData = vm.contactsPicture[index].imageData else { return nil }
        if let UIImage = UIImage(data: imageData) {
            return Image(uiImage: UIImage)
        }
        return nil
    }
}
