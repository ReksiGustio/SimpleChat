//
//  LogoutViewModel.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 07/06/24.
//

import Foundation

extension LogoutView {
    // ViewModel for creating state properties
    @MainActor class LogoutVM: ObservableObject {
        @Published var confirmationPassword = ""
        @Published var errorMessage = ""
        @Published var showError = false
        @Published var showRegister = false
    } // end of view model
    
    //----------------------------------------------------------------
    // verify register data
    func matchRegisterData() -> Bool {
        if vm.userName.isEmpty {
            logoutVM.errorMessage = "Username is required."
            return false
        }
        
        if vm.password.count < 6 {
            logoutVM.errorMessage = "Password must have at least 6 characters."
            return false
        }
        
        if vm.password == logoutVM.confirmationPassword {
            logoutVM.errorMessage = ""
            return true
        } else {
            logoutVM.errorMessage = "Password doesn't match."
            return false
        }
    }
    
    //register
    func goToRegister() {
        logoutVM.showRegister = true
        vm.name = ""
        vm.userName = ""
        vm.password = ""
        logoutVM.confirmationPassword = ""
    }
    
    func verifyRegister() -> Bool {
        let verified = matchRegisterData()
        if verified {
            return true
        } else {
            logoutVM.showError = true
            return false
        }
    }
    //----------------------------------------------------------------
    //verify login data
    func matchLoginData() -> Bool {
        if vm.userName.isEmpty {
            logoutVM.errorMessage = "Username is required."
            return false
        }
        
        if vm.password.count < 6 {
            logoutVM.errorMessage = "Password must have at least 6 characters."
            return false
        }
        
        return true
    }
    
    // login
    func verifyLogin() {
        let verified = matchLoginData()
        if verified {
            Task {
                await vm.loginUser()
                logoutVM.showError = false
            }
        } else {
            logoutVM.showError = true
        }
    }
    
}
