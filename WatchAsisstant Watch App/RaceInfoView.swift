//
//  RaceInfoView.swift
//  RaceAsisstant
//
//  Created by Jan Doniec on 28/10/2024.
//
import SwiftUI
import CoreLocation

struct RaceInfoView: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var pinPosition: CLLocationCoordinate2D?
    @Binding var rcPosition: CLLocationCoordinate2D?
    @Binding var firstTurningMark: CLLocationCoordinate2D?
    @Binding var isFalseStartEnabled: Bool
    @Binding var remainingTime: TimeInterval

    var body: some View {
        VStack(spacing: 10) {
            // Wyświetlanie timera w formacie MM:SS
            Text("Timer: \(formatTime(remainingTime))")
                .font(.headline)

            // Wyświetlanie prędkości
            Text("Speed: \(String(format: "%.2f", locationManager.currentSpeed / 0.51444)) knots")
                .font(.headline)

            // Wyświetlanie falstartu
            if isFalseStartEnabled && checkForFalseStart() {
                Text("False Start!")
                    .foregroundColor(.red)
                    .font(.headline)
            } else {
                Text("Clear Start")
                    .foregroundColor(.green)
                    .font(.headline)
            }
        }
        .padding()
        .onAppear {
            locationManager.startUpdatingLocation()
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
    }

    // Funkcja formatTime formatuje czas jako MM:SS
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func checkForFalseStart() -> Bool {
        guard let rc = rcPosition, let pin = pinPosition, let firstMark = firstTurningMark, let currentLocation = locationManager.currentLocation else {
            return false
        }
        
        return isPointInTriangle(
            p: currentLocation.coordinate,
            a: rc,
            b: pin,
            c: firstMark
        )
    }

    func isPointInTriangle(p: CLLocationCoordinate2D, a: CLLocationCoordinate2D, b: CLLocationCoordinate2D, c: CLLocationCoordinate2D) -> Bool {
        let areaOrig = triangleArea(a, b, c)
        let area1 = triangleArea(p, b, c)
        let area2 = triangleArea(a, p, c)
        let area3 = triangleArea(a, b, p)
        
        return abs(areaOrig - (area1 + area2 + area3)) < 0.01
    }

    func triangleArea(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D, _ c: CLLocationCoordinate2D) -> Double {
        let x1 = a.latitude, y1 = a.longitude
        let x2 = b.latitude, y2 = b.longitude
        let x3 = c.latitude, y3 = c.longitude
        return abs((x1*(y2 - y3) + x2*(y3 - y1) + x3*(y1 - y2)) / 2.0)
    }
}
