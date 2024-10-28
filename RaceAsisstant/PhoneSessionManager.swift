//
//  PhoneSessionManager.swift
//  RaceAsisstant
//
//  Created by Jan Doniec on 28/10/2024.
//


import WatchConnectivity

class PhoneSessionManager: NSObject, WCSessionDelegate {
    static let shared = PhoneSessionManager()
    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Obsługa odebranej wiadomości
    }
}
