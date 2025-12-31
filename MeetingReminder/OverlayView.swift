//
//  OverlayView.swift
//  MeetingReminder
//
//  Created by Mitsuoka Takahiro on 2025/12/27.
//

import SwiftUI
import EventKit

struct OverlayView: View {
    let event: EKEvent
    let dismissAction: () -> Void
    
    // ミーティングURLを検索
    private var meetingURL: URL? {
        MeetingURLFinder.find(in: event)
    }

    var body: some View {
        VStack(spacing: 15) {
            
            // 予定タイトル
            Text(event.title)
                .font(.system(size: 48, weight: .bold, design: .default))
                .multilineTextAlignment(.center)
                .shadow(radius: 3)
                .padding(.top)

            // 開催時間
            Text("\(event.startDate.formatted(date: .omitted, time: .shortened)) - \(event.endDate.formatted(date: .omitted, time: .shortened))")
                .font(.system(size: 28, weight: .regular))
                .opacity(0.8)
            
            // 説明と参加者を表示するスクロール領域
            if (event.notes != nil && !event.notes!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) || (event.attendees != nil && !event.attendees!.isEmpty) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // 説明（メモ）
                        if let notes = event.notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("説明")
                                .font(.headline)
                                .padding(.bottom, 2)
                            Text(notes)
                                .font(.body)
                            Divider()
                        }
                        
                        // 参加者
                        if let attendees = event.attendees, !attendees.isEmpty {
                            Text("参加者")
                                .font(.headline)
                                .padding(.bottom, 2)
                            ForEach(attendees, id: \.self) {
                                attendee in
                                Text(attendee.name ?? "不明な参加者")
                            }
                        }
                    }
                    .padding()
                }
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .frame(maxHeight: 200) // スクロール領域の最大の高さを制限
            }

            // ボタン領域
            HStack(spacing: 30) {
                // 閉じるボタン
                Button(action: dismissAction) {
                    Text("閉じる")
                        .font(.title2)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                }
                .keyboardShortcut(.escape, modifiers: [])

                // 参加ボタン (URLが見つかった場合のみ表示)
                if let url = meetingURL {
                    Button(action: {
                        NSWorkspace.shared.open(url)
                        dismissAction() // 参加したらオーバーレイを閉じる
                    }) {
                        Text("参加する")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 10)
                    }
                    .controlSize(.large)
                }
            }
            .padding(.bottom)
        }
        .padding(40)
        .padding(.horizontal, 80) // 追加の左右マージン
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .foregroundColor(.primary)
        .background(
            Button("", action: dismissAction)
                .keyboardShortcut(.escape, modifiers: [])
        )
    }
}

// プレビュー用のダミーデータ
#if DEBUG
struct OverlayView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyEvent = EKEvent(eventStore: EKEventStore())
        dummyEvent.title = "プロジェクト定例会議"
        dummyEvent.startDate = Date().addingTimeInterval(60 * 10)
        dummyEvent.endDate = Date().addingTimeInterval(60 * 70)
        dummyEvent.notes = "これはテスト用のメモです。\n複数行にわたるテキストも確認します。\n会議URL: https://meet.google.com/abc-def-ghi"
        
        return OverlayView(event: dummyEvent, dismissAction: {
            print("Dismiss action triggered.")
        })
    }
}
#endif
