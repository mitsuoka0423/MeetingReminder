//
//  ContentView.swift
//  MeetingReminder
//
//  Created by Mitsuoka Takahiro on 2025/12/27.
//

import SwiftUI
import EventKit

struct ContentView: View {
    @StateObject private var calendarService = CalendarService()

    var body: some View {
        VStack(spacing: 0) {
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
                            VStack(alignment: .leading) {
                                Text(event.title)
                                    .fontWeight(.bold)
                                Text("\(event.startDate.formatted(date: .omitted, time: .shortened)) - \(event.endDate.formatted(date: .omitted, time: .shortened))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            
                            Divider()
                        }
                    }
                }
            }
            
            Divider()
            
            Button("終了") {
                NSApplication.shared.terminate(nil)
            }
            .padding(.vertical, 8)

        }
        .frame(width: 300, height: 400)
        .onAppear {
            calendarService.requestAccess()
        }
    }
}

#Preview {
    ContentView()
}
