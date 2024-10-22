import SwiftUI
import CoreLocation


struct RaceInfoView: View {
    var startLineCoordinates: (rcBoat: CLLocationCoordinate2D, pin: CLLocationCoordinate2D)
    @EnvironmentObject var locationManager: LocationManager
    @State private var countdown: TimeInterval
    @State private var timerRunning: Bool = false
    @State private var timer: Timer?
    public init(startLineCoordinates: (rcBoat: CLLocationCoordinate2D, pin: CLLocationCoordinate2D)) {
        self.startLineCoordinates = startLineCoordinates
        _countdown = State(initialValue: LocationManager.shared.timerDuration)

    }
    

    var body: some View {
        VStack(spacing: 20) {
            if let currentLocation = locationManager.currentLocation {
                if locationManager.speed > 0{
                    Text("SOG: \(locationManager.speed, specifier: "%.2f") knots")}
                else{
                    Text("SOG: 0 knots")}
                if locationManager.course >= 0{
                    Text("COG: \(locationManager.course, specifier: "%.2f")°")
                }
                else{
                    Text("COG: waiting for GPS data")
                }
                Text("Distance to Start Line: \(calculateDistanceToStartLine(from: currentLocation), specifier: "%.2f") meters")
                Text("Time to Start Line: \(calculateTimeToStartLine(from: currentLocation), specifier: "%.2f") seconds")

            } else {
                Text("Location data not available")
            }

            Text("Timer: \(formatTime(countdown))")
                .font(.largeTitle)
                .padding()

            if !timerRunning {
                Button("Start Timer") {
                    countdown = locationManager.timerDuration
                    startTimer()
                }
                .font(.headline)
                .frame(width: 200, height: 60)
                .background(Color.green)
                .cornerRadius(10)
                .foregroundColor(.white)
            } else {
                Button("Stop Timer") {
                    stopTimer()
                }
                .font(.headline)
                .frame(width: 200, height: 60)
                .background(Color.red)
                .cornerRadius(10)
                .foregroundColor(.white)
            }

            if !timerRunning && countdown < 300 {
                HStack(spacing: 20) {
                    Button("Resume Timer") {
                        startTimer()
                    }
                    .font(.headline)
                    .frame(width: 150, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)

                    Button("Reset Timer") {
                        resetTimer()
                    }
                    .font(.headline)
                    .frame(width: 150, height: 50)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                }
            }
        }
        .padding()
        .onAppear {
            locationManager.startUpdatingLocation()
        }
    }

    private func startTimer() {
        timerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                stopTimer()
            }
        }
    }

    private func stopTimer() {
        timerRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func resetTimer() {
        stopTimer()
        countdown = 300 // Reset do 5 minut
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func calculateDistanceToStartLine(from currentLocation: CLLocationCoordinate2D) -> CLLocationDistance {
        let rcBoatLocation = CLLocation(latitude: startLineCoordinates.rcBoat.latitude, longitude: startLineCoordinates.rcBoat.longitude)
        let pinLocation = CLLocation(latitude: startLineCoordinates.pin.latitude, longitude: startLineCoordinates.pin.longitude)
        let currentCLLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        let lineMidpoint = CLLocation(latitude: (rcBoatLocation.coordinate.latitude + pinLocation.coordinate.latitude) / 2,
                                      longitude: (rcBoatLocation.coordinate.longitude + pinLocation.coordinate.longitude) / 2)
        return currentCLLocation.distance(from: lineMidpoint)
    }
    
    private func calculateTimeToStartLine(from currentLocation: CLLocationCoordinate2D) -> Double {
        let distance = calculateDistanceToStartLine(from: currentLocation)
        let speedInMetersPerSecond = locationManager.speed * 0.514444 // Konwersja węzłów na m/s
        guard speedInMetersPerSecond > 0 else { return Double.infinity }
        return distance / speedInMetersPerSecond
    }
}


