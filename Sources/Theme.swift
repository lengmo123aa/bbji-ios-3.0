import SwiftUI
import UIKit

/* ==================================================================
   Theme —— 3.0 版，色彩照《效果图/index.html》v7 抄。
   字号说明：效果图是 270px 宽的画布，真机 390pt，直接抄像素会偏小（用户反馈"字太小"），
   所以全套字号/头像在效果图基础上放大约 1.3 倍，比例关系保持不变。
   :root：--blue #0A84FF / --ink #0B0D12 / --ink2 #2C323C / --sec #8A93A0 / --ter #AAB2BD
          --sep rgba(60,60,67,.085) / --page #F4F6FA / --card #FFFFFF / --search #EBEEF4
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
    static let chevGray = Color(red: 0.788, green: 0.816, blue: 0.851)  // .ch #C9D0D9

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
    static let fldBg = Color(red: 0.945, green: 0.953, blue: 0.969)     // #F1F3F7

    static let cardRadius: CGFloat = 16

    /* 渐变（.cta/.btn/.sendb：180deg #79B0FF→#4A8BF6 + 内高光） */
    static let gradCTA = LinearGradient(
        colors: [Color(red: 0.475, green: 0.690, blue: 1.0),           // #79B0FF
                 Color(red: 0.290, green: 0.545, blue: 0.965)],        // #4A8BF6
        startPoint: .top, endPoint: .bottom)
    static let gradGreen = LinearGradient(
        colors: [Color(red: 0.373, green: 0.851, blue: 0.494), T.green],
        startPoint: .top, endPoint: .bottom)
    static let gradRed = LinearGradient(
        colors: [Color(red: 1.0, green: 0.42, blue: 0.357), T.red],
        startPoint: .top, endPoint: .bottom)

    /* 左滑三个按钮（.acts2：p1 #C3CBD8 / p2 #F0913F / p3 #FF3B30） */
    static let swipeGray = Color(red: 0.765, green: 0.796, blue: 0.847)
    static let swipeOrange = Color(red: 0.941, green: 0.569, blue: 0.247)

    /* 图标圆底渐变（v3 .c1–.c6） */
    static let icGrads: [[Color]] = [
        [Color(red: 0.776, green: 0.663, blue: 1.0), Color(red: 0.557, green: 0.42, blue: 0.941)],   // c1 紫
        [Color(red: 1.0, green: 0.663, blue: 0.769), Color(red: 0.949, green: 0.333, blue: 0.49)],   // c2 粉
        [Color(red: 1.0, green: 0.757, blue: 0.51), Color(red: 0.941, green: 0.569, blue: 0.247)],   // c3 橙
        [Color(red: 0.498, green: 0.714, blue: 1.0), Color(red: 0.29, green: 0.545, blue: 0.965)],   // c4 蓝
        [Color(red: 0.561, green: 0.89, blue: 0.69), Color(red: 0.22, green: 0.698, blue: 0.416)],   // c5 绿
        [Color(red: 0.561, green: 0.867, blue: 0.91), Color(red: 0.18, green: 0.624, blue: 0.698)],  // c6 青
    ]
    static let avGrads = icGrads

    /// 列表统一 spring
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
    static var shared = ImgStore()
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

struct PressStyle: ButtonStyle {
    var scale: CGFloat = 0.96
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? 0.75 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension View {
    /// 设计稿 .grp 白卡（v7：radius 16 + 0 1px 2px 阴影）
    func bbCard(_ radius: CGFloat = T.cardRadius) -> some View {
        background(T.card)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: Color(red: 0.329, green: 0.439, blue: 0.620).opacity(0.05), radius: 2, y: 2)
    }
}

/// 页面背景
struct AppBg: View {
    var body: some View { T.page.ignoresSafeArea() }
}

