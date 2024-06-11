//
//  ImageView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 11/06/24.
//

import SwiftUI

struct ImageView: View {
    @Environment(\.dismiss) var dismiss
    @State private var offset = CGSize.zero
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    let image: Image
    
    var body: some View {
        NavigationStack {
            VStack {
                image
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
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Dismiss") { dismiss() }
                        }
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
            ) // end of vstack
            .navigationTitle("Image preview")
            .navigationBarTitleDisplayMode(.inline)
        } // end of navstack
    } // end of body
} // end of imageview

#Preview {
    ImageView(image: Image(systemName: "cross.circle"))
}
