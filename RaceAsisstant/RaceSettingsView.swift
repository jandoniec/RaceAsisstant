import SwiftUI
struct RaceSettingsView: View {
    @State private var timerMinutes: Int = 5
    @State private var timerSeconds: Int = 0
    @State private var showPicker: Bool = false
    @EnvironmentObject var locationManager: LocationManager


    var body: some View {
        VStack(spacing: 20) {
            Text("Race Timer Settings")
                .font(.largeTitle)
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
                        Text("Timer Duration: ")
                        Spacer()
                        HStack {
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
                    }
                    .padding()

                    Button("Done") {
                        showPicker.toggle()
                        locationManager.timerDuration = TimeInterval(timerMinutes * 60 + timerSeconds)

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
