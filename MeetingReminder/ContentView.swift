//
//  ContentView.swift
//  MeetingReminder
//
//  Created by Mitsuoka Takahiro on 2025/12/27.
//

import SwiftUI
import EventKit

struct ContentView: View {
    @EnvironmentObject private var calendarService: CalendarService
    @EnvironmentObject private var overlayWindowManager: OverlayWindowManager
    @Environment(\.openSettings) private var openSettings // 設定画面を開くための環境変数
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            // --- ヘッダーエリア ---
            VStack(spacing: 4) {
                Text("しっかリマインダー")
                    .font(.headline)
                Text("今日の予定")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)

            Divider()

            // --- コンテンツエリア ---
            if calendarService.isLoading {
                Spacer()
                ProgressView()
                    .padding()
                Text("予定を読み込み中...")
                Spacer()
            } else if !calendarService.accessGranted {
                Spacer()
                Text("カレンダーへのアクセスが許可されていません。")
                    .padding()
                Button("設定を開く") {
                    // システム設定のカレンダーアクセス画面を開く
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") {
                        NSWorkspace.shared.open(url)
                    }
                }
                Spacer()
            } else if calendarService.events.isEmpty {
                Spacer()
                Text("今日の予定はありません。")
                    .padding()
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(calendarService.events, id: \.eventIdentifier) { event in
                            if let title = event.title, !title.isEmpty {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(title)
                                            .fontWeight(.bold)
                                        Text("\(event.startDate.formatted(date: .omitted, time: .shortened)) - \(event.endDate.formatted(date: .omitted, time: .shortened))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // URLが見つかった場合のみ参加ボタンを表示
                                    if let url = MeetingURLFinder.find(in: event) {
                                        Button("参加") {
                                            NSWorkspace.shared.open(url)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                                
                                Divider()
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            // 設定ボタンを追加
            Button("設定...") {
                openSettings()
            }
            .padding(.vertical, 8)

            #if DEBUG
            Button("デバッグ...") {
                openWindow(id: "debug-window")
            }
            .padding(.vertical, 8)
            #endif

            Button("終了") {
                NSApplication.shared.terminate(nil)
            }
            .padding(.vertical, 8)

        }
        .frame(width: 320, height: 400) // ボタン追加のため少し幅を広げる
        .onAppear {
            calendarService.requestAccess()
        }
    }
}

#Preview {
    // プレビューが動作するように、モックのCalendarServiceとUserSettingsを渡す
    ContentView()
        .environmentObject(CalendarService(userSettings: UserSettings()))
        .environmentObject(OverlayWindowManager(calendarService: CalendarService(userSettings: UserSettings())))
        .environmentObject(UserSettings())
}
