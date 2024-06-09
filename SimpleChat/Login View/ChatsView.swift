//
//  ChatsView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 08/06/24.
//

import SwiftUI

struct ChatsView: View {
    @ObservedObject var vm: ContentView.VM
    @State private var selection: String?
    @State private var user: User?
    @State private var ipadUser: User?
    
    var body: some View {
        NavigationSplitView {
            List(sortedMessages, selection: $selection) { messages in
                NavigationLink {
                    MessageView(vm: vm, messages: messages)
                } label: {
                    HStack {
                        Circle()
                            .fill(.secondary)
                            .frame(width: 44, height: 44)
                        
                        VStack(alignment: .leading) {
                            Text(messages.displayName)
                                .font(.headline)
                            Text(messages.items.last?.text ?? "")
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        } // end of vstack
                        
                        Spacer()
                        
                        Text("\(convertDate(messages.items.last?.date ?? "").formatted(date: .omitted, time: .shortened))")
                            .foregroundStyle(.secondary)
                    } // end of hstack
                } // end of navlink
                .tag(messages.id)
            } // end of list
            .navigationTitle("Chats")
            .toolbar {
                Button {
                    if !vm.contacts.isEmpty {
                        vm.chatContacts = Users()
                        vm.chatContacts?.users = vm.contacts
                    }
                } label: {
                    Label("New Chat", systemImage: "plus")
                }
            } // add new chat
            .sheet(item: $vm.chatContacts) { contacts in
                NewChatView(contacts: contacts) { selectedUser in
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        user = selectedUser
                        selection = ""
                    } else {
                        ipadUser = selectedUser
                        selection = ""
                    }
                }
            } // go to message view when contact selected
            .sheet(item: $user) { user in
                if let index = vm.allMessages.firstIndex(where: { $0.receiver == user.userName }) {
                    MessageView(vm: vm, messages: vm.allMessages[index])
                } else {
                    let messages = newMessages(user.userName)
                    MessageView(vm: vm, messages: messages)
                }
            }
            .onAppear {
                for user in vm.contacts {
                    Task {
                        await vm.fetchMessageByUsername(receiver: user.userName, displayName: user.name)
                    }
                }
            }
            .onReceive(vm.timer) { _ in
                for user in vm.contacts {
                    Task {
                        await vm.fetchMessageByUsername(receiver: user.userName, displayName: user.name)
                    }
                }
            }
        } detail: {
            if ipadUser != nil {
                if let index = vm.allMessages.firstIndex(where: { $0.receiver == ipadUser?.userName }) {
                    MessageView(vm: vm, messages: vm.allMessages[index])
                } else {
                    let messages = newMessages(ipadUser!.userName)
                    MessageView(vm: vm, messages: messages)
                }
            } else {
                Text("Swipe from the left edge to open menu and press \"+\" button to start chat.")
            }
        }
    }
    
    var sortedMessages: [Messages] {
        return vm.allMessages.sorted { $0.lastDate > $1.lastDate }
    }
    
    func convertDate(_ text: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        return dateFormatter.date(from: text) ?? .now
    }
    
    func newMessages(_ name: String) -> Messages {
        let messages = Messages(receiver: name)
        vm.allMessages.append(messages)
        if let index = vm.allMessages.firstIndex(where: { $0.receiver == name }) {
            return vm.allMessages[index]
        }
        
        return Messages(receiver: "")
    }
    
}

#Preview {
    ChatsView(vm: ContentView.VM())
}
