//
//  BackgroundSettingView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 12/06/24.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import SwiftUI

struct BackgroundSettingView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ContentView.VM
    @State private var brightness = 0.0
    @State private var brightnessSlider = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var processedImage: UIImage?
    @State private var currentFilter: CIFilter = CIFilter.exposureAdjust()
    let context = CIContext()
    var backgroundImage: Image? {
        Image(uiImage: UIImage(data: vm.messageBackground) ?? UIImage())
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                
                if brightnessSlider {
                    HStack {
                        Picker("select value", selection: $brightness) {
                            Text("Dark").tag(-5.0)
                            Text("-").tag(-4.0)
                            Text("-").tag(-3.0)
                            Text("-").tag(-2.0)
                            Text("-").tag(-1.0)
                            Text("Light").tag(0.0)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: brightness) { _ in applyProcessing() }
                    } //end of hstack
                    .padding()
                }
                
                ZStack {
                    PhotosPicker(selection: $pickerItem) {
                        if processedImage != nil {
                            selectedImage?
                                .resizable()
                        } else {
                            ZStack {
                                Color.secondary
                                
                                if !vm.messageBackground.isEmpty {
                                    if let backgroundImage {
                                        backgroundImage
                                            .resizable()
                                    }
                                }
                            } // end of zstack
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onChange(of: pickerItem) { _ in loadImage() }
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Text("Tap the area to change picture")
                                .padding(10)
                                .background(.primary.opacity(0.1))
                                .background(Color(uiColor: .systemBackground))
                                .clipShape(.rect(cornerRadius: 15))
                                .padding(.bottom, 10)
                            
                            Spacer()
                            
                            Rectangle()
                                .fill(.clear)
                                .frame(maxWidth: 10, maxHeight: 40)
                        } // end of hstack
                        .padding()
                        
                        HStack {
                            Rectangle()
                                .fill(.clear)
                                .frame(maxWidth: 10, maxHeight: 40)
                            
                            Spacer()
                            
                            Text("After selecting the picture, you can adjust the brightness below.")
                                .padding(10)
                                .background(.blue.opacity(0.8))
                                .background(.white)
                                .clipShape(.rect(cornerRadius: 15))
                                .padding(.bottom, 10)
                            
                        } // end of hstack
                        .padding()
                        
                        HStack {
                            Text("The background picture will be streched depending on your device size, be careful.")
                                .padding(10)
                                .background(.primary.opacity(0.1))
                                .background(Color(uiColor: .systemBackground))
                                .clipShape(.rect(cornerRadius: 15))
                                .padding(.bottom, 10)
                            
                            Spacer()
                            
                            Rectangle()
                                .fill(.clear)
                                .frame(maxWidth: 10, maxHeight: 40)
                        } // end of hstack
                        .padding()
                        
                        Spacer()
                    } // end of vstack
                } // end of zstack
                .frame(width: proxy.size.width * 0.8)
                .clipped()
                .frame(width: proxy.size.width, height: proxy.size.height * 0.6)
                
                if processedImage != nil || !vm.messageBackground.isEmpty {
                    Button("Remove background") {
                        vm.messageBackground = Data()
                        processedImage = nil
                        selectedImage = nil
                        pickerItem = nil
                        brightnessSlider = false
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                }
                
                Spacer()
                
                Button("Save changes") {
                    if processedImage != nil {
                        vm.messageBackground = processedImage?.preparingThumbnail(of: CGSize(width: 1024, height: 1024))?.jpegData(compressionQuality: 1.0) ?? Data()
                    } else {
                        vm.messageBackground = Data()
                    }
                    dismiss()
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .padding()
            } // end of vstack
        } // end of geo reader
        .navigationTitle("Chat Background")
    } // end of body
    
    func loadImage() {
        Task {
            brightness = 0.0
            
            guard let imageData = try await pickerItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }
            
            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            
            applyProcessing()
        }
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputEVKey) {
            currentFilter.setValue(brightness, forKey: kCIInputEVKey)
            brightnessSlider = true
        } else {
            brightnessSlider = false
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            selectedImage = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
}

#Preview {
    BackgroundSettingView(vm: ContentView.VM())
}
