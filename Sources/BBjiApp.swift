import SwiftUI

@main
struct BBjiApp: App {
    @StateObject private var session = Session()
    @StateObject private var store = Store()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .environmentObject(store)
                .preferredColorScheme(.light)
        }
        .onChange(of: scenePhase) { phase in
            /* 离开就锁：切后台 / 关屏 → 上锁 */
            if phase != .active, session.lockPwOn, session.lockPwSet {
                session.locked = true
            }
            /* 进后台就断不了 WS —— Store 自己有心跳和重连，不管它 */
        }
    }
}

struct RootView: View {
    @EnvironmentObject var session: Session
    @EnvironmentObject var store: Store

    var body: some View {
        ZStack {
            if session.loggedIn {
                MainTabs()
                    .onAppear {
                        if !store.connected { store.connect(token: session.token, onFail: { session.logout() }) }
                    }
            } else {
                AuthFlow()
            }
            /* 46/47 锁定覆盖层 */
            if session.locked && session.lockPwSet {
                LockOverlay()
                    .transition(.opacity)
                    .zIndex(99)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: session.locked)
        .animation(.spring(response: 0.4, dampingFraction: 0.9), value: session.loggedIn)
    }
}
