//
//  TextView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 09/06/24.
//

import SwiftUI

struct TextView: View {
    @ObservedObject var vm: ContentView.VM
    let message: Message
    
    var body: some View {
        if !message.userRelated.hasPrefix(vm.userName) {
            HStack {
                VStack(alignment: .leading) {
                    if message.text.isEmpty {
                        AsyncImage(url: URL(string: message.image ?? "")) { phase in
                            if let image = phase.image {
                                ZStack(alignment: .bottomLeading) {
                                    Color.clear
                                    
                                    Button {
                                        Task {
                                            await vm.imagePreview = vm.downloadPreviewPhoto(url:  message.image ?? "")
                                        }
                                    } label: {
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(.rect(cornerRadius: 20))
                                    }
                                } // end of zstack
                                .frame(maxWidth: 300, maxHeight: 250)
                            } else if phase.error != nil {
                                VStack {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                    
                                    Text("Download failed")
                                }
                                .padding()
                                .backgroundStyle(.ultraThinMaterial)
                                .padding(.leading, 10)
                            } else {
                                ProgressView()
                                    .controlSize(.large)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 15)
                            }
                        }
                        .padding([.top, .bottom, .trailing], 10)
                        .padding(.trailing, 12)
                    } else {
                        Text(message.text)
                            .padding(10)
                            .background(.primary.opacity(0.1))
                            .background(Color(uiColor: .systemBackground))
                            .clipShape(.rect(cornerRadius: 15))
                            .contextMenu {
                                Button {
                                    UIPasteboard.general.string = message.text
                                } label: {
                                    Label("Copy text to clipboard", systemImage: "doc.on.doc")
                                }
                            }
                    } // end if
                    
                    Text(segmentedDate(message.date))
                        .font(.subheadline)
                        .fontWeight(vm.messageBackground.isEmpty ? .regular : .bold)
                        .foregroundStyle(vm.messageBackground.isEmpty ? .secondary : .primary)
                        .shadow(radius: vm.messageBackground.isEmpty ? 0 : 5)

                } // end of vstack
                .padding(.bottom, 10)
                
                Spacer()
                
                Rectangle()
                    .fill(.clear)
                    .frame(maxWidth: 10)
                
            } // end of hstack
        } else {
            HStack {
                Rectangle()
                    .fill(.clear)
                    .frame(maxWidth: 10)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    if message.text.isEmpty {
                        AsyncImage(url: URL(string: message.image ?? "")) { phase in
                            if let image = phase.image {
                                ZStack(alignment: .bottomTrailing) {
                                    Color.clear
                                    
                                    Button {
                                        Task {
                                            await vm.imagePreview = vm.downloadPreviewPhoto(url:  message.image ?? "")
                                        }
                                    } label: {
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(.rect(cornerRadius: 20))
                                    }
                                } // end of zstack
                                .frame(maxWidth: 300, maxHeight: 250)
                            } else if phase.error != nil {
                                VStack {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                    
                                    Text("Download failed")
                                }
                                .padding()
                                .backgroundStyle(.ultraThinMaterial)
                                .padding(.trailing, 10)
                            } else {
                                ProgressView()
                                    .controlSize(.large)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 15)
                            }
                        }
                        .padding([.top, .bottom, .leading], 10)
                        .padding(.leading, 12)
                    } else {
                        Text(message.text)
                            .padding(10)
                            .background(.blue.opacity(0.8))
                            .background(.white)
                            .clipShape(.rect(cornerRadius: 15))
                            .contextMenu {
                                Button {
                                    UIPasteboard.general.string = message.text
                                } label: {
                                    Label("Copy text to clipboard", systemImage: "doc.on.doc")
                                }
                            }
                    } // end if
                    
                    Text(segmentedDate(message.date))
                        .font(.subheadline)
                        .fontWeight(vm.messageBackground.isEmpty ? .regular : .bold)
                        .foregroundStyle(vm.messageBackground.isEmpty ? .secondary : .primary)
                        .shadow(radius: vm.messageBackground.isEmpty ? 0 : 5)
  
                } // end of vstack
                .padding(.bottom, 10)
                
            } // end of hstack
            .fullScreenCover(item: $vm.imagePreview) { preview in
                ImageView(image: preview.photo)
                    .onDisappear {
                        vm.imagePreview = nil
                    }
            }
        } // end if
    } // end of body
    
    func segmentedDate(_ text: String) -> String {
        let date = convertDate(text)
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "\(date.formatted(date: .omitted, time: .shortened))"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday at \(date.formatted(date: .omitted, time: .shortened))"
        } else {
            return "\(date.formatted(date: .abbreviated, time: .shortened))"
        }
    }
    
    func convertDate(_ text: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        return dateFormatter.date(from: text) ?? .now
    }
} // end of textview

#Preview {
    TextView(vm: ContentView.VM(), message: Message(id: 0, userRelated: "", text: "", image: "", date: ""))
}
