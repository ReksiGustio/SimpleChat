//
//  DashboardView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 08/06/24.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var vm: ContentView.VM
    @State private var showError = false
    @State private var title = ""
    
    var body: some View {
        VStack {
            TabView {
                ChatsView(vm: vm)
                    .tabItem {
                        Label("Chats", systemImage: "ellipsis.message.fill")
                    }
                    .onDisappear {
                        if let encode = try? JSONEncoder().encode(vm.allMessages) {
                            UserDefaults.standard.set(encode, forKey: vm.messageKey)
                        }
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
            
            if vm.connectionStatus != .isConnected {
                Button {
                    vm.timer = Timer.publish(every: 5, tolerance: 2, on: .main, in: .common).autoconnect()
                    vm.connectionStatus = .isConnecting
                    if !vm.contacts.isEmpty {
                        Task { await getMessage() }
                    }
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(.blue)
                            .frame(height: 30)
                        
                        HStack {
                            if isConnecting {
                                ProgressView().tint(.white)
                                    .padding(.vertical, 2)
                            }
                            
                            Text(isConnecting ? "Connecting" : "Error: \(vm.connectionText) Tap to retry")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .padding(.horizontal, 8)
                                .minimumScaleFactor(0.5)
                                .dynamicTypeSize(...DynamicTypeSize.large)
                                .contextMenu {
                                    Button("Show Error") { showError = true }
                                }
                            
                        } // end of hstack
                    } // end of zstack
                }
                .buttonStyle(PlainButtonStyle())
            } // end if
            
        } // end of vstack
        .onReceive(vm.timer) { _ in  Task { await getMessage() } }
        .sheet(isPresented: $showError) {
            Text(vm.connectionText)
        }
    } // end of body
    
    var isConnecting: Bool {
        if vm.connectionStatus == .isConnecting { true }
        else { false }
    }
    
    func getMessage() async {
        for user in vm.contacts {
            Task {
                await vm.fetchMessageByUsername(receiver: user.userName, displayName: user.name)
            }
        }
    }
    
} // end of dashboard view

#Preview {
    DashboardView(vm: ContentView.VM())
}
