import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    
    @Published var timerDuration: TimeInterval = 300
    @Published var timerSetting: TimeInterval = 300
    @Published var isFalseStartDetectorEnabled: Bool = false // Właściwość do kontroli falstartu
    private(set) var currentLocation: CLLocationCoordinate2D?
    private(set) var speed: CLLocationSpeed = 0.0
    private(set) var course: CLLocationDirection = 0.0
    @Published private var marks: [AddMarksView.Mark] = [] // Lista znaków zwrotnych

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        startUpdatingLocation()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        print("Location updated")
    }

    func fetchCurrentData() -> (location: CLLocationCoordinate2D?, speed: CLLocationSpeed, course: CLLocationDirection) {
        return (currentLocation, speed, course)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
            speed = location.speed * 1.94384
            course = location.course
        }
    }
    
    func startCountdownTimer() {
        timerDuration = timerSetting
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timerDuration > 0 {
                self.timerDuration -= 1
            } else {
                self.stopTimer()
            }
        }
    }
    
    func stopTimer() {
        timerDuration = 0
    }

    func updateTimerDuration(newDuration: TimeInterval) {
        timerSetting = newDuration
        print("Timer setting updated to \(timerSetting) seconds")
    }

    func getFirstTurningMark() -> CLLocationCoordinate2D? {
        guard let firstMark = marks.first(where: { $0.isFirstTurningMark }) else {
            return nil
        }
        return convertStringToCoordinate(latitude: firstMark.latitude, longitude: firstMark.longitude)
    }

    private func convertStringToCoordinate(latitude: String, longitude: String) -> CLLocationCoordinate2D? {
        guard let lat = convertDMSToDecimal(dmsString: latitude),
              let lon = convertDMSToDecimal(dmsString: longitude) else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    private func convertDMSToDecimal(dmsString: String) -> Double? {
        let components = dmsString.split(separator: " ")
        guard components.count == 4,
              let degrees = Double(components[0].dropLast(1)),
              let minutes = Double(components[1].dropLast(1)),
              let seconds = Double(components[2].dropLast(1)) else { return nil }

        var decimal = degrees + minutes / 60 + seconds / 3600
        if components[3] == "S" || components[3] == "W" { decimal *= -1 }
        return decimal
    }
}
