//
//  ContentView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 07/06/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = VM()    
    var body: some View {
        ZStack {
            if vm.loginState == .login {
                DashboardView(vm: vm)
            } else if vm.loginState == .opening {
                ZStack {
                    Color.black.opacity(0.3)
                    ProgressView()
                        .controlSize(.large)
                }
                .ignoresSafeArea()
                .onAppear {
                    vm.user = vm.loadData(vm.saveKey, dataType: User.empty)
                    if vm.user.userName.isEmpty {
                        vm.loginState = .logout
                    } else {
                        Task {
                            await vm.loginUser()
                            vm.loginState = .login
                        }
                    }
                }
            } else {
                LogoutView(vm: vm)
                    .allowsHitTesting(vm.loginState != .loading)
            } // end if state
            
            if vm.loginState == .loading {
                Group {
                    Color.black.opacity(0.3)
                    ProgressView()
                        .controlSize(.large)
                }
                .ignoresSafeArea()
            } // end if state
            
        }
    } // end of body
} // end of contentview

#Preview {
    ContentView()
}
