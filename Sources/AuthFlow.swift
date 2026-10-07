import SwiftUI

/* ==================================================================
   认证流（效果图 01–05）：
   01 启动页 → 02 登录；03 注册 / 04 取名字 / 05 找回密码下一轮补。
   数值全部照效果图 v7 的 .splash / .brandv / .tag / .tag2 / .cta / .link 抄。
   ================================================================== */
enum AuthRoute { case splash, login }

struct AuthFlow: View {
    @AppStorage("bbji30_splash_done") private var splashDone = false
    @State private var route: AuthRoute
    /// 截图用：launch 带 -login 参数直接进登录页
    private var skipSplash: Bool {
        ProcessInfo.processInfo.arguments.contains("-login")
    }

    init() {
        _route = State(initialValue: (UserDefaults.standard.bool(forKey: "bbji30_splash_done") || ProcessInfo.processInfo.arguments.contains("-login")) ? .login : .splash)
    }

    var body: some View {
        ZStack {
            switch route {
            case .splash:
                SplashScreen {
                    splashDone = true
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.88)) { route = .login }
                }
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .move(edge: .bottom).combined(with: .opacity)))
            case .login:
                LoginScreen()
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity))
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
            BrandView(logoSize: 70)
                .padding(.top, 34)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 14)

            Text("随时随地\n与重要的人聊天")
                .font(.system(size: 13)).kerning(0.3)
                .foregroundColor(T.tagGray)
                .multilineTextAlignment(.center).lineSpacing(5)
                .padding(.top, 14)
                .opacity(appeared ? 1 : 0)

            Text("更简洁 · 更流畅 · 更懂你")
                .font(.system(size: 11)).kerning(0.4)
                .foregroundColor(T.tag2Gray)
                .padding(.top, 10)
                .opacity(appeared ? 1 : 0)

            /* 玻璃球装饰区：238×204 缩放 .84，区域高 172 */
            ZStack {
                GlassBlobs()
                    .scaleEffect(0.84)
            }
            .frame(height: 172)
            .frame(maxWidth: .infinity)
            .scaleEffect(appeared ? 1 : 0.92)
            .opacity(appeared ? 1 : 0)

            Spacer(minLength: 0)

            HStack(spacing: 7) {
                Capsule().fill(T.blue).frame(width: 18, height: 6)
                ForEach(0..<2, id: \.self) { _ in
                    Circle().fill(Color(red: 0.824, green: 0.855, blue: 0.898)).frame(width: 6, height: 6)
                }
            }
            .padding(.bottom, 18)

            BigButton(title: "开始使用", action: go)
            Button {
                go()
            } label: {
                Text("已有账号，去登录")
                    .font(.system(size: 13)).foregroundColor(T.blue)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PressStyle())
            .padding(.top, 14).padding(.bottom, 24)
        }
        .padding(.horizontal, 26)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) { appeared = true }
        }
    }
}

