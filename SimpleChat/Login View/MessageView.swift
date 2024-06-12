//
//  MessageView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 09/06/24.
//

import PhotosUI
import Combine
import SwiftUI

struct MessageView: View {
    @ObservedObject var vm: ContentView.VM
    @ObservedObject var chatsVM: ChatsView.ChatsVM
    @State private var isOpened = false
    @FocusState private var isFocused: Bool
    var messages: Messages
    var backgroundImage: Image? {
        Image(uiImage: UIImage(data: vm.messageBackground) ?? UIImage())
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                ZStack(alignment: .center) {
                    if !vm.messageBackground.isEmpty {
                        if let backgroundImage {
                            Color.secondary
                            
                            backgroundImage
                                .resizable(resizingMode: .stretch)
                                .clipped()
                        } else {
                            Color.clear
                        }
                    }
                    
                    ScrollView {
                        LazyVStack {
                            ForEach(sortedMessages) { message in
                                TextView(vm: vm, message: message)
                                    .id(message)
                            } // end of foreach
                            
                            Rectangle()
                                .fill(.clear)
                                .frame(maxHeight: 1)
                                
                            
                                if let index = vm.allMessages.firstIndex(where: { $0.receiver == messages.receiver }) {
                                    TempMessageView(vm: vm, tempMessages: vm.allMessages[index].tempMessages, receiver: vm.allMessages[index].receiver, displayName: messages.displayName)
                                        
                                }
                            
                        } // end of vstack
                        .padding()
                        .onReceive(Just(sortedMessages)) { _ in
                            if isOpened == false {
                                withAnimation {
                                    proxy.scrollTo(sortedMessages.last, anchor: .bottom)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    isOpened = true
                                }
                            }
                        }
                        
                    } // end of scrollView
                    
                } // end of zstack
                
                ZStack {
                    HStack(alignment: .bottom) {
                        TextField("Write your message", text: $vm.messageText, axis: .vertical)
                            .padding(.bottom, 10)
                            .focused($isFocused)
                        
                        Spacer()
                        
                        PhotosPicker(selection: $chatsVM.pickerItem) {
                            Image(systemName: "photo.fill")
                                .font(.title3)
                                .padding(10)
                        }
                        .onChange(of: chatsVM.pickerItem) { _ in chatsVM.loadImage() }
                        
                        Button {
                            let trimmedText = !vm.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            
                            if trimmedText {
                                Task {
                                    await vm.sendText(text: vm.messageText, image: nil, receiver: messages.receiver, displayName: messages.displayName)
                                    await vm.fetchMessageByUsername(receiver: messages.receiver, displayName: messages.displayName)
                                    withAnimation {
                                        proxy.scrollTo(sortedMessages.last, anchor: .bottom)
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .font(.title3)
                        }
                        .padding([.top, .bottom, .trailing], 10)
                        
                    } // end of hstack
                    .padding(.horizontal, 10)
                    .clipShape(.rect(cornerRadius: 15))
                    .overlay (
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.primary, lineWidth: 1)
                    )
                    .padding()
                } // end of ztack
            } // end of vstack
        } // end of scrollviewreader
        .navigationTitle(messages.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                HStack {
                    ZStack {
                        Circle().fill(.secondary)
                        
                        if let image = profilePicture {
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(.circle)
                        }
                    }
                    .frame(maxWidth: 44, maxHeight: 44)
                    .padding([.trailing, .bottom], 5)
                    
                    VStack(alignment: .leading) {
                        Text(messages.displayName)
                            .font(.headline)
                        Text(status)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } // end of vstack
                } // end of hstack
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { isFocused = false }
            }
        }
        .fullScreenCover(item: $chatsVM.previewPhoto) { photo in
            PhotoPreview(preview: photo, receiver: messages.displayName) { data in
                Task {
                    let id = UUID().uuidString
                    let imageString = "http://localhost:3000/download/message/\(vm.userName)-\(messages.receiver)-\(id)-message_pic.jpg"
                    await vm.sendText(text: "", image: imageString, imageId: id, data: data, receiver: messages.receiver, displayName: messages.displayName)
                    await uploadMessageImage(data, id: id, sender: vm.userName, receiver: messages.receiver)
                    await vm.fetchMessageByUsername(receiver: messages.receiver, displayName: messages.displayName)
                }
            }
        }
        .onAppear {
            Task {
                await vm.fetchMessageByUsername(receiver: messages.receiver, displayName: messages.displayName)
            }
        }
        .onDisappear {
            vm.chatsUser = nil
            chatsVM.selection = nil
        }
    } // end of body
    
    var sortedMessages: [Message] {
        if let index = vm.allMessages.firstIndex(where: { $0.receiver == messages.receiver }) {
            return vm.allMessages[index].items.sorted { $0.date < $1.date }
        }
        
        return []
    }
    
    var status: String {
        if let index = vm.contacts.firstIndex(where: { $0.name == messages.displayName }) {
            return vm.contacts[index].status ?? ""
        }
        return ""
    }
    
    var profilePicture: Image? {
        guard let index = vm.contactsPicture.firstIndex(where: { $0.userName == messages.receiver }) else { return nil }
        guard let imageData = vm.contactsPicture[index].imageData else { return nil }
        if let UIImage = UIImage(data: imageData) {
            return Image(uiImage: UIImage)
        }
        return nil
    }
    
} // end of message view

#Preview {
    MessageView(vm: ContentView.VM(), chatsVM: ChatsView.ChatsVM(), messages: Messages.example)
}
