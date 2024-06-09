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
                        
                        if let existingImage = vm.loadUserImage() {
                            existingImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200)
                                .clipShape(.circle)
                        }
                        
                        selectedImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(.circle)
                        
                    } // end of zstack
                } else {
                    Circle()
                        .fill(.secondary)
                        .frame(width: 200, height: 200)
                }
            }
            .onChange(of: settingsVM.pickerItem) { _ in settingsVM.loadImage() }
            .buttonStyle(PlainButtonStyle())
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
                        vm.user.picture = nil
                    } else {
                        vm.user.picture = "http://172.20.57.25:3000/upload/profile/\(vm.userName)-profile_pic.jpg"
                    }
                    Task {
                        await uploadImage(settingsVM.compressedImage, userName: vm.userName)
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
            settingsVM.pickerItem = nil
            settingsVM.selectedImage = nil
        }
    } // end of body
    
} // end of profileview

#Preview {
    ProfileView(vm: ContentView.VM(), settingsVM: SettingsView.SettingsVM())
}
