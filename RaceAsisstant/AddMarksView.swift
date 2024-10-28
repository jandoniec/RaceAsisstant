//
//  AddMarksView.swift
//  RaceAsisstant
//
//  Created by Jan Doniec on 28/10/2024.
//

import SwiftUI
import CoreLocation

struct AddMarksView: View {
    struct Mark: Codable, Identifiable {
        let id = UUID()
        var name: String
        var latitude: String
        var longitude: String
        var isFirstTurningMark: Bool
    }

    @State private var marks: [Mark] = []
    @State private var showPicker: Bool = false
    @State private var markName: String = ""
    @State private var isFirstTurningMark: Bool = false
    @State private var selectedLatitudeDegrees: Int = 0
    @State private var selectedLatitudeMinutes: Int = 0
    @State private var selectedLatitudeSeconds: Double = 0.0
    @State private var selectedLatitudeDirection: String = "N"
    @State private var selectedLongitudeDegrees: Int = 0
    @State private var selectedLongitudeMinutes: Int = 0
    @State private var selectedLongitudeSeconds: Double = 0.0
    @State private var selectedLongitudeDirection: String = "E"
    @State private var errorMessage: String = ""
    @ObservedObject var locationManager: LocationManager  // Zmiana z EnvironmentObject na ObservedObject

    var body: some View {
        VStack(spacing: 20) {
            Text("Add Marks View")
                .font(.largeTitle)
                .padding()

            Button(action: {
                showPicker.toggle()
            }) {
                Image(systemName: "plus.circle")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
            }
            .sheet(isPresented: $showPicker) {
                VStack(spacing: 20) {
                    Button("Add Mark from Current Position") {
                        if let currentLocation = locationManager.currentLocation {
                            setPickerValues(from: currentLocation)
                        } else {
                            errorMessage = "Failed to get current location."
                        }
                    }
                    .font(.headline)
                    .frame(width: 200, height: 60)
                    .background(Color.orange)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .padding()

                    Text("Add Mark")
                        .font(.headline)
                        .padding()

                    TextField("Mark Name", text: $markName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Toggle("Is First Turning Mark", isOn: $isFirstTurningMark)
                        .padding()
                        .onChange(of: isFirstTurningMark) { newValue in
                            if newValue {
                                marks.indices.forEach { marks[$0].isFirstTurningMark = false }
                            }
                        }

                    // Kod wyboru dla współrzędnych szerokości i długości geograficznej...

                    Button("Add Mark") {
                        let latitude = "\(selectedLatitudeDegrees)° \(selectedLatitudeMinutes)' \(selectedLatitudeSeconds)\" \(selectedLatitudeDirection)"
                        let longitude = "\(selectedLongitudeDegrees)° \(selectedLongitudeMinutes)' \(selectedLongitudeSeconds)\" \(selectedLongitudeDirection)"
                        let newMark = Mark(name: markName, latitude: latitude, longitude: longitude, isFirstTurningMark: isFirstTurningMark)
                        marks.append(newMark)
                        saveMarks()
                        showPicker = false
                        errorMessage = ""
                    }
                    .font(.headline)
                    .frame(width: 200, height: 60)
                    .background(Color.green)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                }
                .padding()
            }

            List {
                ForEach(marks) { mark in
                    DisclosureGroup(mark.name) {
                        VStack(alignment: .leading) {
                            Text("Latitude: \(mark.latitude)")
                            Text("Longitude: \(mark.longitude)")
                            Text("Is First Turning Mark: \(mark.isFirstTurningMark ? "Yes" : "No")")
                        }
                        .padding()
                    }
                }
                .onDelete { indexSet in
                    marks.remove(atOffsets: indexSet)
                    saveMarks()
                }
            }
        }
        .padding()
        .onAppear {
            loadMarks()
        }
    }

    private func setPickerValues(from location: CLLocationCoordinate2D) {
        let latDMS = convertToDMS(latitude: location.latitude, isLatitude: true)
        let lonDMS = convertToDMS(latitude: location.longitude, isLatitude: false)

        selectedLatitudeDegrees = latDMS.degrees
        selectedLatitudeMinutes = latDMS.minutes
        selectedLatitudeSeconds = latDMS.seconds
        selectedLatitudeDirection = latDMS.direction

        selectedLongitudeDegrees = lonDMS.degrees
        selectedLongitudeMinutes = lonDMS.minutes
        selectedLongitudeSeconds = lonDMS.seconds
        selectedLongitudeDirection = lonDMS.direction
    }

    private func saveMarks() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(marks) {
            UserDefaults.standard.set(encoded, forKey: "savedMarks")
        }
    }

    private func loadMarks() {
        if let savedMarks = UserDefaults.standard.object(forKey: "savedMarks") as? Data {
            let decoder = JSONDecoder()
            if let loadedMarks = try? decoder.decode([Mark].self, from: savedMarks) {
                marks = loadedMarks
            }
        }
    }

    private func convertToDMS(latitude: Double, isLatitude: Bool) -> (degrees: Int, minutes: Int, seconds: Double, direction: String) {
        let degrees = Int(latitude)
        let minutesDecimal = abs(latitude - Double(degrees)) * 60
        let minutes = Int(minutesDecimal)
        let seconds = (minutesDecimal - Double(minutes)) * 60
        let direction = isLatitude ? (latitude >= 0 ? "N" : "S") : (latitude >= 0 ? "E" : "W")
        return (abs(degrees), minutes, seconds, direction)
    }
}