/// 官方 logo
struct LogoMark: View {
    var size: CGFloat
    var body: some View {
        Image("Logo").resizable().interpolation(.high)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.24, style: .continuous))
            .shadow(color: Color(red: 0.29, green: 0.43, blue: 0.72).opacity(0.16), radius: size * 0.10, y: size * 0.05)
    }
}

/// 品牌区（.brandv）
struct BrandView: View {
    var logoSize: CGFloat = 70
    var title = "BB鸡"
    var titleSize: CGFloat = 28
    var body: some View {
        VStack(spacing: 11) {
            LogoMark(size: logoSize)
            Text(title)
                .font(.system(size: titleSize, weight: .bold))
                .kerning(-0.8)
                .foregroundColor(T.ink)
        }
    }
}

/* ============ 大标题（.ltitle h1：25→31px / 700 / 字距 -1.1） ============ */
struct TopTitle<Trailing: View>: View {
    let text: String
    @ViewBuilder var trailing: () -> Trailing
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Text(text).font(.system(size: 31, weight: .bold))
                .kerning(-1.1).foregroundColor(T.ink)
            Spacer(minLength: 0)
            trailing()
        }
        .padding(.horizontal, 18).padding(.top, 2).padding(.bottom, 12)
    }
}
extension TopTitle where Trailing == EmptyView {
    init(_ text: String) { self.init(text: text) { EmptyView() } }
}

/* ============ 顶栏（.navbar：高 48 / 标题 18/600 / 右侧蓝色图标） ============ */
struct NavBar<Trailing: View>: View {
    var title = ""
    var subtitle = ""
    var avatarId = ""      // 传了就显示小头像
    var avatarSize: CGFloat = 36
    var online: Bool? = nil
    var onBack: (() -> Void)? = nil
    var backTint: Color = T.blue
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 10) {
            if let onBack {
                Button {
                    H.tap()
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(backTint)
                        .frame(width: 30, alignment: .leading)
                }
                .buttonStyle(PressStyle())
            }
            if !avatarId.isEmpty || avatarId == "logo" {
                if avatarId == "logo" {
                    LogoMark(size: avatarSize)
                } else {
                    Ava(name: title, size: avatarSize, online: online, img: avatarId)
                }
            }
            VStack(alignment: .leading, spacing: 1) {
                if !title.isEmpty {
                    Text(title).font(.system(size: 18, weight: .semibold))
                        .kerning(-0.3).foregroundColor(backTint == T.blue ? T.ink : .white)
                        .lineLimit(1)
                }
                if !subtitle.isEmpty {
                    Text(subtitle).font(.system(size: 12)).foregroundColor(backTint == T.blue ? T.sec : .white.opacity(0.75))
                }
            }
            Spacer(minLength: 0)
            trailing()
        }
        .padding(.horizontal, 14).frame(minHeight: 48)
    }
}
extension NavBar where Trailing == EmptyView {
    init(title: String = "", subtitle: String = "", avatarId: String = "", avatarSize: CGFloat = 36,
         online: Bool? = nil, onBack: (() -> Void)? = nil, backTint: Color = T.blue) {
        self.init(title: title, subtitle: subtitle, avatarId: avatarId, avatarSize: avatarSize,
                  online: online, onBack: onBack, backTint: backTint) { EmptyView() }
    }
}

/* ============ 搜索框（.srch：高 40 / 圆角 13 / 14.5px） ============ */
struct SearchBar: View {
    var placeholder = "搜索"
    var onSubmit: ((String) -> Void)? = nil
    @State private var text = ""
    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(T.hint)
            TextField(placeholder, text: $text)
                .font(.system(size: 14.5)).foregroundColor(T.ink)
                .textInputAutocapitalization(.never).disableAutocorrection(true)
                .onSubmit { onSubmit?(text) }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12).frame(height: 40)
        .background(T.searchBg)
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .padding(.horizontal, 14).padding(.bottom, 10)
    }
}

/* ============ 分组小标题（.ghead：13.5px #8A93A0） ============ */
struct GroupHead: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 13.5)).kerning(0.2).foregroundColor(T.sec)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20).padding(.top, 14).padding(.bottom, 6)
    }
}

