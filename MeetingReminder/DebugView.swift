#if DEBUG
import SwiftUI
import EventKit

struct DebugView: View {
    @EnvironmentObject private var overlayWindowManager: MeetingAlertManager
    @Environment(\.dismiss) private var dismiss

    // テストケースを名前でソートして表示
    private let testCases = DebugEventProvider.testCases.sorted { $0.key < $1.key }

    var body: some View {
        VStack(spacing: 0) {
            Text("デバッグ用テストケース")
                .font(.title2)
                .padding()
            
            Divider()

            List {
                ForEach(testCases, id: \.key) { name, event in
                    Button(action: {
                        // 既存のオーバーレイがあれば閉じてから新しいものを表示
                        overlayWindowManager.hideOverlay()
                        // 少し待ってから表示しないとウィンドウがうまく切り替わらない場合がある
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            overlayWindowManager.showOverlay(for: event)
                        }
                        // dismiss() // ウィンドウを閉じずに連続テストできるように変更
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(name)
                                .fontWeight(.bold)
                            Text(event.title)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain) // リストの行全体をクリック可能にする
                }
            }
            
            Divider()
            
            HStack {
                Spacer()
                Button("閉じる") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
                .padding()
            }
        }
        .frame(width: 350, height: 450)
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
            .environmentObject(MeetingAlertManager(calendarService: CalendarService(userSettings: UserSettings())))
    }
}
#endif
