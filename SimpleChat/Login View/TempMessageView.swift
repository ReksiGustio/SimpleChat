//
//  TempMessageView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 12/06/24.
//

import SwiftUI

struct TempMessageView: View {
    @ObservedObject var vm: ContentView.VM
    let tempMessages: [TempMessage]
    var receiver: String
    var displayName: String
    
    var body: some View {
        VStack {
            if !tempMessages.isEmpty {
                Text("Pending Message")
                    .foregroundStyle(vm.messageBackground.isEmpty ? .secondary : .primary)
            }
            
            ForEach(tempMessages) { message in
                HStack {
                    Rectangle()
                        .fill(.clear)
                        .frame(maxWidth: 10)
                        .onAppear {
                            print(message)
                        }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        if message.text.isEmpty {
                            if let image = convertImage(message.imageData)  {
                                ZStack(alignment: .bottomTrailing) {
                                    Color.clear
                                    
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(.rect(cornerRadius: 20))
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                deleteImage(id: message.imageId ?? "", receiver: receiver)
                                            } label: {
                                                Label("Delete message", systemImage: "trash.fill")
                                                    .tint(.red)
                                            }
                                            
                                            
                                            Button {
                                                Task {
                                                    await resendImage(id: message.imageId, imageUrl: message.imageURL, data: message.imageData, receiver: receiver, displayName: displayName)
                                                }
                                            } label: {
                                                Label("Resend", systemImage: "paperplane.fill")
                                            }
                                            
                                        }
                                } // end of zstack
                                .frame(maxWidth: 300, maxHeight: 250)
                            } // end if
                        } else {
                            Text(message.text)
                                .padding(10)
                                .background(.blue.opacity(message.messageStatus.hasPrefix("S") ? 0.8 : 0.5))
                                .background(.white)
                                .clipShape(.rect(cornerRadius: 15))
                                .contextMenu {
                                    Button(role: .destructive) {
                                        deleteText(text: message.text, receiver: receiver)
                                    } label: {
                                        Label("Delete message", systemImage: "trash.fill")
                                    }
                                    
                                    Button {
                                        UIPasteboard.general.string = message.text
                                    } label: {
                                        Label("Copy text to clipboard", systemImage: "doc.on.doc")
                                    }
                                    
                                    Button {
                                        Task {
                                            await resend(text: message.text, image: nil, receiver: receiver, displayName: displayName)
                                        }
                                    } label: {
                                        Label("Resend", systemImage: "paperplane.fill")
                                    }
                                }
                        } // end if
                        
                        Text(message.messageStatus)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
      
                    } // end of vstack
                    .padding(.bottom, 10)
                    
                } // end of hstack
            } // end of foreach
        } // end of vstack
    } // end of body    
} // end of tempmessageview

#Preview {
    TempMessageView(vm: ContentView.VM(), tempMessages: Array(repeating: TempMessage.example, count: 3), receiver: "", displayName: "")
}