/* ============ 行分割线 ============ */
struct RowSep: View {
    var left: CGFloat = 16
    var body: some View {
        Rectangle().fill(T.sep).frame(height: 0.5).padding(.leading, left)
    }
}

/* ============ 设置行（.row tall：min 高 52 / 15.5px / 右值 14 / 箭头） ============ */
struct SettingRow: View {
    var icon: String? = nil          // SF Symbol，配 iconColor
    var iconGrad: Int = 3            // c1-c6 圆角方块底
    var title: String
    var value = ""
    var showChevron = true
    var danger = false
    var center = false
    var titleFont: CGFloat = 15.5
    var minHeight: CGFloat = 52
    var trailing: AnyView? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            H.tap()
            action?()
        } label: {
            HStack(spacing: 10) {
                if let icon {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(LinearGradient(colors: T.icGrads[iconGrad], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 27, height: 27)
                        .overlay(Image(systemName: icon).font(.system(size: 14, weight: .semibold)).foregroundColor(.white))
                        .overlay(RoundedRectangle(cornerRadius: 9).stroke(.white.opacity(0.4), lineWidth: 0.5))
                }
                Text(title)
                    .font(.system(size: titleFont, weight: danger ? .regular : .regular))
                    .foregroundColor(danger ? T.red : T.ink)
                Spacer(minLength: 8)
                if !value.isEmpty {
                    Text(value).font(.system(size: 14)).foregroundColor(T.ter).lineLimit(1)
                }
                if let t = trailing { t }
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold)).foregroundColor(T.chevGray)
                }
            }
            .padding(.horizontal, 16).frame(minHeight: minHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle(scale: 0.99))
        .disabled(action == nil && trailing == nil)
    }
}

/* ============ 开关（.sw：46×28 / 开=渐变蓝） ============ */
struct BBSwitch: View {
    @Binding var on: Bool
    var body: some View {
        Button {
            H.sel()
            withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) { on.toggle() }
        } label: {
            ZStack(alignment: .leading) {
                Capsule().fill(on ? T.gradCTA : Color(red: 0.863, green: 0.882, blue: 0.914))
                    .frame(width: 46, height: 28)
                Circle().fill(.white)
                    .frame(width: 24, height: 24)
                    .shadow(color: .black.opacity(0.18), radius: 2.5, y: 1)
                    .offset(x: on ? 22 : 2)
            }
        }
        .buttonStyle(PressStyle(scale: 0.95))
    }
}

/* ============ 表单一行（.row tall：标签 14.5 宽 56 / 值 16） ============ */
struct FieldRow: View {
    let label: String
    @Binding var text: String
    var placeholder = ""
    var secure = false
    var keyboard: UIKeyboardType = .default
    var trailing: AnyView? = nil
    var reveal: Binding<Bool>? = nil

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 14.5)).foregroundColor(T.labelGray2)
                .frame(width: 58, alignment: .leading)
            Group {
                if secure && !(reveal?.wrappedValue ?? false) {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboard)
                }
            }
            .font(.system(size: 16))
            .foregroundColor(T.ink)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            if let t = trailing { t }
        }
        .padding(.horizontal, 16).frame(minHeight: 52)
    }
}
extension T {
    static let labelGray2 = Color(red: 0.541, green: 0.576, blue: 0.627) // #8A93A0
}

/* ============ 主按钮（.cta：高 54 / 胶囊 / 渐变 / 16.5px 600） ============ */
struct BigButton: View {
    let title: String
    var busy = false
    var disabled = false
    var height: CGFloat = 54
    let action: () -> Void
    var body: some View {
        Button {
            H.tap(.medium)
            action()
        } label: {
            Text(busy ? "请稍等…" : title)
                .font(.system(size: 16.5, weight: .semibold)).kerning(0.2)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).frame(height: height)
                .background(T.gradCTA)
                .clipShape(Capsule())
                .shadow(color: Color(red: 0.29, green: 0.545, blue: 0.965).opacity(0.32), radius: 13, y: 13)
                .opacity(disabled || busy ? 0.55 : 1)
        }
        .disabled(disabled || busy)
        .buttonStyle(PressStyle(scale: 0.98))
    }
}

