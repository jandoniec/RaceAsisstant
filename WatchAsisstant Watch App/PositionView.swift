//
//  PositionView.swift
//  RaceAsisstant
//
//  Created by Jan Doniec on 28/10/2024.
//

import SwiftUI
import CoreLocation
import Foundation

struct PositionView: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var pinPosition: CLLocationCoordinate2D?
    @Binding var rcPosition: CLLocationCoordinate2D?

    var body: some View {
        VStack {
            if let currentLocation = locationManager.currentLocation {
                Text("Current Location: \(formatCoordinate(currentLocation.coordinate.latitude, isLatitude: true)), \(formatCoordinate(currentLocation.coordinate.longitude, isLatitude: false))")
                    .font(.headline)

                Button("Set RC Position") {
                    rcPosition = currentLocation.coordinate
                }
                
                Button("Set Pin Position") {
                    pinPosition = currentLocation.coordinate
                }


            } else {
                Text("Waiting for GPS...")
            }

            // Wyświetlanie współrzędnych RC, jeśli są dostępne
            if let rc = rcPosition {
                Text("RC Position: \(formatCoordinate(rc.latitude, isLatitude: true)), \(formatCoordinate(rc.longitude, isLatitude: false))")
                    .font(.headline)
            }

            // Wyświetlanie współrzędnych Pin, jeśli są dostępne
            if let pin = pinPosition {
                Text("Pin Position: \(formatCoordinate(pin.latitude, isLatitude: true)), \(formatCoordinate(pin.longitude, isLatitude: false))")
                    .font(.headline)
            }
        }
        .onAppear {
            locationManager.startUpdatingLocation()
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
    }

    func formatCoordinate(_ coordinate: CLLocationDegrees, isLatitude: Bool) -> String {
        let degrees = Int(coordinate)
        let minutes = Int((coordinate - Double(degrees)) * 60)
        let seconds = Int((((coordinate - Double(degrees)) * 60) - Double(minutes)) * 60)
        
        let direction: String
        if isLatitude {
            direction = coordinate >= 0 ? "N" : "S"
        } else {
            direction = coordinate >= 0 ? "E" : "W"
        }

        return "\(abs(degrees))° \(abs(minutes))' \(abs(seconds))\" \(direction)"
    }
}
