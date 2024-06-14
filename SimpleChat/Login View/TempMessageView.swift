//
//  TempMessageView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 12/06/24.
//

import MapKit
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
                            if isImage(message) {
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
                            }  else { // used for location
                                let coordinate = getCoordinate(message)
                                VStack(alignment: .leading) {
                                    Text("Location")
                                    
                                    Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinate[0], longitude: coordinate[1]), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))), interactionModes: [])
                                        .frame(width: 220, height: 170)
                                        .clipShape(.rect(cornerRadius: 20))
                                } // end of vstack
                                .padding(10)
                                .background(.blue.opacity(0.6))
                                .background(.white)
                                .clipShape(.rect(cornerRadius: 15))
                                .contextMenu {
                                    Button(role: .destructive) {
                                        deleteLocation(coordinate: message.imageURL, receiver: receiver)
                                    } label: {
                                        Label("Delete message", systemImage: "trash.fill")
                                            .tint(.red)
                                    }
                                    
                                    
                                    Button {
                                        Task {
                                            await resendLocation(location: message.imageURL, receiver: receiver, displayName: displayName)
                                        }
                                    } label: {
                                        Label("Resend", systemImage: "paperplane.fill")
                                    }
                                    
                                }
                                .padding(.leading, 12)
                            } // end if
                        } else {
                            Text(message.text)
                                .padding(10)
                                .background(.blue.opacity(message.messageStatus.hasPrefix("S") ? 0.6 : 0.4))
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
                            .fontWeight(vm.messageBackground.isEmpty ? .regular : .semibold)
                            .foregroundStyle(vm.messageBackground.isEmpty ? .secondary : .primary)
                            .shadow(radius: vm.messageBackground.isEmpty ? 0 : 5)
      
                    } // end of vstack
                    .padding(.bottom, 10)
                    
                } // end of hstack
            } // end of foreach
        } // end of vstack
    } // end of body    
} // end of tempmessageview

#Preview {
    TempMessageView(vm: ContentView.VM(), tempMessages: [.example, .exampleLocation], receiver: "", displayName: "")
}
