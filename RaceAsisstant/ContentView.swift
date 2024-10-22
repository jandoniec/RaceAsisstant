import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var startLineCoordinates = (rcBoat: CLLocationCoordinate2D(), pin: CLLocationCoordinate2D())

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink(destination: MarkStartLineView(startLineCoordinates: $startLineCoordinates)
                                .environmentObject(locationManager)) {
                    Text("Mark Starting Line Position")
                }
                NavigationLink(destination: RaceSettingsView()) {
                    Text("Race Settings")
                }
            }
            .padding()
        }

        .environmentObject(locationManager) // Przekazanie environmentObject
    }
}
