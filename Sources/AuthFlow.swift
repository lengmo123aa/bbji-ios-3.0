import SwiftUI

/* ==================================================================
   认证流（效果图 01–05）：
   01 启动页 → 02 登录 → 03 注册 → 04 取名字；05 找回密码从登录进。
   数值照效果图 v7 的 .splash / .brandv / .tag / .tag2 / .cta / .link / .grp / .row tall 抄（字号放大 1.3）。
   ================================================================== */
enum AuthRoute { case splash, login, register, nickname, forgot }

struct AuthFlow: View {
    @EnvironmentObject var session: Session
    @AppStorage("bbji30_splash_done") private var splashDone = false
    @State private var route: AuthRoute

    init() {
        let skip = UserDefaults.standard.bool(forKey: "bbji30_splash_done") || ProcessInfo.processInfo.arguments.contains("-login")
        _route = State(initialValue: skip ? .login : .splash)
    }

    var body: some View {
        ZStack {
            switch route {
            case .splash:
                SplashScreen {
                    splashDone = true
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.88)) { route = .login }
                }
                .transition(.asymmetric(insertion: .opacity,
                                        removal: .move(edge: .bottom).combined(with: .opacity)))
            case .login:
                LoginScreen(goRegister: { route = .register }, goForgot: { route = .forgot })
                    .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                                            removal: .opacity))
            case .register:
                RegisterScreen(back: { route = .login }, done: { route = .nickname })
            case .nickname:
                NicknameScreen()
            case .forgot:
                ForgotScreen(back: { route = .login })
            }
        }
    }
}

/* ==================== 01 启动页 ==================== */
struct SplashScreen: View {
    let go: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            BrandView(logoSize: 86, titleSize: 28)
                .padding(.top, 40)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 14)

            Text("随时随地\n与重要的人聊天")
                .font(.system(size: 16)).kerning(0.3)
                .foregroundColor(T.tagGray)
                .multilineTextAlignment(.center).lineSpacing(6)
                .padding(.top, 16)
                .opacity(appeared ? 1 : 0)

            Text("更简洁 · 更流畅 · 更懂你")
                .font(.system(size: 13.5)).kerning(0.4)
                .foregroundColor(T.tag2Gray)
                .padding(.top, 12)
                .opacity(appeared ? 1 : 0)

            ZStack { GlassBlobs().scaleEffect(0.84) }
                .frame(height: 190)
                .frame(maxWidth: .infinity)
                .scaleEffect(appeared ? 1 : 0.92)
                .opacity(appeared ? 1 : 0)

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                Capsule().fill(T.blue).frame(width: 22, height: 7)
                ForEach(0..<2, id: \.self) { _ in
                    Circle().fill(Color(red: 0.824, green: 0.855, blue: 0.898)).frame(width: 7, height: 7)
                }
            }
            .padding(.bottom, 20)

            BigButton(title: "开始使用", action: go)
            Button {
                go()
            } label: {
                Text("已有账号，去登录")
                    .font(.system(size: 16)).foregroundColor(T.blue)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PressStyle())
            .padding(.top, 14).padding(.bottom, 26)
        }
        .padding(.horizontal, 28)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) { appeared = true }
        }
    }
}

/* 效果图 .glass：一个大 blob + 右上小球 + 左下小球 */
struct GlassBlobs: View {
    var body: some View {
        ZStack {
            MainBlob()
            SmallBlob(d: 86, ox: 74, oy: -57, highlight: true)
            SmallBlob(d: 60, ox: -70, oy: 70, highlight: false)
        }
        .frame(width: 238, height: 204)
    }
}

private struct SmallBlob: View {
    let d: CGFloat
    let ox: CGFloat
    let oy: CGFloat
    let highlight: Bool

