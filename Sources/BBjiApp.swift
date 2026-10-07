import SwiftUI

@main
struct BBjiApp: App {
    @StateObject private var session = Session()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .preferredColorScheme(.light)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var session: Session

    var body: some View {
        ZStack {
            AppBg()
            if session.loggedIn {
                HomePlaceholder()
            } else {
                AuthFlow()
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.9), value: session.loggedIn)
    }
}

/* 登录后的占位页 —— 消息列表是下一轮的活，先占个位 */
struct HomePlaceholder: View {
    @EnvironmentObject var session: Session
    var body: some View {
        VStack(spacing: 12) {
            BrandView(logoSize: 62)
            Text("登录成功：\(session.myName)")
                .font(.system(size: 13, weight: .medium)).foregroundColor(T.ink)
            Text("06 消息列表下一轮做")
                .font(.system(size: 11.5)).foregroundColor(T.tag2Gray)
            Button {
                session.logout()
            } label: {
                Text("退出登录").font(.system(size: 13)).foregroundColor(T.blue)
            }
            .padding(.top, 20)
        }
    }
}
