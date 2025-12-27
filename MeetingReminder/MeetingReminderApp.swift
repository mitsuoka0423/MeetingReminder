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
    @StateObject private var calendarService = CalendarService()
    @StateObject private var overlayWindowManager: OverlayWindowManager

    init() {
        // CalendarServiceを先に初期化し、それをOverlayWindowManagerに渡す
        let service = CalendarService()
        _calendarService = StateObject(wrappedValue: service)
        _overlayWindowManager = StateObject(wrappedValue: OverlayWindowManager(calendarService: service))
    }

    var body: some Scene {
        MenuBarExtra("しっかリマインダー", systemImage: "calendar.badge.clock") {
            // ContentViewにCalendarServiceを渡す
            ContentView()
                .environmentObject(calendarService)
        }
    }
}
