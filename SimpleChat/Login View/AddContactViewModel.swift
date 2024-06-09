//
//  AddContactViewModel.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 08/06/24.
//

import Foundation

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
                    }
                    else if let data = try? JSONDecoder().decode(Response.self, from: tempResponse) {
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
