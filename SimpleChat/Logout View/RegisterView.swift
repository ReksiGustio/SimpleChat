//
//  RegisterView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 07/06/24.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ContentView.VM
    @ObservedObject var logoutVM: LogoutView.LogoutVM
    var logoutView: LogoutView
    
    var body: some View {
        VStack {
            
            //header
            Text("Register new User")
                .font(.title.bold())
            
            //Text field
            Group {
                TextField("Display Name", text: $vm.name)
                TextField("Username", text: $vm.userName)
                if vm.showPassword {
                    TextField("Password", text: $vm.password)
                    TextField("Confirmation Password", text: $logoutVM.confirmationPassword)
                } else {
                    SecureField("Password", text: $vm.password)
                    SecureField("Confirmation Password", text: $logoutVM.confirmationPassword)
                }
            }
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .textFieldStyle(.roundedBorder)
            .shadow(radius: 5)
            .frame(maxWidth: 350)
            .padding(8)
            
            //CheckBox
            HStack {
                Button {
                    vm.showPassword.toggle()
                } label: {
                    Label("Show Password", systemImage: vm.showPassword ? "square.inset.filled" : "square" )
                }
                
                Spacer()
            } // end of hstack
            .frame(maxWidth: 350)
            .padding(8)
            
            //error
            if logoutVM.showError {
                Text(logoutVM.errorMessage)
                    .foregroundStyle(.red)
            }
            
            //submit button
            HStack {
                Group {
                    Button("Submit") {
                        if logoutView.verifyRegister() {
                            Task {
                                dismiss()
                                await vm.registerUser()
                                logoutVM.showError = false
                            }
                        }
                    }
                }
                .buttonStyle(BorderedProminentButtonStyle())
                
            } // end of hstack
            
        } // end of vstack
        .onAppear {
            logoutVM.errorMessage = ""
        }
        .onDisappear {
            logoutVM.errorMessage = ""
        }
    }
    
}

#Preview {
    RegisterView(vm: ContentView.VM(), logoutVM: LogoutView.LogoutVM(), logoutView: LogoutView(vm: ContentView.VM(), logoutVM: LogoutView.LogoutVM()))
}
