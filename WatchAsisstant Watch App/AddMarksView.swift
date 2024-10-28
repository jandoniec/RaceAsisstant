//
//  AddMarksView.swift
//  RaceAsisstant
//
//  Created by Jan Doniec on 28/10/2024.
//


import SwiftUI
import CoreLocation

struct AddMarksView: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var marks: [CLLocationCoordinate2D]
    @Binding var firstTurningMark: CLLocationCoordinate2D?

    var body: some View {
        VStack {
            if let currentLocation = locationManager.currentLocation {
                Text("Current Location: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
                    .font(.headline)

                Button("Add Mark") {
                    addMark(at: currentLocation.coordinate)
                }

                if firstTurningMark == nil {
                    Button("Set as First Turning Mark") {
                        firstTurningMark = currentLocation.coordinate
                    }
                } else {
                    Text("First Turning Mark: \(firstTurningMark!.latitude), \(firstTurningMark!.longitude)")
                }
            } else {
                Text("Waiting for GPS...")
            }
        }
        .onAppear {
            locationManager.startUpdatingLocation()
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
    }

    func addMark(at coordinate: CLLocationCoordinate2D) {
        marks.append(coordinate)
    }
}
