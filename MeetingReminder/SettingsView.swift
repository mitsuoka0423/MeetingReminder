//
//  SettingsView.swift
//  MeetingReminder
//
//  Created by Mitsuoka Takahiro on 2025/12/27.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSettings: UserSettings
    
    // ユーザーが選択できる通知オフセットのオプション
    private let offsetOptions: [(label: String, value: TimeInterval)] = [
        ("30秒前", 30),
        ("1分前", 60),
        ("2分前", 120),
        ("5分前", 300),
        ("10分前", 600)
    ]
    
    var body: some View {
        Form {
            Picker("通知タイミング", selection: $userSettings.notificationOffsetInSeconds) {
                ForEach(offsetOptions, id: \.value) { option in
                    Text(option.label).tag(option.value)
                }
            }
            .pickerStyle(.inline)
            .frame(width: 200) // Pickerの幅を調整
            
            Text("会議開始の何分前に通知するかを設定します。")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(minWidth: 300, minHeight: 150)
        .navigationTitle("しっかリマインダー設定")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(UserSettings()) // プレビュー用にUserSettingsを渡す
    }
}
