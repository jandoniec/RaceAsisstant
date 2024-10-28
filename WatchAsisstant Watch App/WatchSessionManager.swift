//
//  WatchSessionManager.swift
//  RaceAsisstant
//
//  Created by Jan Doniec on 28/10/2024.
//


import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionManager()
    @Published var receivedData: [String: Any] = [:]

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // Wymagana metoda protokołu WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Obsługa aktywacji sesji, jeśli to konieczne
        if let error = error {
            print("Activation failed with error: \(error.localizedDescription)")
        } else {
            print("Activation completed with state: \(activationState.rawValue)")
        }
    }

    // Opcjonalna metoda protokołu WCSessionDelegate do odbierania wiadomości
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.receivedData = message
        }
    }
}

