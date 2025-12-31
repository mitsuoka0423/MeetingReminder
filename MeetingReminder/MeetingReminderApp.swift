//
//  MeetingReminderApp.swift
//  MeetingReminder
//
//  Created by Mitsuoka Takahiro on 2025/12/27.
//

import SwiftUI
import UserNotifications

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
        
        // 起動通知を表示
        showLaunchNotification()
    }

    private func showLaunchNotification() {
        let center = UNUserNotificationCenter.current()
        
        // 1. 通知の許可をリクエスト
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("通知許可のリクエストエラー: \(error.localizedDescription)")
                return
            }
            
            guard granted else {
                print("通知が許可されませんでした。")
                return
            }
            
            // 2. 通知内容を作成
            let content = UNMutableNotificationContent()
            content.title = "しっかリマインダー"
            content.body = "起動しました。メニューバーで待機しています。"
            content.sound = .default
            
            // 3. 通知リクエストを作成（即時実行）
            // identifierを固定することで、万が一複数回呼ばれても通知が重複しないようにする
            let request = UNNotificationRequest(identifier: "app-launch-notification", content: content, trigger: nil)
            
            // 4. 通知をシステムに追加
            center.add(request) { error in
                if let error = error {
                    print("起動通知の追加に失敗: \(error.localizedDescription)")
                } else {
                    print("起動通知をスケジュールしました。")
                }
            }
        }
    }

    var body: some Scene {
        MenuBarExtra("しっかリマインダー", systemImage: "calendar.badge.clock") {
            // ContentViewに各種サービスを渡す
            ContentView()
                .environmentObject(calendarService)
                .environmentObject(overlayWindowManager) // OverlayWindowManagerを渡す
                .environmentObject(userSettings)
        }
        
        // 設定画面を追加
        Settings {
            SettingsView()
                .environmentObject(userSettings)
        }
        
        #if DEBUG
        Window("デバッグツール", id: "debug-window") {
            DebugView()
                .environmentObject(overlayWindowManager)
        }
        .defaultSize(width: 350, height: 450)
        #endif
    }
}