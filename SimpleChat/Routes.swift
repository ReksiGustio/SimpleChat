//
//  Routes.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 07/06/24.
//

import Foundation

//----------------------------------------------------------------
//register new user
func register(name: String, userName: String, password: String) async -> Data {
    let userData = RegisterData(name: name, userName: userName, password: password)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let url = URL(string: "http://172.20.57.25:3000/register")!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.timeoutInterval = 20
    
    do {
        let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
        return data
    } catch {
        print(error.localizedDescription)
        return Data()
    }
}

//----------------------------------------------------------------
//login user
func login(userName: String, password: String) async -> Data {
    let userData = LoginData(userName: userName, password: password)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let url = URL(string: "http://172.20.57.25:3000/login")!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.timeoutInterval = 20
    
    do {
        let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
        return data
    } catch {
        print(error.localizedDescription)
        return Data()
        
    }
}

//----------------------------------------------------------------
//update user
func update(userName: String, token: String, name: String, status: String?, images: String) async -> Data {
    let userData = updateUserData(name: name, status: status, picture: images.isEmpty ? "" : images)
    print("userData: \(userData)")
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let url = URL(string: "http://172.20.57.25:3000/users/\(userName)")!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(token, forHTTPHeaderField: "Authorization")
    request.httpMethod = "PUT"
    request.timeoutInterval = 20
    
    do {
        let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
        return data
    } catch {
        print(error.localizedDescription)
        return Data()
    }
}

//----------------------------------------------------------------
//search user
func search(userName: String, token: String) async -> Data? {
    let url = URL(string: "http://172.20.57.25:3000/users/\(userName)")!
    var request = URLRequest(url: url)
    request.setValue(token, forHTTPHeaderField: "Authorization")
    request.timeoutInterval = 20
    
    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

//----------------------------------------------------------------
//fetch message
func fetchMessage(sender: String, receiver: String, token: String) async -> Data {
    let url = URL(string: "http://172.20.57.25:3000/message/\(sender)&\(receiver)")!
    var request = URLRequest(url: url)
    request.setValue(token, forHTTPHeaderField: "Authorization")
    request.timeoutInterval = 4
    
    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    } catch {
        print(error.localizedDescription)
        return Data()
    }
}

//send message
func sendMessage(message: String, sender: String, receiver: String, token: String) async -> Data {
    let messageData = MessageText(message: message)
    guard let encoded = try? JSONEncoder().encode(messageData) else { return Data() }
    
    let url = URL(string: "http://172.20.57.25:3000/message/\(sender)&\(receiver)")!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.setValue(token, forHTTPHeaderField: "Authorization")
    request.timeoutInterval = 20
    
    do {
        let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
        return data
    } catch {
        print(error.localizedDescription)
        return Data()
    }
}