/* ============ 轻按钮（.btn：白底红字 / 白底蓝字胶囊） ============ */
struct SoftButton: View {
    let title: String
    var tint = T.blue
    var action: () -> Void
    var body: some View {
        Button {
            H.tap()
            action()
        } label: {
            Text(title).font(.system(size: 15.5, weight: .medium))
                .foregroundColor(tint)
                .frame(maxWidth: .infinity).frame(height: 50)
                .background(Color.white.opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color(red: 0.329, green: 0.439, blue: 0.62).opacity(0.06), radius: 4, y: 2)
        }
        .buttonStyle(PressStyle())
    }
}

/* ============ 小提示（.tip：13.5px #8A93A0 行高 1.7） ============ */
struct TipText: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 13.5)).foregroundColor(T.sec)
            .lineSpacing(5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18).padding(.top, 8).padding(.bottom, 10)
    }
}

/* ============ 角标（.bdg：21 / 红渐变 / 13px 600） ============ */
struct BadgeNum: View {
    let n: Int
    var body: some View {
        Text(n > 99 ? "99+" : "\(n)")
            .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
            .padding(.horizontal, 5).frame(minWidth: 21, minHeight: 21)
            .background(T.gradRed)
            .clipShape(Capsule())
            .shadow(color: T.red.opacity(0.35), radius: 2, y: 1)
    }
}

/* ============ 小蓝 chip（.chip：11px / 蓝 10% 底） ============ */
struct ChipText: View {
    let text: String
    var grey = false
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold)).kerning(0.2)
            .foregroundColor(grey ? T.sec : T.blue)
            .padding(.horizontal, 6).padding(.vertical, 2.5)
            .background(grey ? Color.black.opacity(0.06) : T.blue.opacity(0.12))
            .cornerRadius(7)
    }
}

/* ============ 头像（.avw：绿点 13 / 不在线去色 55%） ============ */
struct Ava: View {
    var name = ""
    var size: CGFloat = 56
    var online: Bool? = nil
    var img: String = ""
    var isLogo = false
    private var u: URL? { isLogo ? nil : bbFileURL(img) }
    private var pick: Int {
        var h = 0
        for c in name.unicodeScalars { h = (h &* 31 &+ Int(c.value)) % 9973 }
        return h % T.avGrads.count
    }
    private var dot: CGFloat { max(12, size * 0.23) }
    private var grad: LinearGradient {
        LinearGradient(colors: T.avGrads[pick], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                if isLogo {
                    LogoMark(size: size)
                } else {
                    ZStack {
                        Circle().fill(grad)
                        Text(String(name.prefix(1)))
                            .font(.system(size: size * 0.40, weight: .semibold)).foregroundColor(.white)
                        if u != nil { NetImg(url: u).frame(width: size, height: size) }
                    }
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black.opacity(0.06), lineWidth: 0.5))
                    .saturation(online == false ? 0 : 1)
                    .opacity(online == false ? 0.55 : 1)
                }
            }
            if online == true {
                Circle().fill(T.gradGreen).frame(width: dot, height: dot)
                    .overlay(Circle().stroke(Color.white.opacity(0.95), lineWidth: 2))
            }
        }
        .frame(width: size, height: size)
    }
}

