//
//  ProfileView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 08/06/24.
//

import PhotosUI
import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ContentView.VM
    @StateObject var settingsVM: SettingsView.SettingsVM
    
    var body: some View {
        VStack {
            
            PhotosPicker(selection: $settingsVM.pickerItem) {
                if let selectedImage = settingsVM.selectedImage {
                    ZStack {
                        
                        selectedImage
                            .resizable()
                            .scaledToFill()
                            .clipShape(.circle)
                        
                        
                        if let existingImage = vm.loadUserImage() {
                            existingImage
                                .resizable()
                                .scaledToFill()
                                .clipShape(.circle)
                        }
                    } // end of zstack
                } else {
                    Circle()
                        .fill(.secondary)
                }
            }
            .onChange(of: settingsVM.pickerItem) { _ in settingsVM.loadImage() }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 200, height: 200)
            .padding()
            
            Form {
                Section("Display name:") {
                    TextField("Available", text: $vm.user.name)
                }
                
                Section("Set status:") {
                    TextField("Available", text: $settingsVM.status)
                }
                
                Button("Save changes") {
                    vm.user.status = settingsVM.status
                    if settingsVM.compressedImage.isEmpty {
                        vm.user.picture = ""
                    } else {
                        vm.user.picture = settingsVM.compressedImage
                    }
                    Task {
                        await vm.updateUser()
                        dismiss()
                    }
                }
            } // end of form
        } // end of vstack
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if vm.user.status != nil {
                settingsVM.status = vm.user.status ?? ""
            }
        }
        .onDisappear {
            settingsVM.selectedImage = nil
        }
    } // end of body
    
} // end of profileview

#Preview {
    ProfileView(vm: ContentView.VM(), settingsVM: SettingsView.SettingsVM())
}
