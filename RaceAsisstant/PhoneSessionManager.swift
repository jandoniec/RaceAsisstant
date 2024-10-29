//
//  PhoneSessionManager.swift
//  RaceAsisstant
//
//  Created by Jan Doniec on 28/10/2024.
//


import WatchConnectivity

class PhoneSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = PhoneSessionManager()
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    // Wymagana metoda do aktywacji sesji
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Activation failed with error: \(error.localizedDescription)")
        } else {
            print("Activation completed with state: \(activationState.rawValue)")
        }
    }

    // Opcjonalna metoda do obsługi przełączania urządzeń (np. w przypadku parowania nowych zegarków)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("Session deactivated")
        // Ponowna aktywacja sesji na nowym urządzeniu, jeśli zachodzi taka potrzeba
        WCSession.default.activate()
    }

    // Opcjonalna metoda do odbierania wiadomości, jeśli komunikujesz się z zegarkiem
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message: \(message)")
        // Możesz dodać tutaj kod obsługi wiadomości, jeśli to konieczne
    }
}
