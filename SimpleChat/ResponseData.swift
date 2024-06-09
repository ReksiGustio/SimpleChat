//
//  ResponseData.swift
//  SimpleChat
//  This file contains data that convert from REST API to swift property
//
//  Created by Reksi Gustio on 07/06/24.
//

import Foundation

//this used for default response
struct Response: Codable {
    let success: Bool
    let message: String
    
}

//this used for success response
struct ResponseData<T: Codable>: Codable {
    let success: Bool
    let message: String
    let data: T
}

//----------------------------------------------------------------
//this used for register
struct RegisterData: Codable {
    let name: String
    let userName: String
    let password: String
}

//this used when the user already exist
struct RegisterError: Codable {
    let type: String
    let value: String
    let msg: String
    let path: String
    let location: String
}

//----------------------------------------------------------------
//this used for login
struct LoginData: Codable {
    let userName: String
    let password: String
}

//this used to retrieve token after login
struct LoginSuccessData: Codable {
    let user: User
    var token: String
}

//----------------------------------------------------------------
//this used for update user
struct updateUserData: Codable {
    let name: String
    let status: String?
    let picture: String
}

//----------------------------------------------------------------
//single user property
struct User: Codable, Identifiable {
    let id: Int
    var name: String
    let userName: String
    var status: String?
    var picture: String?
    
    static let empty = User(id: 0, name: "dummy name", userName: "dummy username", status: nil, picture: nil)
}

 //many user property
struct Users: Codable, Identifiable {
    var id = UUID()
    var users = [User]()
}

//single message property
struct Message: Codable, Hashable, Identifiable {
    let id: Int
    let userRelated: String
    let text: String
    let image: String?
    let date: String
}

//message to send property
struct MessageText: Codable {
    let message: String
}
    
    //struct that contains messages
struct Messages: Identifiable, Hashable {
    
    let id = UUID().uuidString
    var receiver: String
    var displayName =  ""
    var lastDate = Date.now
    var items = [Message]()
    
    static let example = Messages(receiver: "TestUser", displayName: "Dummy Name", lastDate: .now.addingTimeInterval(-5000), items: [
        Message(id: 0, userRelated: "TestSender, TestUser", text: "message 1", image: nil, date: ""),
        Message(id: 1, userRelated: "TestSender, TestUser", text: "message 2 with long text, so long that the text becomes wrapped up.", image: nil, date: ""),
        Message(id: 2, userRelated: "TestUser, TestSender", text: "It's the receiver sending me the message", image: nil, date: ""),
    ])
}

