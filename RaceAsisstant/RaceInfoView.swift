import SwiftUI
import CoreLocation

struct RaceInfoView: View {
    var startLineCoordinates: (rcBoat: CLLocationCoordinate2D, pin: CLLocationCoordinate2D)
    @ObservedObject var locationManager: LocationManager
    @State private var timerRunning: Bool = false
    @State private var cachedLocation: CLLocationCoordinate2D?
    @State private var cachedSpeed: CLLocationSpeed = 0.0
    @State private var cachedCourse: CLLocationDirection = 0.0
    @State private var countdown: TimeInterval
    @State private var isOnFalseStart: Bool = false
    @State private var timer: Timer?  // Timer reference
    @State private var pausedTime: TimeInterval? // To store time remaining when paused

    init(startLineCoordinates: (rcBoat: CLLocationCoordinate2D, pin: CLLocationCoordinate2D), locationManager: LocationManager) {
        self.startLineCoordinates = startLineCoordinates
        self.locationManager = locationManager
        _countdown = State(initialValue: locationManager.timerSetting)
    }

    var body: some View {
        VStack(spacing: 20) {
            // Wybór obrazka na podstawie stanu
            Image(getStartLineImageName())
                .resizable()
                .aspectRatio(contentMode: .fit) // Zachowanie proporcji
                .frame(width: 200)              // Ustaw tylko szerokość
                .padding()

            if let location = cachedLocation {
                Text("SOG: \(cachedSpeed > 0 ? String(format: "%.2f knots", cachedSpeed) : "0 knots")")
                Text("COG: \(cachedCourse >= 0 ? String(format: "%.2f°", cachedCourse) : "waiting for GPS data")")
                Text("Distance to Start Line: \(String(format: "%.2f meters", calculateDistanceToStartLine(from: location)))")
                Text("Time to Start Line: \(String(format: "%.2f seconds", calculateTimeToStartLine(from: location)))")
                
                if locationManager.isFalseStartDetectorEnabled {
                    Text(isOnFalseStart ? "False Start!" : "All Clear")
                        .foregroundColor(isOnFalseStart ? .red : .green)
                }
            } else {
                Text("Location data not available")
            }
            Text("Timer: \(formatTime(countdown))")
                .font(.largeTitle)
                .padding()

            HStack(spacing: 20) {
                if !timerRunning && pausedTime == nil {
                    // Jeśli timer nie jest uruchomiony i nie jest zatrzymany, wyświetl "Start"
                    Button("Start") {
                        startTimer()
                    }
                    .font(.headline)
                    .frame(width: 100, height: 50)
                    .background(Color.green)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                } else if timerRunning {
                    // Jeśli timer jest uruchomiony, wyświetl "Stop"
                    Button("Stop") {
                        stopTimer()
                    }
                    .font(.headline)
                    .frame(width: 100, height: 50)
                    .background(Color.red)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                } else if !timerRunning && pausedTime != nil {
                    // Jeśli timer jest zatrzymany, wyświetl "Resume" i "Reset"
                    Button("Resume") {
                        resumeTimer()
                    }
                    .font(.headline)
                    .frame(width: 100, height: 50)
                    .background(Color.orange)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    
                    Button("Reset") {
                        resetTimer()
                    }
                    .font(.headline)
                    .frame(width: 100, height: 50)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                }
            }
        }
        .padding()
        .onAppear {
            locationManager.startUpdatingLocation()
            fetchAndCacheData()
            startDataFetchTimer()
            checkForFalseStart()
        }
    }

    // Funkcja, która wybiera odpowiednią wersję obrazka linii startu
    private func getStartLineImageName() -> String {
        if locationManager.isFalseStartDetectorEnabled {
            return isOnFalseStart ? "StartLine_Red" : "StartLine_Clear"
        } else {
            return "StartLine_Default"
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
        timer?.invalidate()
        timer = nil
        timerRunning = false
        pausedTime = countdown // Zapisz pozostały czas, aby można było go wznowić
    }

    private func resumeTimer() {
        guard let remainingTime = pausedTime else { return }
        countdown = remainingTime
        pausedTime = nil
        startTimer()
    }

    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        timerRunning = false
        countdown = locationManager.timerSetting
        pausedTime = nil
    }

    private func checkForFalseStart() {
        guard locationManager.isFalseStartDetectorEnabled, let firstMark = locationManager.getFirstTurningMark(), let yachtLocation = cachedLocation else { return }
        isOnFalseStart = isPointInsideTriangle(p: yachtLocation, a: startLineCoordinates.rcBoat, b: startLineCoordinates.pin, c: firstMark)
    }
    private func fetchAndCacheData() {
        let data = locationManager.fetchCurrentData()
        cachedLocation = data.location
        cachedSpeed = data.speed
        cachedCourse = data.course
    }

    private func startDataFetchTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            fetchAndCacheData()
        }
    }

    private func stopDataFetchTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // Funkcja pomocnicza do obliczenia obszaru trójkąta utworzonego przez trzy punkty
    func area(_ p1: CLLocationCoordinate2D, _ p2: CLLocationCoordinate2D, _ p3: CLLocationCoordinate2D) -> Double {
        return abs((p1.latitude * (p2.longitude - p3.longitude) +
                    p2.latitude * (p3.longitude - p1.longitude) +
                    p3.latitude * (p1.longitude - p2.longitude)) / 2.0)
    }

    // Funkcja sprawdzająca, czy punkt leży wewnątrz trójkąta
    func isPointInsideTriangle(p: CLLocationCoordinate2D, a: CLLocationCoordinate2D, b: CLLocationCoordinate2D, c: CLLocationCoordinate2D) -> Bool {
        let totalArea = area(a, b, c)
        let area1 = area(p, b, c)
        let area2 = area(a, p, c)
        let area3 = area(a, b, p)
        
        // Jeśli suma pól trójkątów utworzonych z punktami równa się całkowitemu obszarowi, punkt jest wewnątrz trójkąta
        return abs(totalArea - (area1 + area2 + area3)) < 1e-5
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
        let speedInMetersPerSecond = cachedSpeed * 0.514444
        guard speedInMetersPerSecond > 0 else { return Double.infinity }
        return distance / speedInMetersPerSecond
    }
}
