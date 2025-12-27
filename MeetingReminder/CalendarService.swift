//
//  CalendarService.swift
//  MeetingReminder
//
//  Created by Mitsuoka Takahiro on 2025/12/27.
//

import Foundation
import EventKit
import Combine

class CalendarService: NSObject, ObservableObject {
    private let eventStore = EKEventStore()
    
    @Published var events: [EKEvent] = []
    @Published var accessGranted = false
    @Published var isLoading = true
    
    // 通知を発動させるためのシグナル
    let notificationTrigger = PassthroughSubject<EKEvent, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    private var notificationTimer: Timer?

    override init() {
        super.init()
        // EKEventStoreの変更を監視する
        NotificationCenter.default.publisher(for: .EKEventStoreChanged)
            .sink { [weak self] _ in
                print("カレンダーの変更を検知しました。予定を再取得します。")
                self?.fetchTodaysEvents()
            }
            .store(in: &cancellables)
    }
    
    func requestAccess() {
        // macOS 14.0以上で利用可能な新しいAPIを使用
        if #available(macOS 14.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                self.handleAccessResponse(granted: granted, error: error)
            }
        } else {
            // 古いmacOSバージョン用のフォールバック
            eventStore.requestAccess(to: .event) { granted, error in
                self.handleAccessResponse(granted: granted, error: error)
            }
        }
    }
    
    private func handleAccessResponse(granted: Bool, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("カレンダーアクセス権のリクエスト中にエラー発生: \(error.localizedDescription)")
                self.accessGranted = false
                self.isLoading = false
                return
            }
            
            self.accessGranted = granted
            if granted {
                print("カレンダーへのアクセスが許可されました。")
                self.fetchTodaysEvents()
            } else {
                print("カレンダーへのアクセスが拒否されました。")
                self.isLoading = false
            }
        }
    }

    func fetchTodaysEvents() {
        guard accessGranted else {
            DispatchQueue.main.async {
                self.isLoading = false
            }
            return
        }
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        
        let fetchedEvents = eventStore.events(matching: predicate)
        
        DispatchQueue.main.async {
            self.events = fetchedEvents
            self.isLoading = false
            print("--- 今日の予定 (\(fetchedEvents.count)件) を更新しました ---")
            fetchedEvents.forEach { event in
                print("タイトル: \(event.title ?? "名称未設定") @ \(event.startDate.formatted())")
            }
            print("--------------------")
            
            // 予定リストを更新したので、次の通知をスケジュールする
            self.scheduleNextNotification()
        }
    }
    
    private func scheduleNextNotification() {
        // 既存のタイマーをキャンセル
        notificationTimer?.invalidate()
        
        // 未来の予定の中から直近のものを探す
        guard let nextEvent = events.first(where: { $0.startDate > Date() }) else {
            print("通知対象となる次の予定はありません。")
            return
        }
        
        // 通知時刻を予定の1分前に設定
        let triggerDate = nextEvent.startDate.addingTimeInterval(-60)
        
        // 通知時刻が過去のものは無視
        guard triggerDate > Date() else {
            print("次の予定「\(nextEvent.title ?? "")」は既に開始時刻を過ぎているため、通知はスケジュールされません。")
            return
        }
        
        print("次の予定「\(nextEvent.title ?? "")」の通知を \(triggerDate.formatted()) にスケジュールしました。")
        
        // タイマーを設定
        notificationTimer = Timer(fireAt: triggerDate, interval: 0, target: self, selector: #selector(fireNotification), userInfo: nextEvent, repeats: false)
        RunLoop.main.add(notificationTimer!, forMode: .common)
    }
    
    @objc private func fireNotification(timer: Timer) {
        guard let event = timer.userInfo as? EKEvent else { return }
        
        print("[\(Date().formatted())] 通知トリガー発動: \(event.title ?? "名称未設定")")
        notificationTrigger.send(event)
        
        // 次の通知をスケジュールする
        scheduleNextNotification()
    }
}