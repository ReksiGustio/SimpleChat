//
//  TempMessageViewModel.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 12/06/24.
//

import Foundation
import SwiftUI

extension TempMessageView {
    
    func convertImage(_ data: Data?) -> Image? {
        guard let UIImage = UIImage(data: data ?? Data()) else { return nil }
        return Image(uiImage: UIImage)
    }
    
    func resend(text: String, image: String?, receiver: String, displayName: String) async {
        deleteText(text: text, receiver: receiver)
        
        await vm.sendText(text: text, image: image, receiver: receiver, displayName: displayName)
        await vm.fetchMessageByUsername(receiver: receiver, displayName: displayName)
        
    }
    
    func resendImage(id: String?, imageUrl: String?, data: Data?, receiver: String, displayName: String) async {
        deleteImage(id: id ?? "", receiver: receiver)
        
        
        await vm.sendText(text: "", image: imageUrl, imageId: id, data: data, receiver: receiver, displayName: displayName)
        await uploadMessageImage(data ?? Data(), id: id ?? "", sender: vm.userName, receiver: receiver)
        
        await vm.fetchMessageByUsername(receiver: receiver, displayName: displayName)
    }
    
    func resendLocation(location: String?, receiver: String, displayName: String) async {
        deleteLocation(coordinate: location ?? "", receiver: receiver)
        
        
        await vm.sendText(text: "", image: location, receiver: receiver, displayName: displayName)
        await vm.fetchMessageByUsername(receiver: receiver, displayName: displayName)
    }
    
    func deleteText(text: String, receiver: String) {
        if let index = vm.allMessages.firstIndex(where: { $0.receiver == receiver }) {
            if let tempIndex = vm.allMessages[index].tempMessages.firstIndex(where: { $0.text == text }) {
                vm.allMessages[index].tempMessages.remove(at: tempIndex)
            }
        }
    }
    
    func deleteImage(id: String, receiver: String) {
        if let index = vm.allMessages.firstIndex(where: { $0.receiver == receiver }) {
            if let tempIndex = vm.allMessages[index].tempMessages.firstIndex(where: { $0.imageId == id }) {
                vm.allMessages[index].tempMessages.remove(at: tempIndex)
            }
        }
    }
    
    func deleteLocation(coordinate: String?, receiver: String) {
        if let index = vm.allMessages.firstIndex(where: { $0.receiver == receiver }) {
            if let tempIndex = vm.allMessages[index].tempMessages.firstIndex(where: { $0.imageURL == coordinate }) {
                print(vm.allMessages[index].tempMessages[tempIndex])
                vm.allMessages[index].tempMessages.remove(at: tempIndex)
            }
        }
    }
    
    func isImage(_ message: TempMessage) -> Bool {
        guard let text = message.imageURL else { return false }
        
        if text.hasPrefix("http") { return true }
        else { return false }
    }
    
    func getCoordinate(_ message: TempMessage) -> [Double] {
        guard let stringCoordinate = message.imageURL else { return [0, 0] }
        
        //cheat sheet for displaying map
        if !stringCoordinate.hasPrefix("http") {
            let arrayCoordinate = stringCoordinate.components(separatedBy: ", ")
            let latitude = Double(arrayCoordinate.first ?? "0")
            let longitude = Double(arrayCoordinate.last ?? "0")
            return [latitude ?? 0, longitude ?? 0]
        } else {
            return [0, 0]
        }
    }
    
}
