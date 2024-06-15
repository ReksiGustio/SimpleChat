//
//  TextView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 09/06/24.
//

import MapKit
import SwiftUI

struct TextView: View {

    @ObservedObject var vm: ContentView.VM
    let message: Message
    
    var body: some View {
        if !message.userRelated.hasPrefix(vm.userName) {
            HStack {
                VStack(alignment: .leading) {
                    if message.text.isEmpty {
                        if isImage { //this for image
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
                            
                        }  else {// this for coordinate
                            Button {
                                vm.locationPreview = LocationCoordinate(latitude: coordinate[0], longitude: coordinate[1])
                            } label: {
                                VStack(alignment: .leading) {
                                    
                                    Text("Location")
                                    
                                    Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinate[0], longitude: coordinate[1]), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))), interactionModes: [])
                                        .frame(width: 220, height: 170)
                                        .clipShape(.rect(cornerRadius: 20))
                                } // end of vstack
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(10)
                            .background(.primary.opacity(0.1))
                            .background(Color(uiColor: .systemBackground))
                            .clipShape(.rect(cornerRadius: 15))
                            .padding(.trailing, 12)
                        }
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
                        .fontWeight(vm.messageBackground.isEmpty ? .regular : .semibold)
                        .foregroundStyle(vm.messageBackground.isEmpty ? .secondary : .primary)
                        .shadow(radius: vm.messageBackground.isEmpty ? 0 : 5)

                } // end of vstack
                
                Spacer()
                
                Rectangle()
                    .fill(.clear)
                    .frame(maxWidth: 10)
                
            } // end of hstack
            .background(.blue.opacity(message.read != "read" ? 0.4 : 0))
            .clipShape(.rect(cornerRadius: 5))
        } else {
            HStack {
                Rectangle()
                    .fill(.clear)
                    .frame(maxWidth: 10)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    if message.text.isEmpty {
                        if isImage { //this for image
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
                        } else { // this for location
                            Button {
                                vm.locationPreview = LocationCoordinate(latitude: coordinate[0], longitude: coordinate[1])
                            } label: {
                                VStack(alignment: .leading) {
                                    Text("Location")
                                    
                                    Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinate[0], longitude: coordinate[1]), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))), interactionModes: [])
                                        .frame(width: 220, height: 170)
                                        .clipShape(.rect(cornerRadius: 20))
                                } // end of vstack
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(10)
                            .background(.blue.opacity(0.6))
                            .background(.white)
                            .clipShape(.rect(cornerRadius: 15))
                            .padding(.leading, 12)
                        }
                    } else {
                        Text(message.text)
                            .padding(10)
                            .background(.blue.opacity(0.6))
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
                    
                    HStack{
                        Text(segmentedDate(message.date))
                        
                        Image(systemName: "checkmark")
                            .foregroundStyle(message.read == "read" ? .blue : (vm.messageBackground.isEmpty ? .secondary : .primary))
                    }
                    .font(.subheadline)
                    .fontWeight(vm.messageBackground.isEmpty ? .regular : .bold)
                    .foregroundStyle(vm.messageBackground.isEmpty ? .secondary : .primary)
                    .shadow(radius: vm.messageBackground.isEmpty ? 0 : 5)
  
                } // end of vstack
                
            } // end of hstack
            .fullScreenCover(item: $vm.imagePreview) { preview in
                ImageView(image: preview.photo, data: preview.data)
                    .onDisappear {
                        vm.imagePreview = nil
                    }
            }
        } // end if
    } // end of body
    
    var coordinate: [Double] {
        guard let stringCoordinate = message.image else { return [0, 0] }
        
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
    
    var isImage: Bool {
        guard let text = message.image else { return false }
        
        if text.hasPrefix("http") { return true }
        else { return false }
    }
    
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
    TextView(vm: ContentView.VM(), message: Message(id: 0, userRelated: "", text: "", image: "6.6710612335955375, -1.5860912827168079", read: "unread", date: ""))
}
