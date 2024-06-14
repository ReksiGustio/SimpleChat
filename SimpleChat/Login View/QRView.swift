//
//  QRView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 14/06/24.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

struct QRView: View {
    let userName: String
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        VStack {
            
            Text("Show this QR Code to your friends in order let them add your contact.")
                .multilineTextAlignment(.center)
                .font(.headline)
                .padding()
            
            Image(uiImage: generateQRCode(from: userName))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 280, height: 280)
                .padding(25)
                .background(.secondary.opacity(0.3))
                .clipShape(.rect(cornerRadius: 20))
            
            Text("Username: \(userName)")
                .font(.headline)
                .padding()
        }
        .navigationTitle("Share QR Code")
    }
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
}

#Preview {
    QRView(userName: "dummy")
}