/* ============ 底部标签栏（.tab：高 64 / 白 55%+模糊 / 11.5px / 选中蓝） ============ */
struct TabBar: View {
    @Binding var sel: Int
    private let items: [(String, String, String)] = [
        ("bubble.left.and.bubble.right", "bubble.left.and.bubble.right.fill", "消息"),
        ("person.2", "person.2.fill", "通讯录"),
        ("person.crop.circle", "person.crop.circle.fill", "我"),
    ]
    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(T.sep).frame(height: 0.5)
            HStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { i in
                    Button {
                        guard sel != i else { return }
                        H.sel()
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) { sel = i }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: sel == i ? items[i].1 : items[i].0)
                                .font(.system(size: 22, weight: .regular))
                            Text(items[i].2).font(.system(size: 11.5, weight: sel == i ? .medium : .regular))
                        }
                        .foregroundColor(sel == i ? T.blue : Color(red: 0.643, green: 0.675, blue: 0.722))
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PressStyle(scale: 0.92))
                }
            }
            .padding(.top, 9).frame(height: 64, alignment: .top)
        }
        .background(
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                Rectangle().fill(Color.white.opacity(0.55))
            }
            .ignoresSafeArea(edges: .bottom)
        )
    }
}

/* ============ 导航行：往 NavigationStack 里 push 一个 Route ============ */
struct NavLinkRow: View {
    var icon: String? = nil
    var iconGrad: Int = 3
    var title: String
    var value = ""
    let route: Route
    @State private var pressed = false

    var body: some View {
        NavigationLink(value: route) {
            HStack(spacing: 10) {
                if let icon {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(LinearGradient(colors: T.icGrads[iconGrad], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 27, height: 27)
                        .overlay(Image(systemName: icon).font(.system(size: 14, weight: .semibold)).foregroundColor(.white))
                }
                Text(title).font(.system(size: 15.5)).foregroundColor(T.ink)
                Spacer(minLength: 8)
                if !value.isEmpty {
                    Text(value).font(.system(size: 14)).foregroundColor(T.ter).lineLimit(1)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(T.chevGray)
            }
            .padding(.horizontal, 16).frame(minHeight: 52)
            .contentShape(Rectangle())
            .opacity(pressed ? 0.7 : 1)
        }
        .buttonStyle(PressStyle(scale: 0.99))
    }
}

/* ============ 开关行 ============ */
struct ToggleRow: View {
    let title: String
    var note = ""
    @Binding var on: Bool
    var action: (() -> Void)? = nil   // 传了就走 action（自己改 store），不传直接翻 on

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 15.5)).foregroundColor(T.ink)
                if !note.isEmpty {
                    Text(note).font(.system(size: 13)).foregroundColor(T.sec)
                }
            }
            Spacer()
            if let action {
                BBSwitch(on: Binding(get: { on }, set: { _ in action() }))
            } else {
                BBSwitch(on: $on)
            }
        }
        .padding(.horizontal, 16).frame(minHeight: 52)
    }
}

/* ============ 分段控件（.seg） ============ */
struct Segmented: View {
    let items: [String]
    @Binding var sel: Int
    var body: some View {
        HStack(spacing: 3) {
            ForEach(items.indices, id: \.self) { i in
                Button {
                    H.sel()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { sel = i }
                } label: {
                    Text(items[i])
                        .font(.system(size: 14.5, weight: sel == i ? .semibold : .regular))
                        .foregroundColor(sel == i ? .white : T.sec)
                        .frame(maxWidth: .infinity).frame(height: 34)
                        .background(
                            Group {
                                if sel == i { Capsule().fill(T.gradCTA).shadow(color: T.blue.opacity(0.28), radius: 5, y: 3) }
                            }
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(PressStyle(scale: 0.97))
            }
        }
        .padding(3).background(Color.white.opacity(0.72))
        .clipShape(Capsule())
        .padding(.horizontal, 14).padding(.bottom, 12)
    }
}

/* ============ 空状态 ============ */
struct EmptyHint: View {
    let text: String
    var body: some View {
        VStack(spacing: 8) {
            LogoMark(size: 44).opacity(0.5)
            Text(text).font(.system(size: 14)).foregroundColor(T.tag2Gray)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 60)
    }
}
