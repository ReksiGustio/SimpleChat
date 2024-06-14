//
//  ResponseData.swift
//  SimpleChat
//  This file contains data that convert from REST API to swift property
//
//  Created by Reksi Gustio on 07/06/24.
//

import CoreLocation
import SwiftUI


//this used for connection status
enum netStatus {
    case isConnected, isDisconnected, isConnecting
}

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
    let picture: String?
}

//this used for update message
struct updateRead: Codable {
    let read: String
}

//----------------------------------------------------------------
//single user property
struct User: Codable, Identifiable, Hashable {
    let id: Int
    var name: String
    let userName: String
    var status: String?
    var picture: String?
    
    static let empty = User(id: 0, name: "dummy name", userName: "", status: "Available", picture: nil)
}

//
//struct that store local image data {
struct UserImage: Codable {
    var userName: String
    var imageData: Data?
}

//class to save image to gallery
class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}

//
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
    let read: String
    let date: String
}

//message to send property
struct MessageText: Codable {
    let message: String?
    let image: String?
}

//preview photo
struct PreviewPhoto: Identifiable {
    let id = UUID()
    let photo: Image
    let data: Data
    
    static let example = PreviewPhoto(photo: Image(systemName: "xmark.circle"), data: Data())
}
    
//struct that contains messages
struct Messages: Codable, Identifiable, Hashable {
    
    var id = UUID().uuidString
    var receiver: String
    var displayName =  ""
    var lastDate = Date.now
    var items = [Message]()
    var tempMessages = [TempMessage]()
    
    static let example = Messages(receiver: "TestUser", displayName: "Dummy Name", lastDate: .now.addingTimeInterval(-5000), items: [
        Message(id: 0, userRelated: "TestSender, TestUser", text: "message 1", image: nil, read: "read", date: ""),
        Message(id: 1, userRelated: "TestSender, TestUser", text: "message 2 with long text, so long that the text becomes wrapped up.", image: nil, read: "unread", date: ""),
        Message(id: 2, userRelated: "TestUser, TestSender", text: "", image: "6.6710612335955375, -1.5860912827168079", read: "unread", date: "")
    ])
}

//----------------------------------------------------------------
//temporary message
struct TempMessage: Codable, Hashable, Identifiable {
    var id = UUID()
    var text = ""
    var imageId: String?
    var imageURL: String?
    var imageData: Data?
    var messageStatus = "Sending"
    
    static let example = TempMessage(text: "Mas Anies Mas Anies")
    static let exampleLocation = TempMessage(text: "", imageURL: "6.6710612335955375, -1.5860912827168079")
}

//----------------------------------------------------------------
//location fetcher
class LocationFetcher: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var lastKnownLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
    }

    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first?.coordinate
    }
}

//location data
struct LocationCoordinate: Identifiable {
    let id = UUID()
    var latitude = 0.0
    var longitude = 0.0
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
