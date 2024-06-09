//
//  DashboardView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 08/06/24.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var vm: ContentView.VM
    @State private var title = ""
    
    var body: some View {
        TabView {
            ChatsView(vm: vm)
                .tabItem {
                    Label("Chats", systemImage: "ellipsis.message.fill")
                }
            
            ContactsView(vm: vm)
                .tabItem {
                    Label("Contacts", systemImage: "person.crop.square.filled.and.at.rectangle.fill")
                }
            
            SettingsView(vm: vm)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        } // end of tab view
        .onReceive(vm.timer) { _ in
            for user in vm.contacts {
                Task {
                    await vm.fetchMessageByUsername(receiver: user.userName, displayName: user.name)
                }
            }
        }
    } // end of body
} // end of dashboard view

#Preview {
    DashboardView(vm: ContentView.VM())
}
