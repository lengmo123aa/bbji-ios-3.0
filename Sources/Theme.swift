import SwiftUI
import UIKit

/* ==================================================================
   Theme —— 3.0 版，数值全部照《效果图/index.html》（v7 定稿）抄，别自己发明。
   :root 变量：
     --blue #0A84FF / --ink #0B0D12 / --ink2 #2C323C / --sec #8A93A0 / --ter #AAB2BD
     --sep rgba(60,60,67,.085) / --page #F4F6FA / --card #FFFFFF / --search #EBEEF4
     状态色 red #FF3B30 orange #FF9500 green #34C759 purple #7B5CF0 pink #F2557D teal #1E9EE0
   ================================================================== */
enum T {
    /* 文字 */
    static let ink = Color(red: 0.043, green: 0.051, blue: 0.071)       // #0B0D12
    static let ink2 = Color(red: 0.173, green: 0.196, blue: 0.235)      // #2C323C
    static let sec = Color(red: 0.541, green: 0.576, blue: 0.627)       // #8A93A0
    static let ter = Color(red: 0.667, green: 0.698, blue: 0.741)       // #AAB2BD
    static let tagGray = Color(red: 0.443, green: 0.475, blue: 0.541)   // .tag #71798A
    static let tag2Gray = Color(red: 0.682, green: 0.714, blue: 0.757)  // .tag2 #AEB6C1
    static let hint = Color(red: 0.596, green: 0.631, blue: 0.682)      // #98A1AE
    static let labelGray = Color(red: 0.541, green: 0.576, blue: 0.627) // 表单标签 #8A93A0

    /* 主色 / 状态色 */
    static let blue = Color(red: 0.039, green: 0.518, blue: 1.0)        // #0A84FF
    static let red = Color(red: 1.0, green: 0.231, blue: 0.188)         // #FF3B30
    static let orange = Color(red: 1.0, green: 0.584, blue: 0.0)        // #FF9500
    static let green = Color(red: 0.204, green: 0.780, blue: 0.349)     // #34C759
    static let purple = Color(red: 0.482, green: 0.361, blue: 0.941)    // #7B5CF0
    static let pink = Color(red: 0.949, green: 0.333, blue: 0.490)      // #F2557D
    static let teal = Color(red: 0.118, green: 0.620, blue: 0.878)      // #1E9EE0

    static let page = Color(red: 0.957, green: 0.965, blue: 0.980)      // #F4F6FA
    static let card = Color.white
    static let searchBg = Color(red: 0.922, green: 0.933, blue: 0.957)  // #EBEEF4
    static let sep = Color(red: 0.235, green: 0.235, blue: 0.263).opacity(0.085)

    static let cardRadius: CGFloat = 13

    /* CTA 渐变（.cta/.btn：180deg #79B0FF→#4A8BF6，投影 12/26 rgba(74,139,246,.32)） */
    static let gradCTA = LinearGradient(
        colors: [Color(red: 0.475, green: 0.690, blue: 1.0),           // #79B0FF
                 Color(red: 0.290, green: 0.545, blue: 0.965)],        // #4A8BF6
        startPoint: .top, endPoint: .bottom)

    /* 在线绿点（.ondot：180deg #5FD97E→#34C759） */
    static let gradGreen = LinearGradient(
        colors: [Color(red: 0.373, green: 0.851, blue: 0.494), Color.green],
        startPoint: .top, endPoint: .bottom)

    /* 红点数字（.bdg：红渐变） */
    static let gradRed = LinearGradient(
        colors: [Color(red: 1.0, green: 0.420, blue: 0.357), T.red],
        startPoint: .top, endPoint: .bottom)

    /* 兜底头像用的渐变 */
    static let avGrads: [[Color]] = [
        [Color(red: 0.498, green: 0.714, blue: 1.0), T.blue],
        [Color(red: 1.0, green: 0.663, blue: 0.769), T.pink],
        [Color(red: 0.776, green: 0.663, blue: 1.0), T.purple],
        [Color(red: 1.0, green: 0.757, blue: 0.510), T.orange],
        [Color(red: 0.561, green: 0.890, blue: 0.690), T.green],
        [Color(red: 0.561, green: 0.867, blue: 0.910), T.teal],
    ]

    /// 列表统一 spring（任务书 2.2-3：response 0.35 / damping 0.86）
    static let spring = Animation.spring(response: 0.35, dampingFraction: 0.86)
}

/* ==================== 触感 ==================== */
enum H {
    static func tap(_ s: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let g = UIImpactFeedbackGenerator(style: s)
        g.prepare()
        g.impactOccurred()
    }
    static func sel() { UISelectionFeedbackGenerator().selectionChanged() }
    static func ok() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func warn() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
}

/* ==================== 附件地址 / 图片缓存 ==================== */
func bbFileURL(_ fid: String) -> URL? {
    let f = fid.trimmingCharacters(in: .whitespacesAndNewlines)
    if f.isEmpty { return nil }
    if f.hasPrefix("http") { return URL(string: f) }
    let t = (UserDefaults.standard.string(forKey: "bbji_token") ?? "")
        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    return URL(string: "https://bbji.xkmd.cn/api/file/\(f)?t=\(t)")
}

