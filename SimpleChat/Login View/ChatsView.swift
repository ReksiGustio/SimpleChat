//
//  ChatsView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 08/06/24.
//

import SwiftUI

struct ChatsView: View {
    @ObservedObject var vm: ContentView.VM
    @StateObject private var chatsVM = ChatsVM()
    
    var body: some View {
        NavigationSplitView {
            List(sortedMessages, selection: $chatsVM.selection) { messages in
                NavigationLink {
                    MessageView(vm: vm, chatsVM: chatsVM, messages: messages)
                } label: {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(.secondary)
                                .frame(width: 44, height: 44)
                                .padding(5)
                            
                            if let loadedImage = loadContactImage(messages.receiver) {
                                loadedImage
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(.circle)
                                    .frame(width: 44, height: 44)
                                    .padding(5)
                            }
                        } // end of zstack
                        
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
                NewChatView(vm: vm, contacts: contacts) { selectedUser in
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        chatsVM.user = selectedUser
                        chatsVM.selection = ""
                    } else {
                        chatsVM.ipadUser = selectedUser
                        chatsVM.selection = ""
                    }
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
            } // end of list
        } detail: {
            if chatsVM.ipadUser != nil {
                if let index = vm.allMessages.firstIndex(where: { $0.receiver == chatsVM.ipadUser?.userName }) {
                    MessageView(vm: vm, chatsVM: chatsVM, messages: vm.allMessages[index])
                } else {
                    let messages = newMessages(chatsVM.ipadUser!.userName, displayName: chatsVM.ipadUser!.name)
                    MessageView(vm: vm, chatsVM: chatsVM, messages: messages)
                }
            } else if chatsVM.user != nil{
                if let index = vm.allMessages.firstIndex(where: { $0.receiver == chatsVM.user?.userName }) {
                    MessageView(vm: vm, chatsVM: chatsVM, messages: vm.allMessages[index])
                } else {
                    let messages = newMessages(chatsVM.user!.userName, displayName: chatsVM.user!.name)
                    MessageView(vm: vm, chatsVM: chatsVM, messages: messages)
                }
            } else {
                Text("Swipe from the left edge to open menu and press \"+\" button to start chat.")
            }
        } // end of navsplitview
            
    } // end of body
    
} // end of chatsview

#Preview {
    ChatsView(vm: ContentView.VM())
}
