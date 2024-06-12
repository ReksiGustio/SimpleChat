//
//  ContactsView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 08/06/24.
//

import SwiftUI

struct ContactsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ContentView.VM
    @StateObject var contactsVM = ContactsVM()
    @StateObject var chatsVM = ChatsView.ChatsVM()
    
    var body: some View {
        NavigationSplitView {
            if vm.contacts.isEmpty {
                NavigationLink {
                    AddContactView(vm: vm, contactsVM: contactsVM)
                } label: {
                    VStack {
                        Image(systemName: "person.crop.rectangle.stack")
                            .resizable()
                            .foregroundStyle(.primary)
                            .frame(width: 72, height: 72)
                        Text("There are no contact saved, tap to add new contact.")
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                            .font(.headline)
                    } // end of vstack
                } // end of navlink
                .padding(20)
                .navigationTitle("Contacts")
            } else {
                List(filteredContacts) { user in
                        NavigationLink {
                            ZStack(alignment: .bottom) {
                                Color.clear
                                
                                if let image = loadContactImage(user.userName) {
                                    NavigationLink {
                                        ImageView(image: image)
                                    } label: {
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } // end of navlink
                                }
                                
                                Text(user.name)
                                    .font(.headline.bold())
                                    .foregroundStyle(.white)
                                    .padding(10)
                                    .background(.black.opacity(0.3))
                                    .clipShape(.capsule)
                                    .padding(.vertical, 8)
                                
                            } // end of zstack
                            .frame(maxHeight: 400)
                            List {
                                NavigationLink("Chat \(user.name)") {
                                    if let index = vm.allMessages.firstIndex(where: { $0.receiver == user.userName }) {
                                        MessageView(vm: vm, chatsVM: chatsVM, messages: vm.allMessages[index])
                                    } else {
                                        let messages = newMessages(user.userName, displayName: user.name)
                                        MessageView(vm: vm, chatsVM: chatsVM, messages: messages)
                                    }
                                } // end of navlink
                                Button("Delete contact", role: .destructive) { removeContact(user)
                                    dismiss()
                                }
                            } // end of list
                            .scrollDisabled(true)
                            .navigationTitle(user.name)
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        HStack(spacing: 20) {
                            //image placeholder
                            ZStack {
                                Circle()
                                    .fill(.secondary)
                                    .frame(width: 44, height: 44)
                                    .padding(5)
                                
                                if let loadedImage = loadContactImage(user.userName) {
                                    loadedImage
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(.circle)
                                        .frame(width: 44, height: 44)
                                        .padding(5)
                                }
                            } // end of zstack
                            
                            VStack(alignment: .leading) {
                                Text(user.name)
                                    .font(.headline)
                                Text(user.status ?? "Available")
                                    .foregroundStyle(.secondary)
                            } // end of vstack
                        } // end of hstack
                    } // end of navlink
                } // end of list
                .navigationTitle("Contacts")
                .searchable(text: $contactsVM.searchText, prompt: "Search contact name")
                .toolbar {
                    NavigationLink {
                        AddContactView(vm: vm, contactsVM: contactsVM)
                    } label: {
                        Label("Add contact", systemImage: "plus")
                    }
                }
            } // end if
        } detail: {
            Text("Swipe from the left edge to open menu and press \"+\" button to add new contact.")
        } // end of navsplitview
    } // end of body
} // end of contactsview

#Preview {
    ContactsView(vm: ContentView.VM())
}
