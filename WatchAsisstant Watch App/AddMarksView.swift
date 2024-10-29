//
//  AddMarksView.swift
//  RaceAsisstant
//
//  Created by Jan Doniec on 28/10/2024.
//


import SwiftUI
import CoreLocation
import Foundation

struct AddMarksView: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var marks: [CLLocationCoordinate2D]
    @Binding var firstTurningMark: CLLocationCoordinate2D?

    var body: some View {
        VStack {
            if let currentLocation = locationManager.currentLocation {
                Text("Current Location: \(formatCoordinate(currentLocation.coordinate.latitude, isLatitude: true)), \(formatCoordinate(currentLocation.coordinate.longitude, isLatitude: false))")
                    .font(.headline)

                Button("Add Mark") {
                    addMark(at: currentLocation.coordinate)
                }

                if firstTurningMark == nil {
                    Button("Set as First Turning Mark") {
                        firstTurningMark = currentLocation.coordinate
                    }
                } else {
                    Text("First Turning Mark: \(formatCoordinate(firstTurningMark!.latitude, isLatitude: true)), \(formatCoordinate(firstTurningMark!.longitude, isLatitude: false))")
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
