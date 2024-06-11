//
//  ContentViewModel.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 07/06/24.
//

import SwiftUI

extension ContentView {
    // ViewModel for creating state properties
    @MainActor class VM: ObservableObject {
        enum LoginState {
            case login, logout, loading
        }
    
        //used for register page
        @Published var name = ""
        @Published var userName = "" {
            didSet {
                UserDefaults.standard.setValue(userName, forKey: "name")
            }
        }
        @Published var password = "" {
            didSet {
                UserDefaults.standard.setValue(password, forKey: "password")
            }
        }
        
        //used for login page
        @Published var loginState = LoginState.logout
        @Published var showPassword = false
        @Published var rememberUser = false {
            didSet {
                UserDefaults.standard.setValue(rememberUser, forKey: "rememberUser")
            }
        }
        
        //store current user data
        @Published var title = ""
        @Published private(set) var token = ""
        @Published var user = User.empty
        @Published var userImage = Data() {
            didSet {
                UserDefaults.standard.setValue(userImage, forKey: imageKey)
            }
        }
        
        //store other contacts locally
        @Published var chatContacts: Users?
        @Published var contacts = [User.empty]  {
            didSet {
                if let encoded = try? JSONEncoder().encode(contacts) {
                    UserDefaults.standard.set(encoded, forKey: saveKey)
                }
            }
        }
        @Published var contactsPicture = [UserImage]() {
            didSet {
                if let encoded = try? JSONEncoder().encode(contactsPicture) {
                    UserDefaults.standard.set(encoded, forKey: contactsPictureKey)
                }
            }
        }
        
        //store messages
        @Published var timer = Timer.publish(every: 5, tolerance: 2, on: .main, in: .common).autoconnect()
        var allMessages = [Messages]() {
            willSet {
                objectWillChange.send()
            }
        }
        @Published var messageText = ""
        @Published var imagePreview: PreviewPhoto?
        
        //used for showing an alert after REST API used
        @Published private(set) var message = ""
        @Published private(set) var subMessage = ""
        @Published var showMessage = false
        
        //used for load data locally
        var saveKey: String { user.userName }
        var contactsPictureKey: String { "\(user.userName)-contactsPicture" }
        var imageKey: String { "\(user.userName)-profile" }
        
        //initializer
        init() {
            userName = UserDefaults.standard.string(forKey: "name") ?? ""
            rememberUser = UserDefaults.standard.bool(forKey: "rememberUser")
            if rememberUser {
                password = UserDefaults.standard.string(forKey: "password") ?? ""
            }
        }
        
        //----------------------------------------------------------------
        //register new user
        func registerUser() async {
            loginState = .loading
            if name.isEmpty { name = "New User" }
            message = ""
            Task {
                let tempResponse = await register(name: name, userName: userName, password: password)
                
                if tempResponse.isEmpty {
                    message = "Error: Request timed out"
                    subMessage = "Check your internet connection and try again."
                    showMessage = true
                    loginState = .logout
                    return
                }
                
                if let data = try? JSONDecoder().decode(ResponseData<[RegisterError]>.self, from: tempResponse) {
                    message = data.message
                    subMessage = data.data[0].msg
                    showMessage = true
                    loginState = .logout
                    
                } else if let data = try? JSONDecoder().decode(Response.self, from: tempResponse) {
                    message = data.message
                    showMessage = true
                    loginState = .logout
                }
            }
            
        } // end of register func
        
        //----------------------------------------------------------------
        //login user
        func loginUser() async {
            loginState = .loading
            message = ""
            Task {
                let tempResponse = await login(userName: userName, password: password)
                
                if tempResponse.isEmpty {
                    message = "Error: Request timed out"
                    subMessage = "Check your internet connection and try again."
                    showMessage = true
                    loginState = .logout
                    return
                }
                
                if let data = try? JSONDecoder().decode(ResponseData<LoginSuccessData>.self, from: tempResponse) {
                    user = data.data.user
                    token = data.data.token
                    allMessages = []
                    contacts = loadContacts(saveKey)
                    contactsPicture = loadContactsPicture(contactsPictureKey)
                    if let imageURL = data.data.user.picture {
                        userImage = await downloadImage(url: imageURL) ?? Data()
                    }
                    timer = Timer.publish(every: 5, tolerance: 2, on: .main, in: .common).autoconnect()
                    await updateContacts()
                    loginState = .login
                    await updateContactsImage()
                }
                else if let data = try? JSONDecoder().decode(Response.self, from: tempResponse) {
                    message = data.message
                    showMessage = true
                    loginState = .logout
                }
            }
        } // end of login func
        
        func loadContacts(_ key: String) -> [User] {
            if let data = UserDefaults.standard.data(forKey: key) {
                if let decodedData = try? JSONDecoder().decode([User].self, from: data) {
                    return decodedData
                }
            }
            
            return []
        } // end of load contacts func
        
        func loadContactsPicture(_ key: String) -> [UserImage] {
            if let data = UserDefaults.standard.data(forKey: key) {
                if let decodedData = try? JSONDecoder().decode([UserImage].self, from: data) {
                    return decodedData
                }
            }
            
            return []
        } // end of load contacts func
        
