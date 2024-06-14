//
//  QRScannerView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 14/06/24.
//

import SwiftUI
import VisionKit

struct QRScannerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var scannedText = ""
    var saveText: (String) -> ()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                QRScanner(result: $scannedText)
                
                if !scannedText.isEmpty {
                    Text(scannedText)
                        .padding()
                        .background(.black)
                        .foregroundColor(.white)
                        .padding(.bottom)
                        
                }
                
            } // end of zstack
            
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .onChange(of: scannedText) { _ in
                hapticTrigger()
                saveText(scannedText)
                dismiss()
            }
        }
    }
    
    init(saveText: @escaping (String) -> Void) {
        self.saveText = saveText
    }
    
    func hapticTrigger() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
}

#Preview {
    QRScannerView() { _ in }
}
