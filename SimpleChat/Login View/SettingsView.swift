//
//  SettingsView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 08/06/24.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var vm: ContentView.VM
    @StateObject var settingsVM = SettingsView.SettingsVM()
    
    var body: some View {
        NavigationSplitView {
            List {
                
                // profile
                NavigationLink {
                    ProfileView(vm: vm, settingsVM: settingsVM)
                } label: {
                    HStack {
                        //image placeholder
                        ZStack {
                            Circle()
                                .fill(.secondary)
                                .frame(width: 64, height: 64)
                                .padding(5)
                            
                            if let existingImage = vm.loadUserImage() {
                                existingImage
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(.circle)
                                    .frame(width: 64, height: 64)
                                    .padding(5)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text(vm.user.name)
                                .font(.title.bold())
                                .lineLimit(1)
                            Text(vm.user.status ?? "Available")
                                .lineLimit(1)
                        } // end of vstack
                    } // end of hstack
                } // end of profile
                
                //logout
                Section {
                    Button("Log out") { settingsVM.showLogoutAlert = true }
                        .foregroundStyle(.red)
                }
            } // end of list
            .navigationTitle("Settings")
            .alert("Are you sure you want to log out this account?", isPresented: $settingsVM.showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Confirm",action: vm.logout)
            }
        } detail: {
            Text("Swipe from the left edge to open setting menu.")
        } // end of navsplitview
    } // end of body
} // end of settingview

#Preview {
    SettingsView(vm: ContentView.VM())
}
