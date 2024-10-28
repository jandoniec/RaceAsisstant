import SwiftUI
import CoreLocation

struct MarkStartLineView: View {
    @Binding var startLineCoordinates: (rcBoat: CLLocationCoordinate2D, pin: CLLocationCoordinate2D)
    @State private var rcLocationMessage: String = ""
    @State private var pinLocationMessage: String = ""

      @ObservedObject var locationManager: LocationManager  // Zmiana z EnvironmentObject na ObservedObject

    var body: some View {
        VStack(spacing: 20) {
            if !rcLocationMessage.isEmpty {
                Text(rcLocationMessage)
                    .foregroundColor(.red)
            }
            Button("Mark RC") {
                if let currentLocation = locationManager.currentLocation {
                    startLineCoordinates.rcBoat = currentLocation
                    rcLocationMessage = convertToDMS(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                } else {
                    rcLocationMessage = "Location set failed"
                }
            }
            .font(.headline)
            .frame(width: 200, height: 60)
            .background(Color(.systemGray4))
            .cornerRadius(10)
            .foregroundColor(.black)

            if !pinLocationMessage.isEmpty {
                Text(pinLocationMessage)
                    .foregroundColor(.red)
            }
            Button("Mark Pin") {
                if let currentLocation = locationManager.currentLocation {
                    startLineCoordinates.pin = currentLocation
                    pinLocationMessage = convertToDMS(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                } else {
                    pinLocationMessage = "Location set failed"
                }
            }
            .font(.headline)
            .frame(width: 200, height: 60)
            .background(Color(.systemGray4))
            .cornerRadius(10)
            .foregroundColor(.black)

            NavigationLink(destination: RaceInfoView(
                startLineCoordinates: startLineCoordinates,
                locationManager: locationManager
            )) {
                Text("Done")
            }
                            .font(.headline)
            .frame(width: 200, height: 60)
            .background(Color(.systemGray4))
            .cornerRadius(10)
            .foregroundColor(.black)
        }
        .padding()
    }

    private func convertToDMS(latitude: Double, longitude: Double) -> String {
        func dmsString(from coordinate: Double, isLatitude: Bool) -> String {
            let degrees = Int(coordinate)
            let minutesDecimal = abs(coordinate - Double(degrees)) * 60
            let minutes = Int(minutesDecimal)
            let seconds = (minutesDecimal - Double(minutes)) * 60
            let direction = isLatitude ? (coordinate >= 0 ? "N" : "S") : (coordinate >= 0 ? "E" : "W")
            return String(format: "%d° %d' %.2f\" %@", abs(degrees), minutes, seconds, direction)
        }

        let latitudeString = dmsString(from: latitude, isLatitude: true)
        let longitudeString = dmsString(from: longitude, isLatitude: false)
        return "Pin coordinates: \(latitudeString), \(longitudeString)"
    }
}
