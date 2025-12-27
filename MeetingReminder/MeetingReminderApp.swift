//
//  MeetingReminderApp.swift
//  MeetingReminder
//
//  Created by Mitsuoka Takahiro on 2025/12/27.
//

import SwiftUI

@main
struct MeetingReminderApp: App {
    // アプリのライフサイクル全体で共有されるサービスとマネージャーを初期化
    @StateObject private var calendarService: CalendarService
    @StateObject private var overlayWindowManager: OverlayWindowManager
    @StateObject private var userSettings = UserSettings() // UserSettingsを追加

    init() {
        // UserSettingsを先に初期化
        let settings = UserSettings()
        _userSettings = StateObject(wrappedValue: settings)

        // CalendarServiceを初期化し、UserSettingsを渡す
        let service = CalendarService(userSettings: settings)
        _calendarService = StateObject(wrappedValue: service)
        
        // OverlayWindowManagerを初期化し、CalendarServiceを渡す
        _overlayWindowManager = StateObject(wrappedValue: OverlayWindowManager(calendarService: service))
    }

    var body: some Scene {
        MenuBarExtra("しっかリマインダー", systemImage: "calendar.badge.clock") {
            // ContentViewにCalendarServiceとUserSettingsを渡す
            ContentView()
                .environmentObject(calendarService)
                .environmentObject(userSettings) // UserSettingsを渡す
        }
        
        // 設定画面を追加
        Settings {
            SettingsView()
                .environmentObject(userSettings) // SettingsViewにUserSettingsを渡す
        }
    }
}