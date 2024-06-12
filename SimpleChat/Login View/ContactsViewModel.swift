//
//  ContactsViewModel.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 08/06/24.
//

import Foundation
import SwiftUI

extension ContactsView {
    // ViewModel for creating state properties
    @MainActor class ContactsVM: ObservableObject {
        
        //used for sort and filter
        @Published var searchText = ""
        
        //used for search new user
        @Published var searchName = ""
        @Published var message = ""
        @Published var showMessage = false
        
        //used for storing contact info
        @Published var user: User? = nil
        @Published var downloadedData: Data?
        @Published var downloadedImage: Image?
    } // end of view model
    
    var filteredContacts: [User] {
        if contactsVM.searchText.isEmpty {
            vm.contacts.sorted { $0.name < $1.name }
        } else {
            vm.contacts
                .sorted { $0.name < $1.name }
                .filter { $0.name.localizedCaseInsensitiveContains(contactsVM.searchText)}
        }
    }
    
    //remove one contact
    func removeContact(_ user: User) {
        if let index = vm.contacts.firstIndex(where: { $0.userName == user.userName}) {
            vm.contacts.remove(at: index)
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
    
    func newMessages(_ name: String, displayName: String) -> Messages {
        let messages = Messages(receiver: name, displayName: displayName)// add displayname
        vm.allMessages.append(messages)
        if let index = vm.allMessages.firstIndex(where: { $0.receiver == name }) {
            return vm.allMessages[index]
        }
        
        return Messages(receiver: "")
    }
    
}
