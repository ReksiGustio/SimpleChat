//
//  AddContactViewModel.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 08/06/24.
//

import Foundation
import SwiftUI

extension AddContactView {
    var sameUser: Bool {
        contactsVM.user?.userName == vm.user.userName
    }
    
    //search user
    func searchUser(_ userName: String) async {
        contactsVM.message = ""
        if !contactsVM.searchName.isEmpty {
            Task {
                if let tempResponse = await search(userName: userName, token: vm.token) {
                    print(String(data: tempResponse, encoding: .utf8)!)
                    if let data = try? JSONDecoder().decode(ResponseData<User>.self, from: tempResponse) {
                        contactsVM.user = data.data
                        contactsVM.searchName = ""
                        contactsVM.downloadedImage = nil
                        Task {
                            guard let stringURL = data.data.picture else { return }
                            guard let downloadedImageData = await vm.downloadImage(url: stringURL) else { return }
                            if let UIImage = UIImage(data: downloadedImageData) {
                                contactsVM.downloadedImage = Image(uiImage: UIImage)
                            }
                        }
                    } else if let data = try? JSONDecoder().decode(Response.self, from: tempResponse) {
                        contactsVM.message = data.message
                        contactsVM.showMessage = true
                    }
                }
            }
        }
    } // end of search func
    
    //check contact
    func addToContact(_ userName: String) {
        for contact in vm.contacts {
            if contact.userName == userName {
                contactsVM.message = "User is already in your contacts."
                contactsVM.showMessage = true
                return
            }
        }
        
        vm.contacts.append(contactsVM.user!)
        dismiss()
    } // end of check contact func
}