final class ImgStore {
    static let shared = ImgStore()
    private let cache = NSCache<NSURL, UIImage>()
    private init() { cache.countLimit = 240 }
    func cached(_ u: URL) -> UIImage? { cache.object(forKey: u as NSURL) }
    func image(_ u: URL) async -> UIImage? {
        if let i = cached(u) { return i }
        guard let (d, _) = try? await URLSession.shared.data(from: u),
              let i = UIImage(data: d) else { return nil }
        cache.setObject(i, forKey: u as NSURL)
        return i
    }
}

/// 带缓存的网络图
struct NetImg: View {
    let url: URL?
    var fill: Bool = true
    @State private var img: UIImage?

    var body: some View {
        Group {
            if let img {
                Image(uiImage: img).resizable()
                    .aspectRatio(contentMode: fill ? .fill : .fit)
            } else {
                Color(red: 0.906, green: 0.921, blue: 0.945)
            }
        }
        .onAppear { load() }
        .onChange(of: url) { _ in img = nil; load() }
    }

    private func load() {
        guard let url else { return }
        if let c = ImgStore.shared.cached(url) { img = c; return }
        Task { @MainActor in
            if let i = await ImgStore.shared.image(url) { img = i }
        }
    }
}

/// 通用按压反馈
struct PressStyle: ButtonStyle {
    var scale: CGFloat = 0.94
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? 0.72 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension View {
    /// 设计稿 .grp 白卡：radius 13 + 0 1px 2px rgba(84,112,158,.04)
    func bbCard(_ radius: CGFloat = T.cardRadius) -> some View {
        background(T.card)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: Color(red: 0.329, green: 0.439, blue: 0.620).opacity(0.04), radius: 1, y: 2)
    }
}

/// 官方 logo（图标资源里那张 1024 的圆图，效果图的 brandv 就是它）
struct LogoMark: View {
    var size: CGFloat
    var body: some View {
        Image("Logo").resizable().interpolation(.high)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.24, style: .continuous))
            .shadow(color: Color(red: 0.29, green: 0.43, blue: 0.72).opacity(0.16), radius: size * 0.10, y: size * 0.05)
    }
}

/// 品牌区（.brandv：logo + BB鸡 23px/700/字距-0.6，间距 9）
struct BrandView: View {
    var logoSize: CGFloat = 70
    var title = "BB鸡"
    var titleSize: CGFloat = 23
    var body: some View {
        VStack(spacing: 9) {
            LogoMark(size: logoSize)
            Text(title)
                .font(.system(size: titleSize, weight: .bold))
                .kerning(-0.6)
                .foregroundColor(T.ink)
        }
    }
}

/// 主按钮（.cta：高 50 / 胶囊 / 渐变 / 15px 600 / 投影 0 12px 26px rgba(74,139,246,.32)）
struct BigButton: View {
    let title: String
    var busy = false
    var disabled = false
    let action: () -> Void
    var body: some View {
        Button {
            H.tap(.medium)
            action()
        } label: {
            Text(busy ? "请稍等…" : title)
                .font(.system(size: 15, weight: .semibold)).kerning(0.2)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).frame(height: 50)
                .background(T.gradCTA)
                .clipShape(Capsule())
                .shadow(color: Color(red: 0.290, green: 0.545, blue: 0.965).opacity(0.32), radius: 12, y: 12)
                .opacity(disabled || busy ? 0.55 : 1)
        }
        .disabled(disabled || busy)
        .buttonStyle(PressStyle(scale: 0.97))
    }
}

/// 表单一行（.row tall：min 高 44 / 左标签 12px #8A93A0 宽 42 / 右值 12.5px / 分割线 left:16）
struct FieldRow: View {
    let label: String
    @Binding var text: String
    var placeholder = ""
    var secure = false
    var keyboard: UIKeyboardType = .default
    var trailing: AnyView? = nil
    var reveal: Binding<Bool>? = nil   /* 密码那行的小眼睛：true = 明文 */

    var body: some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.system(size: 12)).foregroundColor(T.labelGray)
                .frame(width: 42, alignment: .leading)
            Group {
                if secure && !(reveal?.wrappedValue ?? false) {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboard)
                }
            }
            .font(.system(size: 12.5))
            .foregroundColor(T.ink)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            if let t = trailing { t }
        }
        .padding(.horizontal, 16).frame(minHeight: 44)
    }
}

/// 卡片行之间的分割线（.row + .row::before：left 16 / .5px / --sep）
struct RowSep: View {
    var body: some View {
        Rectangle().fill(T.sep).frame(height: 0.5)
            .padding(.leading, 16)
    }
}

/// 页面背景（效果图 .scr 的底就是 --page 纯色）
struct AppBg: View {
    var body: some View {
        T.page.ignoresSafeArea()
    }
}
