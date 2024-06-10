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
                    selectedImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(.circle)
                } else if let existingImage = vm.loadUserImage(data: vm.userImage) {
                    existingImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(.circle)
                } else {
                    Circle()
                        .fill(.secondary)
                        .frame(width: 200, height: 200)
                }
            } // end of photopicker
            .onChange(of: settingsVM.pickerItem) { _ in settingsVM.loadImage() }
            .buttonStyle(PlainButtonStyle())
            .padding()
            
            HStack {
                if settingsVM.pickerItem != nil {
                    Button("Reset") {
                        settingsVM.pickerItem = nil
                        settingsVM.selectedImage = nil
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .padding(.bottom, 10)
                }
                
                if !vm.userImage.isEmpty {
                    Button("Remove Picture") {
                        vm.userImage = Data()
                        vm.user.picture = ""
                        settingsVM.pickerItem = nil
                        settingsVM.selectedImage = nil
                        settingsVM.compressedImage = Data()
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .padding(.bottom, 10)
                }
                
            } // end of hstack
            
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
                        vm.user.picture = "http://localhost:3000/download/profile/\(vm.userName)-profile_pic.jpg"
                        vm.userImage = settingsVM.compressedImage
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