    var body: some View {
        let top = Color(red: 0.894, green: 0.933, blue: 0.992)
        let bot = Color(red: 0.761, green: 0.839, blue: 0.969)
        let c = Circle()
        return c
            .fill(LinearGradient(colors: [highlight ? top : top.opacity(0.92), bot.opacity(highlight ? 0.80 : 0.68)],
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: d, height: d)
            .overlay(
                highlight
                    ? AnyView(c.stroke(.white.opacity(0.5), lineWidth: 0.5).frame(width: d, height: d))
                    : AnyView(Color.clear)
            )
            .shadow(color: Color(red: 0.494, green: 0.627, blue: 0.839).opacity(0.14), radius: 11, y: 10)
            .offset(x: ox, y: oy)
    }
}

private struct MainBlob: View {
    var body: some View {
        let blob = BlobShape()
        return blob
            .fill(LinearGradient(colors: [Color(red: 0.914, green: 0.949, blue: 0.996),
                                          Color(red: 0.694, green: 0.792, blue: 0.945)],
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 190, height: 190)
            .overlay(
                BlobShape()
                    .fill(RadialGradient(colors: [.white.opacity(0.99), .white.opacity(0.20), .white.opacity(0)],
                                         center: UnitPoint(x: 0.32, y: 0.24), startRadius: 0, endRadius: 120))
                    .frame(width: 190, height: 190)
            )
            .overlay(
                Ellipse()
                    .fill(.white.opacity(0.88))
                    .frame(width: 190 * 0.32, height: 190 * 0.22)
                    .blur(radius: 3)
                    .rotationEffect(.degrees(-18))
                    .offset(x: 190 * 0.06, y: -190 * 0.24)
            )
            .shadow(color: Color(red: 0.494, green: 0.627, blue: 0.839).opacity(0.19), radius: 19, y: 18)
    }
}

/// 效果图 o1 的不规则圆：border-radius 52% 48% 46% 54% / 56% 52% 48% 44%
struct BlobShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.maxX * 0.5, y: r.minY))
        p.addCurve(to: CGPoint(x: r.maxX, y: r.height * 0.52),
                   control1: CGPoint(x: r.maxX * 0.94, y: r.minY + r.height * 0.10),
                   control2: CGPoint(x: r.maxX, y: r.height * 0.28))
        p.addCurve(to: CGPoint(x: r.maxX * 0.46, y: r.maxY),
                   control1: CGPoint(x: r.maxX, y: r.maxY - r.height * 0.22),
                   control2: CGPoint(x: r.maxX * 0.72, y: r.maxY))
        p.addCurve(to: CGPoint(x: r.minX, y: r.height * 0.44),
                   control1: CGPoint(x: r.maxX * 0.20, y: r.maxY),
                   control2: CGPoint(x: r.minX, y: r.maxY - r.height * 0.18))
        p.addCurve(to: CGPoint(x: r.maxX * 0.5, y: r.minY),
                   control1: CGPoint(x: r.minX, y: r.minY + r.height * 0.24),
                   control2: CGPoint(x: r.maxX * 0.26, y: r.minY))
        p.closeSubpath()
        return p
    }
}

/* ==================== 02 登录 ==================== */
struct LoginScreen: View {
    @EnvironmentObject var session: Session
    let goRegister: () -> Void
    let goForgot: () -> Void
    @State private var account = ""
    @State private var password = ""
    @State private var showPwd = false

    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    BrandView(logoSize: 76, titleSize: 28)
                        .padding(.top, max(80, geo.size.height * 0.12))

                    Text("登录后开始聊天")
                        .font(.system(size: 15))
                        .foregroundColor(T.tagGray)
                        .padding(.top, 6)

                    VStack(spacing: 0) {
                        FieldRow(label: "邮箱", text: $account,
                                 placeholder: "邮箱 / BB鸡号", keyboard: .emailAddress)
                        RowSep()
                        FieldRow(label: "密码", text: $password,
                                 placeholder: "密码", secure: true,
                                 trailing: AnyView(
                                     Button {
                                         H.sel()
                                         showPwd.toggle()
                                     } label: {
                                         Image(systemName: showPwd ? "eye.slash" : "eye")
                                             .font(.system(size: 15, weight: .medium))
                                             .foregroundColor(T.sec)
                                             .padding(.leading, 6)
                                     }
                                 ),
                                 reveal: $showPwd)
                    }
                    .bbCard()
                    .padding(.top, 24)

