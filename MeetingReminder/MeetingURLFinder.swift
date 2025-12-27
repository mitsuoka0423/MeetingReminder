//
//  MeetingURLFinder.swift
//  MeetingReminder
//
//  Created by Mitsuoka Takahiro on 2025/12/27.
//

import Foundation
import EventKit

struct MeetingURLFinder {
    
    // サポートするWeb会議サービスの正規表現パターン
    private static let patterns = [
        // Zoom
        "https://[a-zA-Z0-9-]+\\.zoom.us/j/[a-zA-Z0-9?&=_.-]+",
        // Google Meet
        "https://meet.google.com/[a-zA-Z-]+"
    ]
    
    /// EKEventからWeb会議のURLを検索する
    /// - Parameter event: 検索対象のイベント
    /// - Returns: 見つかった場合はURL、見つからなければnil
    static func find(in event: EKEvent) -> URL? {
        // 1. event.urlフィールドを最初にチェック
        if let eventURL = event.url, isMeetingURL(eventURL) {
            return eventURL
        }
        
        // 2. event.notesフィールドを次にチェック
        if let notes = event.notes, let url = findURL(in: notes) {
            return url
        }
        
        return nil
    }
    
    /// 与えられたURLがWeb会議のURLパターンに一致するかどうかを判定
    private static func isMeetingURL(_ url: URL) -> Bool {
        let urlString = url.absoluteString
        for pattern in patterns {
            if urlString.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }
        return false
    }
    
    /// 与えられたテキスト内からWeb会議のURLを検索する
    private static func findURL(in text: String) -> URL? {
        for pattern in patterns {
            if let range = text.range(of: pattern, options: .regularExpression) {
                let urlString = String(text[range])
                if let url = URL(string: urlString) {
                    return url
                }
            }
        }
        return nil
    }
}
