//
//  MessageView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 09/06/24.
//

import PhotosUI
import SwiftUI

struct MessageView: View {
    @ObservedObject var vm: ContentView.VM
    @ObservedObject var chatsVM: ChatsView.ChatsVM
    @State private var isOpened = false
    @FocusState private var isFocused: Bool
    var messages: Messages
    
    var body: some View {
        ScrollViewReader { value in
            VStack {
                ScrollView {
                    LazyVStack {
                        ForEach(sortedMessages) { message in
                            TextView(vm: vm, message: message)
                        } // end of foreach
                        
                        Rectangle()
                            .fill(.clear)
                            .frame(maxHeight: 1)
                            .id(1)
                        
                    } // end of vstack
                    .padding()
                } // end of scrollView
                
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
                                }
                                value.scrollTo(1)
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
            .onAppear { value.scrollTo(1) }
        } // end of scrollviewreader
        .navigationTitle(messages.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
                    await vm.sendText(text: "", image: imageString, receiver: messages.receiver, displayName: messages.displayName)
                    await uploadMessageImage(data, id: id, sender: vm.userName, receiver: messages.receiver)
                    await vm.fetchMessageByUsername(receiver: messages.receiver, displayName: messages.displayName)
                }
            }
        }
        .onAppear {
            if isOpened == false {
                Task {
                    await vm.fetchMessageByUsername(receiver: messages.receiver, displayName: messages.displayName)
                    isOpened = true
                }
            }
        }
        .onDisappear {
            chatsVM.user = nil
            chatsVM.ipadUser = nil
            chatsVM.selection = nil
        }
    } // end of body
    
    var sortedMessages: [Message] {
        if let index = vm.allMessages.firstIndex(where: { $0.receiver == messages.receiver }) {
            return vm.allMessages[index].items.sorted { $0.date < $1.date }
        }
        
        return []
    }
    
} // end of message view

#Preview {
    MessageView(vm: ContentView.VM(), chatsVM: ChatsView.ChatsVM(), messages: Messages.example)
}
