//
//  WorkoutManager.swift
//  RaceAsisstant
//
//  Created by Jan Doniec on 29/10/2024.
//

import HealthKit
import WatchKit

class WorkoutManager: NSObject, ObservableObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    var healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?

    func startWorkout() {
        // Konfiguracja sesji treningowej
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .sailing // Możesz zmienić na odpowiednią aktywność
        configuration.locationType = .outdoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
            
            session?.delegate = self
            builder?.delegate = self // Ustawienie delegata na self
            
            session?.startActivity(with: Date())
        } catch {
            print("Failed to start workout session: \(error)")
        }
    }

    func endWorkout() {
        session?.end()
    }

    // MARK: - HKWorkoutSessionDelegate

    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        // Obsługa zmiany stanu sesji, np. start, pauza, zakończenie
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session error: \(error)")
    }

    // MARK: - HKLiveWorkoutBuilderDelegate

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Implementacja dla zdarzeń kolekcji danych, jeśli potrzebna
    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf types: Set<HKSampleType>) {
        // Obsługa zebranych danych – w tym miejscu można przetwarzać dane, np. tętno lub lokalizację
    }
}
