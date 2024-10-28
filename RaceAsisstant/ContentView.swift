import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var startLineCoordinates = (rcBoat: CLLocationCoordinate2D(), pin: CLLocationCoordinate2D())
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink(destination: MarkStartLineView(startLineCoordinates: $startLineCoordinates, locationManager: locationManager)) {
                    Text("Mark Starting Line Position")
                }
                .font(.headline)
                .frame(width: 200, height: 60)
                .background(Color(.systemGray4))
                .cornerRadius(10)
                .foregroundColor(.black)
                
                NavigationLink(destination: RaceSettingsView(locationManager: locationManager)) {
                    Text("Race Settings")
                }
                .font(.headline)
                .frame(width: 200, height: 60)
                .background(Color(.systemGray4))
                .cornerRadius(10)
                .foregroundColor(.black)
                
                NavigationLink(destination: AddMarksView(locationManager: locationManager)) {
                    Text("Add Turning Marks")
                }
                .font(.headline)
                .frame(width: 200, height: 60)
                .background(Color(.systemGray4))
                .cornerRadius(10)
                .foregroundColor(.black)
            }
            .padding()
        }
    }
}
