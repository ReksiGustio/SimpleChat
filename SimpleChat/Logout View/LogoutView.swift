//
//  LogoutView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 07/06/24.
//

import SwiftUI

struct LogoutView: View {
    @ObservedObject var vm: ContentView.VM
    @StateObject var logoutVM = LogoutVM()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            
            //header
            Text("Log in to Simple Chat")
                .font(.title.bold())
            
            //Text field
            Group {
                TextField("Username", text: $vm.userName)
                    .focused($isFocused)
                if vm.showPassword {
                    TextField("Password", text: $vm.password)
                        .focused($isFocused)
                } else {
                    SecureField("Password", text: $vm.password)
                        .focused($isFocused)
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
                
                Button {
                    vm.rememberUser.toggle()
                } label: {
                    Label("Remember me", systemImage: vm.rememberUser ? "square.inset.filled" : "square" )
                }
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
                    Button("Log in", action: verifyLogin)
                    Button("Register", action: goToRegister)
                }
                .buttonStyle(BorderedProminentButtonStyle())
                
            } // end of hstack
            
        } // end of vstack
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { isFocused = false }
            }
        }
        .alert(vm.message, isPresented: $vm.showMessage) { } message: {
            Text(vm.subMessage)
        }
        .sheet(isPresented: $logoutVM.showRegister) {
            RegisterView(vm: vm, logoutVM: logoutVM, logoutView: self)
        }
    } // end of body
} // end of logoutview

#Preview {
    LogoutView(vm: ContentView.VM())
}
