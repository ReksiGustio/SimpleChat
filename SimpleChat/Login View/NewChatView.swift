//
//  NewChatView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 09/06/24.
//

import SwiftUI

struct NewChatView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
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
                        Circle()
                            .fill(.secondary)
                            .frame(width: 44, height: 44)
                        
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
    
    init(contacts: Users, selectedContact: @escaping (User) -> Void) {
        self.contacts = contacts
        self.selectedContact = selectedContact
    }
    
    var filteredContacts: [User] {
        if searchText.isEmpty {
            contacts.users.sorted { $0.name < $1.name }
        } else {
            contacts.users
                .sorted { $0.name < $1.name }
                .filter { $0.name.localizedCaseInsensitiveContains(searchText)}
        }
    }
    
}

#Preview {
    NewChatView(contacts: Users()) { _ in }
}
