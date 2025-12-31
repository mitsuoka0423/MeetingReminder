#if DEBUG
import Foundation
import EventKit

struct DebugEventProvider {
    
    static func createEvent(
        title: String,
        minutesFromNow: Int,
        durationInMinutes: Int,
        notes: String?,
        hasURL: Bool
    ) -> EKEvent {
        let event = EKEvent(eventStore: EKEventStore()) // Note: This store is temporary
        event.title = title
        event.startDate = Date().addingTimeInterval(TimeInterval(minutesFromNow * 60))
        event.endDate = event.startDate.addingTimeInterval(TimeInterval(durationInMinutes * 60))
        
        var eventNotes = notes ?? ""
        if hasURL {
            if !eventNotes.isEmpty {
                eventNotes += "\n\n"
            }
            eventNotes += "参加用URL: https://meet.google.com/abc-def-ghi"
        }
        
        if !eventNotes.isEmpty {
            event.notes = eventNotes
        }
        
        // Note: Creating real EKParticipant objects for the `attendees` property
        // is not feasible for this kind of debug setup, as EKParticipant is read-only
        // and tightly coupled with the EventKit backend.
        // We can test the "no attendees" case, which is implicitly handled.
        
        return event
    }
    
    static let testCases: [String: EKEvent] = [
        "通常（URL・説明あり）": createEvent(
            title: "プロジェクト定例会議",
            minutesFromNow: 10,
            durationInMinutes: 50,
            notes: "今週の進捗確認と来週のタスク割り当てを行います。",
            hasURL: true
        ),
        "説明文が長い": createEvent(
            title: "新機能ブレインストーミング",
            minutesFromNow: 30,
            durationInMinutes: 60,
            notes: """
            新しいユーザー体験向上のためのアイデア出し会議です。
            - 現状の課題点の洗い出し
            - 競合アプリの分析
            - 新機能案の提案（UI/UX含む）
            - 実装の実現可能性の検討
            
            この説明文は、スクロールビューが正しく機能するか、また複数行のテキストがレイアウトを崩さずに表示されるかを確認するためのテストです。
            """,
            hasURL: true
        ),
        "URLのみ（説明なし）": createEvent(
            title: "クイック同期",
            minutesFromNow: 45,
            durationInMinutes: 15,
            notes: nil,
            hasURL: true
        ),
        "URLなし（説明あり）": createEvent(
            title: "1on1ミーティング",
            minutesFromNow: 60,
            durationInMinutes: 30,
            notes: "キャリアパスについての面談。",
            hasURL: false
        ),
        "情報がほぼ無い": createEvent(
            title: "個人作業時間",
            minutesFromNow: 120,
            durationInMinutes: 90,
            notes: "",
            hasURL: false
        )
    ]
}
#endif
