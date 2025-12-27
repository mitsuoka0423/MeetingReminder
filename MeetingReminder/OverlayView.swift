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
        VStack(spacing: 20) {
            
            // 予定タイトル
            Text(event.title)
                .font(.system(size: 60, weight: .bold, design: .default))
                .multilineTextAlignment(.center)
                .shadow(radius: 4)

            // 開催時間
            Text("\(event.startDate.formatted(date: .omitted, time: .shortened)) - \(event.endDate.formatted(date: .omitted, time: .shortened))")
                .font(.system(size: 32, weight: .regular))
                .opacity(0.8)

            HStack(spacing: 30) {
                // 閉じるボタン
                Button(action: dismissAction) {
                    Text("閉じる")
                        .font(.title)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                }
                .keyboardShortcut(.escape, modifiers: []) // Escキーで閉じられるようにする

                // 参加ボタン (URLが見つかった場合のみ表示)
                if let url = meetingURL {
                    Button(action: {
                        NSWorkspace.shared.open(url)
                        dismissAction() // 参加したらオーバーレイを閉じる
                    }) {
                        Text("参加する")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                    }
                    .controlSize(.large)
                }
            }
            .padding(.top, 40)
        }
        .padding(60)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .foregroundColor(.primary)
        // Escキーで閉じるための見えないボタン
        .background(
            Button("") {
                dismissAction()
            }
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
        // プレビュー用にダミーのURLをメモに追加
        dummyEvent.notes = "これはテスト用のメモです。会議URL: https://meet.google.com/abc-def-ghi"
        
        return OverlayView(event: dummyEvent, dismissAction: {
            print("Dismiss action triggered.")
        })
    }
}
#endif