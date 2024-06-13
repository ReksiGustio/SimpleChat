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
    @StateObject var chatsVM = ChatsView.ChatsVM()
    @State private var searchText = ""
    @State private var searchName = ""
    @State private var user: User? = nil
    @State private var downloadedData: Data?
    @State private var downloadedImage: Image?
    
    var body: some View {
        NavigationSplitView {
            if vm.contacts.isEmpty {
                NavigationLink {
                    AddContactView(vm: vm, searchName: $searchName, user: $user, downloadedData: $downloadedData, downloadedImage: $downloadedImage)
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
                                        ImageView(image: image, data: Data())
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
                .searchable(text: $searchText, prompt: "Search contact name")
                .toolbar {
                    NavigationLink {
                        AddContactView(vm: vm, searchName: $searchName, user: $user, downloadedData: $downloadedData, downloadedImage: $downloadedImage)
                    } label: {
                        Label("Add contact", systemImage: "plus")
                    }
                }
            } // end if
        } detail: {
            Text("Swipe from the left edge to open menu and press \"+\" button to add new contact.")
        } // end of navsplitview
    } // end of body
    
    var filteredContacts: [User] {
        if searchText.isEmpty {
            vm.contacts.sorted { $0.name < $1.name }
        } else {
            vm.contacts
                .sorted { $0.name < $1.name }
                .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
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
    
} // end of contactsview

#Preview {
    ContactsView(vm: ContentView.VM())
}
