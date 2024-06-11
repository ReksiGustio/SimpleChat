//
//  PhotoPreview.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 11/06/24.
//

import SwiftUI

struct PhotoPreview: View {
    @Environment(\.dismiss) var dismiss
    @State private var offset = CGSize.zero
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    let preview: PreviewPhoto
    let receiver: String
    let send: (Data) -> ()
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                preview.photo
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(max(1, min(3, currentZoom + totalZoom)))
                    .offset(offset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                offset = value.translation
                            }
                            .onEnded { _ in
                                withAnimation {
                                    offset = .zero
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation {
                            if totalZoom <= 1 {
                                totalZoom = 2
                                offset = .zero
                            } else {
                                totalZoom = 1
                                offset = .zero
                            }
                        }
                    }
                    .padding(40)
                
                Spacer()
                
                Button {
                    send(preview.data)
                    dismiss()
                } label: {
                    Label("Send to \(receiver)", systemImage: "paperplane")
                }
                .buttonStyle(BorderedProminentButtonStyle())
            }
            .navigationTitle("Preview photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .simultaneousGesture(
                MagnificationGesture()
                    .onChanged { value in
                        currentZoom = log(value)
                    }
                    .onEnded { _ in
                        let scale = currentZoom + totalZoom
                        totalZoom += currentZoom
                        if scale > 3 {
                            totalZoom = 3
                        }
                        currentZoom = 0
                    }
            )
        }
    }
    
    init(preview: PreviewPhoto, receiver: String, send: @escaping (Data) -> Void) {
        self.preview = preview
        self.receiver = receiver
        self.send = send
    }
    
}

#Preview {
    PhotoPreview(preview: PreviewPhoto.example, receiver: "Yanto") { _ in }
}
