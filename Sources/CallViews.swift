import SwiftUI

/* ==================================================================
   通话（效果图 34-37）：来电 / 语音通话 / 视频通话 / 群通话（演示 UI）
   ================================================================== */

enum CallState: String {
    case voiceIn    // 34 来电
    case voiceOut   // 35 语音通话中
    case video      // 36 视频通话
    case group      // 37 群通话
}

struct CallScreen: View {
    @Environment(\.dismiss) private var dismiss
    let state: CallState
    let name: String
    @State private var seconds = 0
    @State private var timer: Timer? = nil
    @State private var answered = false

    var body: some View {
        ZStack {
            if state == .video {
                videoBg
            } else {
                LinearGradient(colors: [Color(red: 0.353, green: 0.42, blue: 0.549),
                                        Color(red: 0.2, green: 0.251, blue: 0.361),
                                        Color(red: 0.118, green: 0.149, blue: 0.204)],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }

            switch state {
            case .voiceIn: incomingView
            case .voiceOut: voiceView
            case .video: videoView
            case .group: groupView
            }
        }
        .onAppear {
            if state != .voiceIn {
                answered = true
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in seconds += 1 }
            }
        }
        .onDisappear { timer?.invalidate() }
    }

    private var videoBg: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.15, green: 0.19, blue: 0.26),
                                    Color(red: 0.06, green: 0.09, blue: 0.14)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            Circle()
                .fill(RadialGradient(colors: [Color(red: 0.494, green: 0.69, blue: 1.0).opacity(0.22), .clear],
                                     center: .center, startRadius: 0, endRadius: 260))
                .frame(width: 420, height: 420)
                .offset(y: -80)
        }
    }

    /* 34 来电 */
    private var incomingView: some View {
        VStack(spacing: 0) {
            Text("语音通话来电")
                .font(.system(size: 14)).foregroundColor(.white.opacity(0.6))
                .padding(.top, 10)
            Ava(name: name, size: 104)
                .shadow(color: .white.opacity(0.12), radius: 4)
                .padding(.top, 44)
            Text(name).font(.system(size: 24, weight: .semibold)).foregroundColor(.white).padding(.top, 16)
            Text("邀请你语音通话…")
                .font(.system(size: 16)).foregroundColor(.white.opacity(0.65)).padding(.top, 8)
            Spacer()
            HStack(spacing: 80) {
                callBtn("phone.down.fill", "拒绝", .red) { dismiss() }
                callBtn("phone.fill", "接听", .green) {
                    H.ok()
                    answered = true
                    state2Voice()
                }
            }
            .padding(.bottom, 46)
        }
    }

    @State private var showVoice = false
    private func state2Voice() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in seconds += 1 }
        showVoice = true
    }

    /* 35 语音通话中 */
    private var voiceView: some View {
        VStack(spacing: 0) {
            if showVoice {
                voiceBody
            } else {
                incomingView
            }
        }
    }

    private var voiceBody: some View {
        VStack(spacing: 0) {
            Text("语音通话中")
                .font(.system(size: 14)).foregroundColor(.white.opacity(0.6)).padding(.top, 10)
            Ava(name: name, size: 104)
                .padding(.top, 40)
            Text(name).font(.system(size: 24, weight: .semibold)).foregroundColor(.white).padding(.top, 16)
            Text(timeStr).font(.system(size: 17)).foregroundColor(.white.opacity(0.75)).padding(.top, 8)
            Spacer()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 18), count: 3), spacing: 22) {
                ctrlBtn("mic.fill", "静音")
                ctrlBtn("speaker.wave.2.fill", "免提")
                ctrlBtn("video.fill", "切视频")
                ctrlBtn("person.badge.plus", "加人")
                ctrlBtn("arrow.down.right.and.arrow.up.left", "最小化")
                callBtn("phone.down.fill", "挂断", .red) { dismiss() }
            }
            .padding(.horizontal, 26).padding(.bottom, 44)
        }
    }

    /* 36 视频通话 */
    private var videoView: some View {
        ZStack {
            VStack(spacing: 0) {
                Text(name).font(.system(size: 20, weight: .semibold)).foregroundColor(.white).padding(.top, 52)
                Text("视频通话中 · \(timeStr)")
                    .font(.system(size: 14)).foregroundColor(.white.opacity(0.72)).padding(.top, 5)
                Spacer()
                HStack(spacing: 26) {
                    ctrlBtn("mic.fill", "静音")
                    ctrlBtn("video.slash.fill", "关摄像头")
                    ctrlBtn("arrow.triangle.2.circlepath.camera.fill", "翻转")
                    callBtn("phone.down.fill", "挂断", .red) { dismiss() }
                }
                .padding(.horizontal, 22).padding(.bottom, 20)
            }
            /* 本地小窗 */
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(LinearGradient(colors: [Color(red: 0.42, green: 0.52, blue: 0.68), Color(red: 0.24, green: 0.3, blue: 0.42)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 92, height: 130)
                .overlay(
                    Ava(name: "我", size: 40, img: "").padding(.bottom, 40)
                )
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.22), lineWidth: 1.5))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.trailing, 14).padding(.top, 96)
        }
    }

    /* 37 群通话 */
    private var groupView: some View {
        ZStack {
            VStack(spacing: 0) {
                Text("群通话").font(.system(size: 19, weight: .semibold)).foregroundColor(.white).padding(.top, 14)
                Text("4 人在线 · \(timeStr)")
                    .font(.system(size: 14)).foregroundColor(.white.opacity(0.7)).padding(.top, 4)
                Spacer()
                HStack(spacing: 24) {
                    ctrlBtn("mic.fill", "静音")
                    ctrlBtn("video.fill", "摄像头")
                    ctrlBtn("person.badge.plus", "邀请")
                    callBtn("phone.down.fill", "挂断", .red) { dismiss() }
                }
                .padding(.horizontal, 22).padding(.bottom, 18)
            }
            VStack(spacing: 8) {
                ForEach(0..<2, id: \.self) { r in
                    HStack(spacing: 8) {
                        ForEach(0..<2, id: \.self) { c in
                            let names = ["老王", "星皓", "我", "李明"]
                            ZStack(alignment: .bottomLeading) {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(LinearGradient(colors: [Color(red: 0.2 + Double(r) * 0.05, green: 0.25, blue: 0.34),
                                                                  Color(red: 0.12, green: 0.16, blue: 0.23)],
                                                         startPoint: .top, endPoint: .bottom))
                                Ava(name: names[r * 2 + c], size: 52)
                                    .frame(maxWidth: .infinity).padding(.top, 26)
                                Text(names[r * 2 + c])
                                    .font(.system(size: 12)).foregroundColor(.white)
                                    .padding(.horizontal, 7).padding(.vertical, 3)
                                    .background(.black.opacity(0.32))
                                    .clipShape(Capsule())
                                    .padding(7)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 12).padding(.top, 54).padding(.bottom, 110)
        }
    }

    private var timeStr: String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    private func callBtn(_ icon: String, _ label: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button {
            H.tap(.medium)
            action()
        } label: {
            VStack(spacing: 7) {
                Circle().fill(color)
                    .frame(width: 64, height: 64)
                    .overlay(Image(systemName: icon).font(.system(size: 24)).foregroundColor(.white))
                    .shadow(color: color.opacity(0.4), radius: 6, y: 4)
                Text(label).font(.system(size: 12.5)).foregroundColor(.white.opacity(0.72))
            }
        }
        .buttonStyle(PressStyle(scale: 0.92))
    }

    private func ctrlBtn(_ icon: String, _ label: String) -> some View {
        Button {
            H.sel()
        } label: {
            VStack(spacing: 7) {
                Circle().fill(.white.opacity(0.14))
                    .frame(width: 64, height: 64)
                    .overlay(Image(systemName: icon).font(.system(size: 23)).foregroundColor(.white))
                Text(label).font(.system(size: 12.5)).foregroundColor(.white.opacity(0.72))
            }
        }
        .buttonStyle(PressStyle(scale: 0.92))
    }
}
