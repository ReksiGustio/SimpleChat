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
                    Text(message.text)
                        .padding(.trailing, 12)
                    
                    Text(convertDate(message.date), format: .dateTime.month().day().hour().minute())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                } // end of vstack
                .padding(10)
                .background(.primary.opacity(0.05))
                .clipShape(.rect(cornerRadius: 15))
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = message.text
                    } label: {
                        Label("Copy text to clipboard", systemImage: "doc.on.doc")
                    }
                }
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
                    Text(message.text)
                        .padding(.leading, 12)
                    
                    Text(convertDate(message.date), format: .dateTime.month().day().hour().minute())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
  
                } // end of vstack
                .padding(10)
                .background(.blue.opacity(0.5))
                .clipShape(.rect(cornerRadius: 15))
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = message.text
                    } label: {
                        Label("Copy text to clipboard", systemImage: "doc.on.doc")
                    }
                }
                .padding(.bottom, 10)
                
            } // end of hstack
        }
    } // end of body
    
    func convertDate(_ text: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        return dateFormatter.date(from: text) ?? .now
    }
    
} // end of textview

#Preview {
    TextView(vm: ContentView.VM(), message: Message(id: 0, userRelated: "", text: "P", image: nil, date: ""))
}
