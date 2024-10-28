import SwiftUI

struct RaceSettingsView: View {
    @ObservedObject var locationManager: LocationManager
    @State private var timerMinutes: Int = 5
    @State private var timerSeconds: Int = 0
    @State private var showPicker: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Toggle("Enable False Start Detector", isOn: $locationManager.isFalseStartDetectorEnabled)
                .padding()

            Button("Set Timer Duration") {
                showPicker.toggle()
            }
            .font(.headline)
            .frame(width: 200, height: 60)
            .background(Color.blue)
            .cornerRadius(10)
            .foregroundColor(.white)
            
            if showPicker {
                VStack(spacing: 20) {
                    HStack {
                        Text("Timer Duration:")
                        Spacer()
                        Picker("Minutes", selection: $timerMinutes) {
                            ForEach(0..<60) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 100)
                        
                        Picker("Seconds", selection: $timerSeconds) {
                            ForEach(0..<60) { second in
                                Text("\(second) sec").tag(second)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 100)
                    }
                    .padding()
                    
                    Button("Done") {
                        showPicker.toggle()
                        let newDuration = TimeInterval(timerMinutes * 60 + timerSeconds)
                        locationManager.updateTimerDuration(newDuration: newDuration)
                    }
                    .font(.headline)
                    .frame(width: 200, height: 60)
                    .background(Color.green)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                }
            }
        }
        .padding()
    }
}
