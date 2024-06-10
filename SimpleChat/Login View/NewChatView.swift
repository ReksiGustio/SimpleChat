//
//  NewChatView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 09/06/24.
//

import SwiftUI

struct NewChatView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ContentView.VM
    @State var searchText = ""
    let contacts: Users
    var selectedContact: (User) -> Void
    
    var body: some View {
        NavigationStack {
            List(filteredContacts) { user in
                Button {
                    selectedContact(user)
                    dismiss()
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
                }
                .foregroundStyle(.primary)
            } // end of list
            .navigationTitle("Select contact to start chat")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search contact name")
        } // end of navstack
    } // end of body
    
    init(vm: ContentView.VM, contacts: Users, selectedContact: @escaping (User) -> Void) {
        self.vm = vm
        self.contacts = contacts
        self.selectedContact = selectedContact
    }
} // end of newchatview

#Preview {
    NewChatView(vm: ContentView.VM(), contacts: Users()) { _ in }
}