/* 效果图 .glass：一个大 blob + 右上小球 + 左下小球（radial 高光 + 内阴影，这里用渐变逼近） */
struct GlassBlobs: View {
    var body: some View {
        ZStack {
            /* o1：190×190 的主 blob（不规则圆，用两轴缩放的椭圆近似） */
            BlobShape()
                .frame(width: 190, height: 190)
                .background(
                    ZStack {
                        LinearGradient(colors: [Color(red: 0.863, green: 0.914, blue: 0.988).opacity(0.97),
                                                Color(red: 0.706, green: 0.800, blue: 0.949).opacity(0.84)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                        RadialGradient(colors: [Color(red: 0.557, green: 0.706, blue: 0.933).opacity(0.88),
                                                Color(red: 0.737, green: 0.824, blue: 0.965).opacity(0.52),
                                                .white.opacity(0)],
                                       center: UnitPoint(x: 0.68, y: 0.74), startRadius: 0, endRadius: 160)
                        RadialGradient(colors: [.white.opacity(0.99), .white.opacity(0.20), .white.opacity(0)],
                                       center: UnitPoint(x: 0.32, y: 0.24), startRadius: 0, endRadius: 120)
                    }
                )
                .clipShape(BlobShape())
                .shadow(color: Color(red: 0.494, green: 0.627, blue: 0.839).opacity(0.19), radius: 19, y: 18)
                .overlay(
                    /* o1 的高光条 */
                    Ellipse()
                        .fill(.white.opacity(0.88))
                        .frame(width: 190 * 0.32, height: 190 * 0.22)
                        .blur(radius: 3)
                        .rotationEffect(.degrees(-18))
                        .offset(x: 190 * 0.06, y: -190 * 0.24)
                )

            /* o2：右上小球 86 */
            Circle()
                .frame(width: 86, height: 86)
                .foregroundStyle(
                    LinearGradient(colors: [Color(red: 0.894, green: 0.933, blue: 0.992).opacity(0.95),
                                            Color(red: 0.761, green: 0.839, blue: 0.969).opacity(0.80)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .overlay(Circle().stroke(.white.opacity(0.5), lineWidth: 0.5))
                .shadow(color: Color(red: 0.494, green: 0.627, blue: 0.839).opacity(0.15), radius: 12, y: 11)
                .offset(x: (238 / 2) - (86 / 2) - 2, y: -(204 / 2) + (86 / 2) + 2)

            /* o3：左下小球 60 */
            Circle()
                .frame(width: 60, height: 60)
                .foregroundStyle(
                    LinearGradient(colors: [Color(red: 0.941, green: 0.961, blue: 0.992).opacity(0.92),
                                            Color(red: 0.831, green: 0.890, blue: 0.973).opacity(0.68)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .shadow(color: Color(red: 0.494, green: 0.627, blue: 0.839).opacity(0.13), radius: 10, y: 9)
                .offset(x: -(238 / 2) + (60 / 2) + 2, y: (204 / 2) - (60 / 2) - 2)
        }
        .frame(width: 238, height: 204)
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
    @State private var account = ""
    @State private var password = ""
    @State private var showPwd = false

    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    BrandView(logoSize: 62)
                        .padding(.top, max(70, geo.size.height * 0.11))

                    Text("登录后开始聊天")
                        .font(.system(size: 12.5))
                        .foregroundColor(T.tagGray)
                        .padding(.top, 4)

                    /* 表单卡（.grp：radius 13，行 min 高 44） */
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
                                             .font(.system(size: 13, weight: .medium))
                                             .foregroundColor(T.sec)
                                             .padding(.leading, 6)
                                     }
                                 ),
                                 reveal: $showPwd)
                    }
                    .bbCard()
                    .padding(.top, 22)

                    if !session.err.isEmpty {
                        Text(session.err)
                            .font(.system(size: 12)).foregroundColor(T.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 2).padding(.top, 10)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    BigButton(title: "登 录", busy: session.busy,
                              disabled: account.isEmpty || password.isEmpty) {
                        Task { await session.login(account: account, password: password) }
                    }
                    .padding(.top, 16)

                    Button {
                        /* 05 找回密码下一轮 */
                        H.tap()
                        session.err = "找回密码下一轮做（先直接登录）"
                    } label: {
                        Text("忘记密码？")
                            .font(.system(size: 13)).foregroundColor(T.blue)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PressStyle())
                    .padding(.top, 12)

                    Spacer(minLength: 0)

                    HStack(spacing: 2) {
                        Text("还没有账号？")
                            .font(.system(size: 11)).foregroundColor(T.tag2Gray)
                        Text("去注册")
                            .font(.system(size: 11, weight: .medium)).foregroundColor(T.blue)
                    }
                    .padding(.bottom, 22)
                }
                .padding(.horizontal, 24)
                .frame(minHeight: geo.size.height, alignment: .top)
            }
            .scrollDismissesKeyboard(.interactively)
            .simultaneousGesture(TapGesture().onEnded { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) })
        }
    }
}
