//
//  LocationManager.swift
//  RaceAsisstant
//
//  Created by Jan Doniec on 28/10/2024.
//
import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var currentSpeed: CLLocationSpeed = 0.0
    @Published var currentCourse: CLLocationDirection = 0.0 // Dodane COG
    @Published var distanceToStartLine: CLLocationDistance = 0.0
    @Published var timeToStartLine: TimeInterval = 0.0

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func startUpdatingLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        currentSpeed = location.speed
        currentCourse = location.course // Aktualizacja COG
        // Uaktualnij distanceToStartLine oraz timeToStartLine tutaj, jeśli to konieczne
    }
}
