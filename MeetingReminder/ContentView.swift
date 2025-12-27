//
//  ContentView.swift
//  MeetingReminder
//
//  Created by Mitsuoka Takahiro on 2025/12/27.
//

import SwiftUI
import EventKit

struct ContentView: View {
    private let eventStore = EKEventStore()
    @State private var eventTitle: String = "カレンダーの予定を待機中..."

    var body: some View {
        VStack {
            Image(systemName: "calendar")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(eventTitle)
        }
        .padding()
        .onAppear(perform: requestCalendarAccess)
    }

    private func requestCalendarAccess() {
        // macOS 14.0以上で利用可能な新しいAPIを使用
        if #available(macOS 14.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                if let error = error {
                    print("カレンダーアクセス権のリクエスト中にエラー発生: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.eventTitle = "アクセスエラー"
                    }
                    return
                }
                
                if granted {
                    print("カレンダーへのフルアクセスが許可されました。")
                    fetchUpcomingEvent()
                } else {
                    print("カレンダーへのアクセスが拒否されました。")
                    DispatchQueue.main.async {
                        self.eventTitle = "カレンダーへのアクセスが拒否されました。"
                    }
                }
            }
        } else {
            // 古いmacOSバージョン用のフォールバック
            eventStore.requestAccess(to: .event) { granted, error in
                if let error = error {
                    print("カレンダーアクセス権のリクエスト中にエラー発生: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.eventTitle = "アクセスエラー"
                    }
                    return
                }
                
                if granted {
                    print("カレンダーへのアクセスが許可されました。")
                    fetchUpcomingEvent()
                } else {
                    print("カレンダーへのアクセスが拒否されました。")
                    DispatchQueue.main.async {
                        self.eventTitle = "カレンダーへのアクセスが拒否されました。"
                    }
                }
            }
        }
    }

    private func fetchUpcomingEvent() {
        let now = Date()
        let endDate = now.addingTimeInterval(24 * 60 * 60) // 今から24時間後
        let predicate = eventStore.predicateForEvents(withStart: now, end: endDate, calendars: nil)
        
        let events = eventStore.events(matching: predicate)
        
        if let firstEvent = events.first {
            // デバッグコンソールに表示
            print("--- 直近の予定 ---")
            print("タイトル: \(firstEvent.title ?? "名称未設定")")
            print("開始時刻: \(firstEvent.startDate.formatted())")
            print("終了時刻: \(firstEvent.endDate.formatted())")
            print("--------------------")
            
            DispatchQueue.main.async {
                self.eventTitle = firstEvent.title ?? "名称未設定"
            }
        } else {
            print("今後24時間以内に予定は見つかりませんでした。")
            DispatchQueue.main.async {
                self.eventTitle = "直近の予定はありません"
            }
        }
    }
}

#Preview {
    ContentView()
}