                    if !session.err.isEmpty {
                        Text(session.err)
                            .font(.system(size: 14)).foregroundColor(T.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4).padding(.top, 10)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    BigButton(title: "登 录", busy: session.busy,
                              disabled: account.isEmpty || password.isEmpty) {
                        Task { await session.login(account: account, password: password) }
                    }
                    .padding(.top, 18)

                    Button {
                        H.tap()
                        goForgot()
                    } label: {
                        Text("忘记密码？")
                            .font(.system(size: 15.5)).foregroundColor(T.blue)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PressStyle())
                    .padding(.top, 14)

                    Spacer(minLength: 0)

                    HStack(spacing: 3) {
                        Text("还没有账号？")
                            .font(.system(size: 13.5)).foregroundColor(T.tag2Gray)
                        Text("去注册")
                            .font(.system(size: 13.5, weight: .medium)).foregroundColor(T.blue)
                    }
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 26)
                .frame(minHeight: geo.size.height, alignment: .top)
            }
            .scrollDismissesKeyboard(.interactively)
            .simultaneousGesture(TapGesture().onEnded {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            })
        }
    }
}

/* ==================== 「获取验证码」 ==================== */
struct CodeButton: View {
    let onGet: () async -> String
    let onTip: (String) -> Void
    @State private var left = 0
    @State private var busy = false
    @State private var timer: Timer? = nil

    var body: some View {
        Button {
            guard !busy, left == 0 else { return }
            busy = true
            onTip("正在发送验证码…")
            Task {
                let e = await onGet()
                busy = false
                if e.isEmpty {
                    H.ok()
                    onTip("✅ 验证码已发出，10 分钟内有效")
                    left = 60
                    timer?.invalidate()
                    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
                        left -= 1
                        if left <= 0 { t.invalidate() }
                    }
                } else {
                    H.warn()
                    onTip(e)
                }
            }
        } label: {
            Text(busy ? "发送中…" : (left > 0 ? "\(left) 秒后重发" : "获取验证码"))
                .font(.system(size: 14.5, weight: .medium))
                .foregroundColor(left > 0 || busy ? T.ter : T.blue)
                .padding(.vertical, 10).padding(.horizontal, 6)
                .contentShape(Rectangle())
        }
        .disabled(left > 0 || busy)
        .onDisappear { timer?.invalidate() }
    }
}

/* ==================== 03 注册 ==================== */
struct RegisterScreen: View {
    @EnvironmentObject var session: Session
    let back: () -> Void
    let done: () -> Void
    @State private var account = ""
    @State private var email = ""
    @State private var code = ""
    @State private var password = ""
    @State private var tip = ""

    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    NavBar(title: "", onBack: back)
                    BrandView(logoSize: 68, titleSize: 25, title: "注册 BB鸡")
                        .padding(.top, 6)

                    VStack(spacing: 0) {
                        FieldRow(label: "账号", text: $account, placeholder: "3-20 位字母数字")
                        RowSep()
                        FieldRow(label: "邮箱", text: $email, placeholder: "用于接收验证码", keyboard: .emailAddress)
                        RowSep()
                        FieldRow(label: "验证码", text: $code, placeholder: "6 位数字", keyboard: .numberPad,
                                 trailing: AnyView(codeButton))
                        RowSep()
                        FieldRow(label: "密码", text: $password, placeholder: "至少 8 位", secure: true)
                    }
                    .bbCard()
                    .padding(.top, 20)

                    if !tip.isEmpty {
                        Text(tip)
                            .font(.system(size: 13.5))
                            .foregroundColor(tip.hasPrefix("✅") ? T.green : T.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4).padding(.top, 10)
                    }
                    TipText(text: "验证码 10 分钟内有效；收不到看下垃圾箱。")

