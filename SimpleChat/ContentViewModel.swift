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
            case login, logout, loading, opening
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
        @Published var loginState = LoginState.opening
        @Published var showPassword = false
        @Published var rememberUser = false {
            didSet {
                UserDefaults.standard.setValue(rememberUser, forKey: "rememberUser")
            }
        }
        
        //store current user data
        @Published var title = ""
        @Published private(set) var token = ""
        @Published var user = User.empty {
            didSet {
                if let encoded = try? JSONEncoder().encode(user) {
                    UserDefaults.standard.set(encoded, forKey: saveKey)
                }
            }
        }
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
                    UserDefaults.standard.set(encoded, forKey: contactsKey)
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
        @Published var chatsUser: User?
        @Published var messageBackground = Data() {
            didSet {
                UserDefaults.standard.set(messageBackground, forKey: "background")
            }
        }
        
        //used for showing an alert after REST API used
        @Published private(set) var message = ""
        @Published private(set) var subMessage = ""
        @Published var showMessage = false
        
        //used for load data locally
        var saveKey = "userData"
        var contactsKey: String { "\(user.userName)-contacts" }
        var contactsPictureKey: String { "\(user.userName)-contactsPicture" }
        var imageKey: String { "\(user.userName)-profile" }
        var messageKey: String { "\(user.userName)-messages" }
        
        //initializer
        init() {
            if let data = UserDefaults.standard.data(forKey: saveKey) {
                if let decodedData = try? JSONDecoder().decode(User.self, from: data) {
                    user = decodedData
                }
            }
            userName = UserDefaults.standard.string(forKey: "name") ?? ""
            messageBackground = UserDefaults.standard.data(forKey: "background") ?? Data()
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
            message = ""
            allMessages = loadData(messageKey, dataType: [Messages]())
            contacts = loadData(contactsKey, dataType: [User]())
            contactsPicture = loadData(contactsPictureKey, dataType: [UserImage]())
            timer = Timer.publish(every: 5, tolerance: 2, on: .main, in: .common).autoconnect()
            
            Task {
                let tempResponse = await login(userName: userName, password: password)
                
                if tempResponse.isEmpty {
                    message = "Error: Request timed out"
                    subMessage = "Check your internet connection and try again."
                    showMessage = true
                    if user.userName.isEmpty { loginState = .logout }
                    return
                }
                
                if let data = try? JSONDecoder().decode(ResponseData<LoginSuccessData>.self, from: tempResponse) {
                    user = data.data.user
                    token = data.data.token
                    allMessages = loadData(messageKey, dataType: [Messages]())
                    contacts = loadData(contactsKey, dataType: [User]())
                    contactsPicture = loadData(contactsPictureKey, dataType: [UserImage]())
                    if let imageURL = data.data.user.picture {
                        userImage = await downloadImage(url: imageURL) ?? Data()
                    }
                    await updateContacts()
                    loginState = .login
                    await updateContactsImage()
                }
                else if let data = try? JSONDecoder().decode(Response.self, from: tempResponse) {
                    message = data.message
                    showMessage = true
                    if user.userName.isEmpty { loginState = .logout }
                }
            }
        } // end of login func
        
        func loadData<T: Codable>(_ key: String, dataType: T) -> T {
            if let data = UserDefaults.standard.data(forKey: key) {
                if let decodedData = try? JSONDecoder().decode(T.self, from: data) {
                    return decodedData
                }
            }
            
            return dataType
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
        
        func updateRead(id: Int) async {
            Task {
                let tempResponse = await updateMessage(id: id, token: token)
                
                if tempResponse.isEmpty {
                    //failed response here
                }
            }
        } // end of update func
        
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
        func sendText(text: String?, image: String?, imageId: String? = nil, data: Data? = nil, receiver: String, displayName: String) async {
            
            //create temporary message
            if data == nil { createTemporaryText(text: text, receiver: receiver) }
            else { 
                createTemporaryImage(text: text, imageId: imageId, image: image, imageData: data, receiver: receiver)
            }
            
            Task {
                let tempResponse = await sendMessage(message: text, image: image, sender: userName, receiver: receiver, token: token)
                
                if !tempResponse.isEmpty {
                    await fetchMessageByUsername(receiver: receiver, displayName: displayName)
                    
                    if let index = allMessages.firstIndex(where: { $0.receiver == receiver }) {
                        if let tempIndex = allMessages[index].tempMessages.firstIndex(where: { $0.text == text }) {
                            allMessages[index].tempMessages.remove(at: tempIndex)
                        }
                    }
                    
                    messageText = ""
                } else {
                    //when message failed to send
                    if let index = allMessages.firstIndex(where: { $0.receiver == receiver }) {
                        if let tempIndex = allMessages[index].tempMessages.firstIndex(where: { $0.text == text }) {
                            allMessages[index].tempMessages[tempIndex].messageStatus = "Failed to send"
                        }
                    }
                    messageText = ""
                }
            }
        }
        
        //----------------------------------------------------------------
        //create temporary message
        func createTemporaryText(text: String?, receiver: String) {
            if let index = allMessages.firstIndex(where: { $0.receiver == receiver }) {
                allMessages[index].tempMessages.append(TempMessage(text: text ?? ""))
            }
        }
        
        //create temporary message with image
        func createTemporaryImage(text: String?, imageId: String?, image: String?, imageData: Data?, receiver: String) {
            if let index = allMessages.firstIndex(where: { $0.receiver == receiver }) {
                allMessages[index].tempMessages.append(TempMessage(text: text ?? "", imageId: imageId, imageURL: image, imageData: imageData))
            }
        }
        
        //----------------------------------------------------------------
        //logout user
        func logout() {
            timer.upstream.connect().cancel()
            user = User.empty
            allMessages = []
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
