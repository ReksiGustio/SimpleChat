//
//  Routes.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 07/06/24.
//

import Foundation
import UIKit

extension Data {
   mutating func append(_ string: String) {
      if let data = string.data(using: .utf8) {
         append(data)
         print("data======>>>",data)
      }
   }
}

//----------------------------------------------------------------
//register new user
func register(name: String, userName: String, password: String) async -> Data {
    let userData = RegisterData(name: name, userName: userName, password: password)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let url = URL(string: "http://localhost:3000/register")!
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
    
    let url = URL(string: "http://localhost:3000/login")!
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
func update(userName: String, token: String, name: String, status: String?, images: String?) async -> Data {
    let userData = updateUserData(name: name, status: status, picture: images)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    print("userData: \(userData)")
    let url = URL(string: "http://localhost:3000/users/\(userName)")!
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

//search user
func search(userName: String, token: String) async -> Data? {
    let url = URL(string: "http://localhost:3000/users/\(userName)")!
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
    guard let url = URL(string: "http://localhost:3000/message/\(sender)&\(receiver)") else { return Data() }
    var request = URLRequest(url: url)
    request.setValue(token, forHTTPHeaderField: "Authorization")
    request.timeoutInterval = 4
    
    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    } catch {
        let string = "\(error.localizedDescription)"
        print(error.localizedDescription)
        return Data(string.utf8)
    }
}

//send message
func sendMessage(message: String?, image: String?, sender: String, receiver: String, token: String) async -> Data {
    let messageData = MessageText(message: message, image: image)
    guard let encoded = try? JSONEncoder().encode(messageData) else { return Data() }
    
    let url = URL(string: "http://localhost:3000/message/\(sender)&\(receiver)")!
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

func updateMessage(id: Int) async {
    let readData = updateRead(read: "read")
    guard let encoded = try? JSONEncoder().encode(readData) else { return }
    let url = URL(string: "http://localhost:3000/message/\(id)")!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "PUT"
    request.timeoutInterval = 5
    
    do {
        let _ = try await URLSession.shared.upload(for: request, from: encoded)
    } catch {
        print(error.localizedDescription)
    }
}

//----------------------------------------------------------------
//upload profile image
func uploadImage(_ image: Data, userName: String) async {
    let boundary = generateBoundaryString()
    let body = createBody(boundary: boundary, name: "profile_pic", fieldName: "profile_pic.jpg", image: image)
    
    let url = URL(string: "http://localhost:3000/upload/profile/\(userName)")!
    var request = URLRequest.init(url: url)
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.httpBody = body as Data
    request.timeoutInterval = 10

    do {
        if let encoded = request.httpBody {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            print(String(data: data, encoding: .utf8) ?? "")
        }
    } catch {
        print(error.localizedDescription)
    }

}

//upload messageImage
func uploadMessageImage(_ image: Data, id: String, sender: String, receiver: String) async {
    let boundary = generateBoundaryString()
    let body = createBody(boundary: boundary, name: "message_pic", fieldName: "message_pic.jpg", image: image)
    
    let url = URL(string: "http://localhost:3000/upload/message/\(sender)&\(receiver)&\(id)")!
    var request = URLRequest.init(url: url)
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.httpBody = body as Data
    request.timeoutInterval = 10
    
    do {
        if let encoded = request.httpBody {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            print(String(data: data, encoding: .utf8) ?? "")
        }
    } catch {
        print(error.localizedDescription)
    }
    
}

//----------------------------------------------------------------
//create bondary and body for uploading image
func generateBoundaryString() -> String {
    return "Boundary-\(NSUUID().uuidString)"
}

func createBody(boundary: String, name: String, fieldName: String, image: Data) -> NSMutableData {
    let body = NSMutableData()
    
    let mimetype = "image/png"

    body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
    body.append("Content-Disposition:form-data; name=\"\(name)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
    body.append("hi\r\n".data(using: String.Encoding.utf8)!)

    body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
    body.append("Content-Disposition:form-data; name=\"\(name)\"; filename=\"\(fieldName)\"\r\n".data(using: String.Encoding.utf8)!)
    body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
    body.append(image)

    body.append("\r\n".data(using: String.Encoding.utf8)!)
    body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
    
    return body
}
