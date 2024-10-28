//
//  TimerView.swift
//  RaceAsisstant
//
//  Created by Jan Doniec on 28/10/2024.
//


import SwiftUI

struct TimerView: View {
    @Binding var timerLength: TimeInterval
    @Binding var remainingTime: TimeInterval
    @Binding var isTimerRunning: Bool
    @State private var timer: Timer? = nil // Opcjonalna zmienna dla timera

    var body: some View {
        VStack {
            // Wyświetlanie timera w formacie MM:SS
            Text("Timer: \(formatTime(remainingTime))")
                .font(.headline)

            // Slider do ustawiania długości timera
            Slider(value: $timerLength, in: 60...600, step: 1) {
                Text("Timer Length")
            }
            .onChange(of: timerLength) { newValue in
                if !isTimerRunning {
                    remainingTime = newValue // Aktualizacja remainingTime przy zmianie timerLength
                }
            }
            .padding()

            HStack {
                Button("Start") {
                    startTimer()
                }
                .disabled(isTimerRunning)

                Button("Stop") {
                    stopTimer()
                }
                .disabled(!isTimerRunning)

                Button("Reset") {
                    resetTimer()
                }
            }
        }
        .onAppear {
            remainingTime = timerLength // Ustawienie remainingTime na 5 minut przy uruchomieniu
        }
    }

    func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                stopTimer()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate() // Zatrzymanie timera
        timer = nil // Ustawienie na nil, aby można było ponownie uruchomić
        isTimerRunning = false
    }

    func resetTimer() {
        stopTimer()
        remainingTime = timerLength // Reset do ustawionej długości timera
    }

    // Funkcja do formatowania czasu jako MM:SS
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