        func loadUserPicture(_ key: String) -> Data {
            if let data = UserDefaults.standard.data(forKey: imageKey) {
                return data
            }
            return Data()
        }
        
        //----------------------------------------------------------------
        //update user
        func updateUser() async {
            message = ""
            Task {
                let tempResponse = await update(userName: userName, token: token, name: user.name, status: user.status, images: user.picture)
                
                if tempResponse.isEmpty {
                    message = "Error: Request timed out"
                    subMessage = "Check your internet connection and try again."
                    showMessage = true
                    return
                }
                
                if let data = try? JSONDecoder().decode(ResponseData<LoginSuccessData>.self, from: tempResponse) {
                    user = data.data.user
                }
                else if let data = try? JSONDecoder().decode(Response.self, from: tempResponse) {
                    message = data.message
                    showMessage = true
                }
            }
        } // end of update func
        
        //update contacts
        func updateContacts() async {
            if !contacts.isEmpty {
                for user in contacts {
                    if let index = contacts.firstIndex(where: { $0.userName == user.userName }) {
                        Task {
                            if let response = await search(userName: user.userName, token: token) {
                                if let data = try? JSONDecoder().decode(ResponseData<User>.self, from: response) {
                                    contacts[index].name = data.data.name
                                    contacts[index].status = data.data.status
                                    contacts[index].picture = data.data.picture
                                }
                            }
                        } // end of task
                    }
                } // end for
            }
        } // end of updatecontacts
        
        //update one contact
        func updateContact(_ userName: String) async {
            if let index = contacts.firstIndex(where: { $0.userName == userName }) {
                Task {
                    if let response = await search(userName: userName, token: token) {
                        if let data = try? JSONDecoder().decode(ResponseData<User>.self, from: response) {
                            contacts[index].name = data.data.name
                            contacts[index].status = data.data.status
                            contacts[index].picture = data.data.picture
                        }
                    }
                } // end of task
            }
        } // end of udpatecontact
        
        //----------------------------------------------------------------
        //load image
        func loadUserImage(data: Data) -> Image? {
            if let UIPicture = UIImage(data: data) {
                return Image(uiImage: UIPicture)
            }
            
            return nil
        } // end of load user image
        
        func updateContactsImage() async {
            if !contactsPicture.isEmpty {
                for user in contactsPicture {
                    guard let index = contacts.firstIndex(where: { $0.userName == user.userName }) else { continue }
                    Task {
                        guard let stringURL = contacts[index].picture else { return }
                        guard let downloadedImageData = await downloadImage(url: stringURL) else { return }
                        if let userIndex = contactsPicture.firstIndex(where: { $0.userName == user.userName} ) {
                            contactsPicture[userIndex].imageData = downloadedImageData
                        }
                    } // end task
                }
            } // end if
        } // end of update contacts image
        
        //download image
        func downloadImage(url: String) async -> Data? {
            guard let imageURL = URL(string: url) else { return nil }
            let request = URLRequest(url: imageURL)
                
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                return data
            } catch {
                print(error.localizedDescription)
                return nil
            }
            
        }
        
        //download one preview photo
        func downloadPreviewPhoto(url: String) async -> PreviewPhoto? {
            guard let imageURL = URL(string: url) else { return nil }
            let request = URLRequest(url: imageURL)
                
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                if let UIImage = UIImage(data: data) {
                    let image = Image(uiImage: UIImage)
                    return PreviewPhoto(photo: image, data: data)
                }
            } catch {
                print(error.localizedDescription)
                return nil
            }
            return nil
        }
        
        //----------------------------------------------------------------
        //get message
        func fetchMessageByUsername(receiver: String, displayName: String) async {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            if let index = contacts.firstIndex(where: { $0.userName == receiver }) {
                Task {
                    let response = await fetchMessage(sender: user.userName, receiver: contacts[index].userName, token: token)
                    if let data = try? decoder.decode(ResponseData<[Message]>.self, from: response) {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                        
                        var messages = Messages(receiver: receiver, displayName: displayName)
                        messages.items = data.data
                        if let lastDate = data.data.last?.date {
                            messages.lastDate = dateFormatter.date(from: lastDate) ?? .now
                        }
                        
                        for _ in allMessages {
                            if let messageIndex = allMessages.firstIndex(where: { $0.receiver == receiver }) {
                                allMessages[messageIndex].items = messages.items
                                return
                            }
                        }
                        allMessages.append(messages)
                    }
                } // end task
            }
        } // end of get message func
        
        //send message
        func sendText(text: String?, image: String?, receiver: String, displayName: String) async {
            Task {
                let tempResponse = await sendMessage(message: text, image: image, sender: userName, receiver: receiver, token: token)
                
                if !tempResponse.isEmpty {
                    await fetchMessageByUsername(receiver: receiver, displayName: displayName)
                    messageText = ""
                }
            }
        }
        
        //----------------------------------------------------------------
        //logout user
        func logout() {
            timer.upstream.connect().cancel()
            user = User.empty
            token = ""
            message = ""
            subMessage = ""
            title = ""
            showMessage = false
            rememberUser = false
            userImage = Data()
            loginState = .logout
        }
    } // end of viewmodel
}
