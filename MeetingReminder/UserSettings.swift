//
//  UserSettings.swift
//  MeetingReminder
//
//  Created by Mitsuoka Takahiro on 2025/12/27.
//

import Foundation
import Combine

class UserSettings: ObservableObject {
    @Published var notificationOffsetInSeconds: TimeInterval {
        didSet {
            UserDefaults.standard.set(notificationOffsetInSeconds, forKey: "notificationOffsetInSeconds")
        }
    }
    
    init() {
        self.notificationOffsetInSeconds = UserDefaults.standard.object(forKey: "notificationOffsetInSeconds") as? TimeInterval ?? 60
    }
}
