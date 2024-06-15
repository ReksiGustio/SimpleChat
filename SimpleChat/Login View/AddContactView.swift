//
//  AddContactView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 08/06/24.
//

import SwiftUI

struct AddContactView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ContentView.VM
    @FocusState private var isFocused: Bool

    @State private var message = ""
    @State private var showMessage = false
    @State private var showScanner = false
    
    @Binding var searchName: String
    @Binding var user: User?
    @Binding var downloadedData: Data?
    @Binding var downloadedImage: Image?
    
    var body: some View {
        Form {
            Section {
                HStack {
                    TextField("Insert Username", text: $searchName)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused($isFocused)
                        .onSubmit {
                            isFocused = false
                        }
                    
                    Button("Submit") {
                        Task {
                            isFocused = false
                            await searchUser(searchName)
                        }
                    }
                } // end of hstack
                
                Button("Scan QR Code") { 
                    showScanner = true
                    searchName = ""
                }
                
            } // end of section
            
            Section {
                if let user = user {
                    HStack {
                        //image placeholder
                        ZStack {
                            Circle()
                                .fill(.secondary)
                                .frame(width: 64, height: 64)
                                .padding(5)
                            
                            if let downloadedImage {
                                downloadedImage
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(.circle)
                                    .frame(width: 64, height: 64)
                                    .padding(5)
                            }
                        } // end of zstack
                        
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.title.bold())
                                .lineLimit(1)
                            Text(user.userName)
                                .lineLimit(1)
                        } // end of vstack
                    } // end of hstack
                    
                    Button(sameUser ? "You can't add yourself" : "Add to contact") {
                        if !sameUser { addToContact(user.userName) }
                    }
                    .foregroundStyle(sameUser ? .red : .blue)
                    
                }
            } // end of section
            
        } // end of form
        .navigationTitle("Add New Contact")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { isFocused = false }
            }
        }
        .sheet(isPresented: $showScanner) {
            QRScannerView() { scannedText in
                searchName = scannedText
                Task {
                    await searchUser(searchName)
                }
            }
        }
        .onAppear { user = nil }
        .alert(message, isPresented: $showMessage) { }
    }
    
    var sameUser: Bool {
        user?.userName == vm.user.userName
    }
    
    //search user
    func searchUser(_ userName: String) async {
        message = ""
        let trimmedUsername = userName.filter { !$0.isWhitespace }
        if !searchName.isEmpty {
            Task {
                if let tempResponse = await search(userName: trimmedUsername, token: vm.token) {
                    print(String(data: tempResponse, encoding: .utf8)!)
                    if let data = try? JSONDecoder().decode(ResponseData<User>.self, from: tempResponse) {
                        user = data.data
                        searchName = ""
                        downloadedImage = nil
                        Task {
                            guard let stringURL = data.data.picture else { return }
                            guard let downloadedImageData = await vm.downloadImage(url: stringURL) else { return }
                            if let UIImage = UIImage(data: downloadedImageData) {
                                downloadedData = downloadedImageData
                                downloadedImage = Image(uiImage: UIImage)
                            }
                        }
                    } else if let data = try? JSONDecoder().decode(Response.self, from: tempResponse) {
                        message = data.message
                        showMessage = true
                    }
                }
            }
        }
    } // end of search func
    
    //check contact
    func addToContact(_ userName: String) {
        for contact in vm.contacts {
            if contact.userName == userName {
                message = "User is already in your contacts."
                showMessage = true
                return
            }
        }
        
        vm.contacts.append(user!)
        vm.contactsPicture.append(UserImage(userName: user?.userName ?? "", imageData: downloadedData))
        Task {
            await vm.updateContact(user?.userName ?? "")
        }
        dismiss()
    } // end of check contact func
    
}

#Preview {
    AddContactView(vm: ContentView.VM(), searchName: .constant(""), user: .constant(User(id: 0, name: "Dummy", userName:"DummyUser")), downloadedData: .constant(Data()), downloadedImage: .constant(Image(systemName: "xmark.circle")))
}
