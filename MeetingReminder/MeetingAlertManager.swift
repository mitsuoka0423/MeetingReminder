//
//  OverlayWindowManager.swift
//  MeetingReminder
//
//  Created by Mitsuoka Takahiro on 2025/12/27.
//

import AppKit
import SwiftUI
import Combine
import EventKit

// オーバーレイ表示用のカスタムNSPanel
class MeetingAlertPanel: NSPanel {
    init(contentRect: NSRect, backing: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: [.borderless, .nonactivatingPanel], backing: backing, defer: flag)
        
        self.isFloatingPanel = true
        self.level = .screenSaver
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        self.isMovableByWindowBackground = false
        self.hasShadow = true
        self.isReleasedWhenClosed = false // Managerでライフサイクルを管理するため
        self.backgroundColor = .clear // SwiftUI側で背景を設定するため
        self.isOpaque = false // ウィンドウの不透明を無効にし、背景の透明を許可する
    }
    
    // キーボードイベント（Escキーなど）を受け付けるために必要
    override var canBecomeKey: Bool {
        return true
    }
}


class MeetingAlertManager: ObservableObject {
    private var calendarService: CalendarService
    private var cancellables = Set<AnyCancellable>()
    
    private var overlayWindow: MeetingAlertPanel?

    init(calendarService: CalendarService) {
        self.calendarService = calendarService
        
        // CalendarServiceからの通知トリガーを監視
        calendarService.notificationTrigger
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.showOverlay(for: event)
            }
            .store(in: &cancellables)
    }
    
    func showOverlay(for event: EKEvent) {
        // 既に表示されている場合は何もしない
        if overlayWindow != nil && overlayWindow!.isVisible {
            return
        }

        // メインスクリーンを取得
        guard let mainScreen = NSScreen.main else {
            print("メインスクリーンが見つかりません。")
            return
        }

        // SwiftUIビューを作成
        let overlayView = MeetingAlertView(event: event) { [weak self] in
            self?.hideOverlay()
        }
        
        let hostingView = NSHostingView(rootView: overlayView)
        
        // パネルを作成
        let panel = MeetingAlertPanel(contentRect: mainScreen.frame, backing: .buffered, defer: false)
        panel.title = "しっかリマインダー: \(event.title ?? "通知")"
        panel.contentView = hostingView
        panel.contentView?.wantsLayer = true
        panel.contentView?.layer?.isOpaque = false
        
        // 表示
        panel.makeKeyAndOrderFront(nil)
        
        self.overlayWindow = panel
    }
    
    func hideOverlay() {
        overlayWindow?.orderOut(nil)
        overlayWindow = nil // 解放
    }
}
