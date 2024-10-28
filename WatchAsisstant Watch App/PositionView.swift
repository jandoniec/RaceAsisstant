//
//  PositionView.swift
//  RaceAsisstant
//
//  Created by Jan Doniec on 28/10/2024.
//

import SwiftUI
import CoreLocation

struct PositionView: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var pinPosition: CLLocationCoordinate2D?
    @Binding var rcPosition: CLLocationCoordinate2D?

    var body: some View {
        VStack {
            if let currentLocation = locationManager.currentLocation {
                Text("Current Location: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
                    .font(.headline)

                Button("Set Pin Position") {
                    pinPosition = currentLocation.coordinate
                }

                Button("Set RC Position") {
                    rcPosition = currentLocation.coordinate
                }
            } else {
                Text("Waiting for GPS...")
            }

            if let pin = pinPosition {
                Text("Pin Position: \(pin.latitude), \(pin.longitude)")
            }

            if let rc = rcPosition {
                Text("RC Position: \(rc.latitude), \(rc.longitude)")
            }
        }
        .onAppear {
            locationManager.startUpdatingLocation()
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
    }
}
