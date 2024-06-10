//
//  AddContactView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 08/06/24.
//

import SwiftUI

struct AddContactView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ContentView.VM
    @ObservedObject var contactsVM: ContactsView.ContactsVM
    
    var body: some View {
        Form {
            Section {
                HStack {
                    TextField("Insert Username", text: $contactsVM.searchName)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button("Submit") {
                        Task {
                            await searchUser(contactsVM.searchName)
                        }
                    }
                } // end of hstack
            } // end of section
            
            Section {
                if let user = contactsVM.user {
                    HStack {
                        //image placeholder
                        ZStack {
                            Circle()
                                .fill(.secondary)
                                .frame(width: 64, height: 64)
                                .padding(5)
                            
                            if let downloadedImage = contactsVM.downloadedImage {
                                downloadedImage
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(.circle)
                                    .frame(width: 64, height: 64)
                                    .padding(5)
                            }
                        } // end of zstack
                        
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.title.bold())
                                .lineLimit(1)
                            Text(user.userName)
                                .lineLimit(1)
                        } // end of vstack
                    } // end of hstack
                    
                    Button(sameUser ? "You can't add yourself" : "Add to contact") {
                        if !sameUser { addToContact(contactsVM.user!.userName) }
                    }
                    .foregroundStyle(sameUser ? .red : .blue)
                    
                }
            } // end of section
            
        } // end of form
        .navigationTitle("Add New Contact")
        .navigationBarTitleDisplayMode(.inline)
        
        .onAppear { contactsVM.user = nil }
        .alert(contactsVM.message, isPresented: $contactsVM.showMessage) { }
    }
    
}

#Preview {
    AddContactView(vm: ContentView.VM(), contactsVM: ContactsView.ContactsVM())
}
