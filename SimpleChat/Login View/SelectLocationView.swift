//
//  SelectLocationView.swift
//  SimpleChat
//
//  Created by Reksi Gustio on 13/06/24.
//

import MapKit
import SwiftUI

struct SelectLocationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 75, longitudeDelta: 75))
    @State private var location = LocationCoordinate()
    var latitude: Double
    var longitude: Double
    var onSave: (LocationCoordinate) -> Void
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: [location]) { location in
                MapAnnotation(coordinate: location.coordinate) { }
            }
            .onAppear {
                withAnimation {
                    region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                }
            }
            .ignoresSafeArea()
            Image(systemName: "dot.scope")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 80, height: 80)
            
            VStack {
                Spacer()
                
                Button("Use this location") {
                    location.latitude = region.center.latitude
                    location.longitude = region.center.longitude
                    onSave(location)
                    dismiss()
                }
                .padding()
                .font(.headline.bold())
                .foregroundStyle(.white)
                .background(.black.opacity(0.75))
                .clipShape(.capsule)
                .padding(.vertical, 30)
            }
            
        }
    }
    
    init(latitude: Double, longitude: Double, onSave: @escaping (LocationCoordinate) -> Void) {
        self.latitude = latitude
        self.longitude = longitude
        self.onSave = onSave
    }
}

#Preview {
    SelectLocationView(latitude: 20.0, longitude: 20.0) { _ in }
}
