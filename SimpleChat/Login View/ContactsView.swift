//
//  ContactsView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 08/06/24.
//

import SwiftUI

struct ContactsView: View {
    @ObservedObject var vm: ContentView.VM
    @StateObject var contactsVM = ContactsVM()
    
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
                    .contextMenu {
                        Button("Delete contact", role: .destructive) { removeContact(user)
                        }
                        
                    }
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
