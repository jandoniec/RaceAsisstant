//
//  WatchMainView.swift
//  RaceAsisstant
//
//  Created by Jan Doniec on 28/10/2024.
//

import SwiftUI
import CoreLocation

struct WatchMainView: View {
    @StateObject private var locationManager = LocationManager()

    @State private var timerLength: TimeInterval = 300 // 5 minut
    @State private var remainingTime: TimeInterval = 300 // Pozostały czas
    @State private var isTimerRunning = false
    @State private var pinPosition: CLLocationCoordinate2D?
    @State private var rcPosition: CLLocationCoordinate2D?
    @State private var firstTurningMark: CLLocationCoordinate2D?
    @State private var isFalseStartEnabled = false
    @State private var marks: [CLLocationCoordinate2D] = [] // Tablica na znaki
    @StateObject private var workoutManager = WorkoutManager()


    var body: some View {
        TabView {
            // Widok timera
            TimerView(timerLength: $timerLength, remainingTime: $remainingTime, isTimerRunning: $isTimerRunning)
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }

            // Widok pozycji RC i Pin
            PositionView(locationManager: locationManager, pinPosition: $pinPosition, rcPosition: $rcPosition)
                .tabItem {
                    Label("Positions", systemImage: "mappin.and.ellipse")
                }

            // Widok dodawania znaków
            AddMarksView(locationManager: locationManager, marks: $marks, firstTurningMark: $firstTurningMark)
                .tabItem {
                    Label("Add Marks", systemImage: "location")
                }

            // Widok informacji wyścigowych
            RaceInfoView(
                locationManager: locationManager,
                pinPosition: $pinPosition,
                rcPosition: $rcPosition,
                firstTurningMark: $firstTurningMark,
                isFalseStartEnabled: $isFalseStartEnabled,
                remainingTime: $remainingTime
            )
            .tabItem {
                Label("Race Info", systemImage: "flag")
            }
            .onAppear {
                workoutManager.startWorkout() // Automatyczne rozpoczęcie sesji treningowej
            }
            .onDisappear {
                workoutManager.endWorkout() // Automatyczne zakończenie sesji, gdy aplikacja zostanie zamknięta
            }
        }
    }
}