                    Spacer(minLength: 24)
                    BigButton(title: "注册", busy: session.busy,
                              disabled: account.isEmpty || email.isEmpty || code.isEmpty || password.isEmpty) {
                        Task {
                            let e = await session.register(account: account, email: email, code: code, password: password)
                            if e.isEmpty { done() } else { tip = e }
                        }
                    }
                    .padding(.bottom, 26)
                }
                .padding(.horizontal, 24)
                .frame(minHeight: geo.size.height, alignment: .top)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private var codeButton: some View {
        CodeButton(onGet: { await session.sendCode(email, scene: "register") }, onTip: { tip = $0 })
    }
}

/* ==================== 04 取名字 ==================== */
struct NicknameScreen: View {
    @EnvironmentObject var session: Session
    @State private var name = ""

    var body: some View {
        VStack(spacing: 0) {
            NavBar(title: "取个名字")
            VStack(spacing: 0) {
                Ava(name: name.isEmpty ? session.myName : name, size: 104)
                    .overlay(alignment: .bottomTrailing) {
                        Circle().fill(LinearGradient(colors: [Color(red: 0.475, green: 0.69, blue: 1.0), Color(red: 0.29, green: 0.545, blue: 0.965)],
                                                     startPoint: .top, endPoint: .bottom))
                            .frame(width: 34, height: 34)
                            .overlay(Image(systemName: "plus").font(.system(size: 15, weight: .semibold)).foregroundColor(.white))
                            .shadow(color: T.blue.opacity(0.35), radius: 5, y: 3)
                            .offset(x: 2, y: 2)
                    }
                    .padding(.top, 20)
                Text("点头像可以换一张")
                    .font(.system(size: 14.5)).foregroundColor(T.tagGray)
                    .padding(.top, 14)

                VStack(spacing: 0) {
                    FieldRow(label: "昵称", text: $name, placeholder: session.myName)
                }
                .bbCard()
                .padding(.top, 20)

                TipText(text: "以后在「我 → 我的资料」里随时能改。")
                Spacer()
                BigButton(title: "进入 BB鸡") {
                    Task { _ = await session.setNickname(name) }
                }
                .padding(.horizontal, 24).padding(.bottom, 26)
            }
        }
        .onAppear { if name.isEmpty { name = session.myName } }
    }
}

/* ==================== 05 找回密码 ==================== */
struct ForgotScreen: View {
    @EnvironmentObject var session: Session
    let back: () -> Void
    @State private var email = ""
    @State private var code = ""
    @State private var password = ""
    @State private var tip = ""

    var body: some View {
        VStack(spacing: 0) {
            NavBar(title: "找回密码", onBack: back)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        FieldRow(label: "邮箱", text: $email, placeholder: "注册时用的邮箱", keyboard: .emailAddress)
                        RowSep()
                        FieldRow(label: "验证码", text: $code, placeholder: "6 位数字", keyboard: .numberPad,
                                 trailing: AnyView(codeButton))
                        RowSep()
                        FieldRow(label: "新密码", text: $password, placeholder: "至少 8 位", secure: true)
                    }
                    .bbCard()
                    .padding(.top, 10)

                    if !tip.isEmpty {
                        Text(tip)
                            .font(.system(size: 13.5))
                            .foregroundColor(tip.hasPrefix("✅") ? T.green : T.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4).padding(.top, 10)
                    }
                    TipText(text: "验证码 10 分钟内有效；改完用新密码登录。")

                    BigButton(title: "重设密码", busy: session.busy,
                              disabled: email.isEmpty || code.isEmpty || password.isEmpty) {
                        Task {
                            let e = await session.resetPassword(email: email, code: code, password: password)
                            if e.isEmpty {
                                H.ok()
                                back()
                            } else {
                                H.warn()
                                tip = e
                            }
                        }
                    }
                    .padding(.top, 18)
                }
                .padding(.horizontal, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private var codeButton: some View {
        CodeButton(onGet: { await session.sendCode(email, scene: "reset") }, onTip: { tip = $0 })
    }
}
