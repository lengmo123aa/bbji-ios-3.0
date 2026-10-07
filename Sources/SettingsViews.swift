import SwiftUI

/* ==================================================================
   设置（41-43 48-55）+ 锁定流程（44-47）+ 锁定覆盖层
   ================================================================== */

/* ==================== 41 设置主页 ==================== */
struct SettingsHomeView: View {
    @EnvironmentObject var session: Session
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "设置", onBack: { dismiss() })
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        NavLinkRow(icon: "person", iconGrad: 3, title: "账号与安全", route: .account)
                        RowSep(left: 47)
                        NavLinkRow(icon: "bell", iconGrad: 2, title: "消息通知", route: .notify)
                        RowSep(left: 47)
                        NavLinkRow(icon: "lock", iconGrad: 0, title: "隐私与锁定", route: .privacy)
                        RowSep(left: 47)
                        NavLinkRow(icon: "antenna.radiowaves.left.and.right", iconGrad: 5, title: "后台保活", route: .keepAlive)
                        RowSep(left: 47)
                        NavLinkRow(icon: "gearshape", iconGrad: 4, title: "通用", route: .general)
                        RowSep(left: 47)
                        NavLinkRow(icon: "questionmark.circle", iconGrad: 1, title: "帮助与反馈", route: .help)
                        RowSep(left: 47)
                        NavLinkRow(icon: "info.circle", iconGrad: 3, title: "关于我们", route: .about)
                    }
                    .bbCard()
                    .padding(.horizontal, 14).padding(.top, 4)
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

/* ==================== 42 账号与安全 ==================== */
struct AccountView: View {
    @EnvironmentObject var session: Session
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var confirmOut = false

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "账号与安全", onBack: { dismiss() })
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            Ava(name: store.meName, size: 40, img: store.myAvatar)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(store.meName).font(.system(size: 16, weight: .semibold)).foregroundColor(T.ink)
                                Text("登录账号 \(store.meId)").font(.system(size: 13)).foregroundColor(T.sec)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(T.chevGray)
                        }
                        .padding(.horizontal, 16).frame(minHeight: 60)
                        RowSep()
                        SettingRow(title: "BB鸡号", value: store.meId, showChevron: false)
                    }
                    .bbCard()
                    .padding(.horizontal, 14).padding(.top, 4).padding(.bottom, 12)

                    VStack(spacing: 0) {
                        SettingRow(title: "绑定邮箱", value: store.myEmail, showChevron: false)
                        RowSep()
                        SettingRow(title: "修改密码", value: "用找回密码改") { }
                        RowSep()
                        SettingRow(title: "登录设备", value: "这台手机") { }
                    }
                    .bbCard()
                    .padding(.horizontal, 14).padding(.bottom, 12)

                    VStack(spacing: 0) {
                        SettingRow(title: "退出登录", danger: true, showChevron: false) { confirmOut = true }
                    }
                    .bbCard()
                    .padding(.horizontal, 14)
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("退出后要重新登录才能进来", isPresented: $confirmOut, titleVisibility: .visible) {
            Button("退出登录", role: .destructive) {
                session.logout()
            }
            Button("取消", role: .cancel) { }
        }
    }
}

/* ==================== 43 隐私与锁定 ==================== */
struct PrivacyView: View {
    @EnvironmentObject var session: Session
    @Environment(\.dismiss) private var dismiss
    @AppStorage("bbji30_lock_on") private var lockOn = false
    @AppStorage("bbji30_lock_pw") private var lockPw = ""
    @AppStorage("bbji30_calc_disguise") private var calcDisguise = false
    @AppStorage("bbji30_lock_bio") private var allowBio = true

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "隐私与锁定", onBack: { dismiss() })
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        ToggleRow(title: "离开就锁", note: "切到后台 / 关掉屏幕就要求密码", on: $lockOn)
                        RowSep()
                        NavLinkRow(title: "锁定密码", value: lockPw.isEmpty ? "没设置" : "已设置（\(lockPw.count) 位）", route: .lockSetPw)
                        RowSep()
                        SettingRow(title: "锁定规则", value: "锁上之后") { }
                    }
                    .bbCard()
                    .padding(.horizontal, 14).padding(.top, 4).padding(.bottom, 12)

                    VStack(spacing: 0) {
                        ToggleRow(title: "计算器伪装锁", note: "锁屏长得就是个普通计算器", on: $calcDisguise)
                        RowSep()
                        ToggleRow(title: "允许面容 / 指纹解锁", on: $allowBio)
                    }
                    .bbCard()
                    .padding(.horizontal, 14).padding(.bottom, 12)

                    TipText(text: "锁上之后：中间是 logo，点「解锁」输 4 位密码才能进来。不挡系统截屏（锁着本来就看不到内容）。")

                    VStack(spacing: 0) {
                        SettingRow(title: "立刻锁定", danger: true, showChevron: false) {
                            if lockPw.isEmpty {
                                session.lockMsg = "先设置 4 位锁定密码"
                                H.warn()
                            } else {
                                session.locked = true
                            }
                        }
                    }
                    .bbCard()
                    .padding(.horizontal, 14)
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .overlay {
            if session.locked { LockOverlay().zIndex(50) }
        }
    }
}

/* ==================== 44 设置锁定密码（4 位数字盘） ==================== */
struct LockSetPwView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("bbji30_lock_pw") private var lockPw = ""
    @State private var first = ""
    @State private var digits = ""
    @State private var stage = 0   // 0=第一次输 1=确认

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.353, green: 0.42, blue: 0.549),
                                    Color(red: 0.2, green: 0.251, blue: 0.361),
                                    Color(red: 0.118, green: 0.149, blue: 0.204)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                NavBar(title: "设置锁定密码", onBack: { dismiss() }, backTint: .white)
                Text(stage == 0 ? "设置 4 位数字密码" : "再输一遍确认")
                    .font(.system(size: 19, weight: .semibold)).foregroundColor(.white)
                    .padding(.top, 16)
                Text("不能和账号密码一样，忘了只能清数据")
                    .font(.system(size: 13.5)).foregroundColor(.white.opacity(0.62))
                    .padding(.top, 8)
                Dots4(count: digits.count)
                    .padding(.top, 30)
                Spacer()
                Keypad { k in tap(k) } onDel: { if !digits.isEmpty { digits.removeLast() } }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func tap(_ k: Int) {
        guard digits.count < 4 else { return }
        H.tap(.light)
        digits.append(String(k))
        if digits.count == 4 {
            if stage == 0 {
                first = digits
                stage = 1
                digits = ""
            } else if digits == first {
                lockPw = digits
                H.ok()
                dismiss()
            } else {
                H.warn()
                stage = 0
                first = ""
                digits = ""
            }
        }
    }
}

/* 4 位进度点（.dots6 改 4 位） */
struct Dots4: View {
    let count: Int
    var body: some View {
        HStack(spacing: 14) {
            ForEach(0..<4, id: \.self) { i in
                Circle()
                    .strokeBorder(.white.opacity(0.72), lineWidth: 1.6)
                    .background(Circle().fill(i < count ? Color.white : .clear))
                    .frame(width: 14, height: 14)
            }
        }
    }
}

/* 数字键盘（.keys：3 列 / 圆 / 白 14%） */
struct Keypad: View {
    let onTap: (Int) -> Void
    var onDel: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 14) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 24) {
                    ForEach(1...3, id: \.self) { col in
                        key(row * 3 + col)
                    }
                }
            }
            HStack(spacing: 24) {
                Text("").frame(width: 74, height: 74)
                key(0)
                if let onDel {
                    Button {
                        H.tap()
                        onDel()
                    } label: {
                        Image(systemName: "delete.left")
                            .font(.system(size: 22)).foregroundColor(.white.opacity(0.85))
                            .frame(width: 74, height: 74)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PressStyle())
                } else {
                    Text("").frame(width: 74, height: 74)
                }
            }
        }
        .padding(.bottom, 14)
    }

    private func key(_ k: Int) -> some View {
        Button {
            onTap(k)
        } label: {
            Text("\(k)")
                .font(.system(size: 27, weight: .light)).foregroundColor(.white)
                .frame(width: 74, height: 74)
                .background(Color.white.opacity(0.14))
                .clipShape(Circle())
                .contentShape(Circle())
        }
        .buttonStyle(PressStyle(scale: 0.93))
    }
}

/* ==================== 45 锁定规则 ==================== */
struct LockRulesView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("bbji30_lock_on") private var lockOn = true
    @AppStorage("bbji30_lock_bio") private var allowBio = true
    @AppStorage("bbji30_notify_hide") private var hideNotify = true
    @AppStorage("bbji30_lock_call") private var allowCall = true

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "锁定规则", onBack: { dismiss() })
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 0) {
                        ToggleRow(title: "离开就锁", note: "开了＝关掉页面就锁；关了＝任何情况都不锁", on: $lockOn)
                    }
                    .bbCard()
                    .padding(.horizontal, 14).padding(.top, 4)

                    GroupHead(text: "锁上之后")
                    VStack(spacing: 0) {
                        ToggleRow(title: "立刻要求密码", on: $lockOn)
                        RowSep()
                        ToggleRow(title: "允许面容 / 指纹", on: $allowBio)
                        RowSep()
                        ToggleRow(title: "锁定时通知不显示内容", on: $hideNotify)
                        RowSep()
                        ToggleRow(title: "锁屏时能接来电", on: $allowCall)
                    }
                    .bbCard()
                    .padding(.horizontal, 14)

                    TipText(text: "关了「离开就锁」也可以随时手动锁：设置 → 隐私与锁定 → 立刻锁定。")
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

/* ==================== 46 锁定覆盖层（锁屏） ==================== */
struct LockOverlay: View {
    @EnvironmentObject var session: Session
    @AppStorage("bbji30_lock_pw") private var lockPw = ""
    @AppStorage("bbji30_calc_disguise") private var calcDisguise = false
    @AppStorage("bbji30_lock_bio") private var allowBio = true
    @State private var digits = ""
    @State private var wrong = false
    @State private var date = Date()

    var body: some View {
        if calcDisguise {
            CalcLockView()
        } else {
            lockScreen
        }
    }

    private var lockScreen: some View {
        let grad = LinearGradient(colors: [Color(red: 0.353, green: 0.42, blue: 0.549),
                                           Color(red: 0.2, green: 0.251, blue: 0.361),
                                           Color(red: 0.118, green: 0.149, blue: 0.204)],
                                  startPoint: .top, endPoint: .bottom)
        return ZStack {
            grad.ignoresSafeArea()
            VStack(spacing: 0) {
                Text(timeStr)
                    .font(.system(size: 15)).foregroundColor(.white.opacity(0.72))
                    .padding(.top, 14)
                Ava(name: session.myName.isEmpty ? "B" : session.myName, size: 96, img: session.myAvatar)
                    .shadow(color: .white.opacity(0.12), radius: 4)
                    .padding(.top, 36)
                Text(session.myName.isEmpty ? "BB鸡" : session.myName)
                    .font(.system(size: 17)).foregroundColor(.white)
                    .padding(.top, 14)
                VStack(spacing: 10) {
                    Text(wrong ? "密码不对，再试试" : "输入锁定密码")
                        .font(.system(size: 23, weight: .semibold))
                        .foregroundColor(wrong ? Color(red: 1.0, green: 0.42, blue: 0.357) : .white)
                    Dots4(count: digits.count)
                }
                .padding(.top, 34)
                Spacer()
                Keypad { k in
                    guard digits.count < 4 else { return }
                    H.tap(.light)
                    digits.append(String(k))
                    if digits.count == 4 {
                        if digits == lockPw {
                            H.ok()
                            session.locked = false
                        } else {
                            H.warn()
                            wrong = true
                            digits = ""
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { wrong = false }
                        }
                    }
                } onDel: {
                    if !digits.isEmpty { digits.removeLast() }
                }
                Text(allowBio ? "面容 / 指纹 · 忘记密码？" : "忘记密码？")
                    .font(.system(size: 14)).foregroundColor(.white.opacity(0.72))
                    .padding(.bottom, 26)
            }
        }
    }

    private var timeStr: String {
        let f = DateFormatter()
        f.dateFormat = "M月d日 EEEE HH:mm"
        f.locale = Locale(identifier: "zh_CN")
        return f.string(from: date)
    }
}

/* ==================== 47 计算器伪装锁 ==================== */
struct CalcLockView: View {
    @EnvironmentObject var session: Session
    @AppStorage("bbji30_lock_pw") private var lockPw = ""
    @State private var shown = "1234"

    private let rows: [[String]] = [
        ["AC", "±", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "−"],
        ["1", "2", "3", "+"],
        ["0", ".", "="],
    ]

    var body: some View {
        ZStack {
            Color(red: 0.067, green: 0.078, blue: 0.09).ignoresSafeArea()
            VStack(spacing: 0) {
                Text(shown)
                    .font(.system(size: 52, weight: .light)).kerning(-1)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 18).padding(.top, 40).padding(.bottom, 16)
                VStack(spacing: 10) {
                    ForEach(rows, id: \.self) { row in
                        HStack(spacing: 10) {
                            ForEach(row, id: \.self) { k in
                                keyCell(k)
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                Text("这看着就是个普通计算器 —— 输对密码才会进 BB鸡")
                    .font(.system(size: 12)).foregroundColor(Color(red: 0.431, green: 0.459, blue: 0.494))
                    .padding(.vertical, 10)
            }
        }
    }

    private func keyColor(_ k: String) -> Color {
        if ["÷", "×", "−", "+", "="].contains(k) { return T.orange }
        if ["AC", "±", "%"].contains(k) { return Color(red: 0.945, green: 0.945, blue: 0.945) }
        return Color(red: 0.173, green: 0.173, blue: 0.18)
    }
    private func keyText(_ k: String) -> Color {
        return ["AC", "±", "%"].contains(k) ? Color(red: 0.067, green: 0.078, blue: 0.09) : .white
    }

    private func keyCell(_ k: String) -> some View {
        Button {
            H.tap(.light)
            press(k)
        } label: {
            Text(k)
                .font(.system(size: 24, weight: .regular)).foregroundColor(keyText(k))
                .frame(maxWidth: .infinity)
                .frame(height: 66)
                .background(keyColor(k))
                .clipShape(k == "0" ? RoundedRectangle(cornerRadius: 40, style: .continuous) : Circle())
                .frame(maxWidth: k == "0" ? .infinity : nil)
                .gridCellColumns(k == "0" ? 2 : 1)
        }
        .buttonStyle(PressStyle(scale: 0.94))
    }

    private func press(_ k: String) {
        switch k {
        case "AC": shown = "0"
        case "0"..."9":
            if digitsCount < 4 { shown = shown == "0" ? k : shown + k }
            if digitsCount == 4 && shown == lockPw { H.ok(); session.locked = false }
        case "=":
            if shown == lockPw {
                H.ok()
                session.locked = false
            } else if lockPw.isEmpty {
                session.locked = false   // 没设过密码就不锁
            } else {
                H.warn()
                shown = "0"
            }
        default: break
        }
    }

    private var digitsCount: Int { shown.filter { $0.isNumber }.count }
}

/* ==================== 48 消息通知 ==================== */
struct NotifyView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("bbji30_nt_main") private var main = true
    @AppStorage("bbji30_nt_sound") private var sound = true
    @AppStorage("bbji30_nt_vib") private var vib = true
    @AppStorage("bbji30_nt_screen") private var onlyScreen = false

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "消息通知", onBack: { dismiss() })
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 0) {
                        ToggleRow(title: "新消息通知", on: $main)
                        RowSep()
                        ToggleRow(title: "声音", on: $sound)
                        RowSep()
                        ToggleRow(title: "震动", on: $vib)
                        RowSep()
                        ToggleRow(title: "只在屏幕亮着时提醒", on: $onlyScreen)
                    }
                    .bbCard()
                    .padding(.horizontal, 14).padding(.top, 4)

                    GroupHead(text: "提醒什么")
                    VStack(spacing: 0) {
                        SettingRow(title: "全部消息", showChevron: false) { }
                            .overlay(alignment: .trailing) {
                                Image(systemName: "checkmark").font(.system(size: 14, weight: .semibold)).foregroundColor(T.blue).padding(.trailing, 16)
                            }
                        RowSep()
                        SettingRow(title: "只提醒 @我") { }
                        RowSep()
                        SettingRow(title: "群消息", value: "接收但不出声") { }
                    }
                    .bbCard()
                    .padding(.horizontal, 14)

                    GroupHead(text: "推送怎么发到手机")
                    VStack(spacing: 0) {
                        NavLinkRow(icon: "waveform", iconGrad: 5, title: "推送正文样式", route: .pushStyle)
                        RowSep(left: 47)
                        NavLinkRow(icon: "bell.badge", iconGrad: 3, title: "推送 API（Bark）", route: .pushAPI)
                        RowSep(left: 47)
                        NavLinkRow(icon: "book", iconGrad: 1, title: "Bark 配置教程", route: .barkGuide)
                    }
                    .bbCard()
                    .padding(.horizontal, 14)
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

/* ==================== 49 后台保活 ==================== */
struct KeepAliveView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("bbji30_ka_main") private var main = true
    @AppStorage("bbji30_ka_ring") private var ring = true
    @AppStorage("bbji30_ka_music") private var music = true

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "后台保活", onBack: { dismiss() })
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 0) {
                        ToggleRow(title: "后台保活", note: "开着更实时：来电直接弹、消息秒到；代价是费电", on: $main)
                    }
                    .bbCard()
                    .padding(.horizontal, 14).padding(.top, 4)

                    GroupHead(text: "保活用的通道")
                    VStack(spacing: 0) {
                        ToggleRow(title: "语音通话后台响铃", on: $ring)
                        RowSep()
                        ToggleRow(title: "无声音乐保活", on: $music)
                    }
                    .bbCard()
                    .padding(.horizontal, 14)

                    TipText(text: "实话：iOS 切后台约 30 秒会被挂起，保活只能延长、不可能常驻 —— 所以必须「保活 + 推送」两套一起用。")
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

/* ==================== 50 推送正文样式 ==================== */
struct PushStyleView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("bbji30_push_style") private var style = 0

    private let opts: [(String, String)] = [
        ("显示全部", "标题＝谁发的，正文＝内容"),
        ("只显示有新消息", "不写谁、不写内容"),
        ("只显示谁发的", "写名字，不写内容"),
    ]

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "推送正文样式", onBack: { dismiss() })
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 0) {
                        ForEach(opts.indices, id: \.self) { i in
                            Button {
                                H.sel()
                                style = i
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(opts[i].0).font(.system(size: 15.5)).foregroundColor(T.ink)
                                        Text(opts[i].1).font(.system(size: 13)).foregroundColor(T.sec)
                                    }
                                    Spacer()
                                    Image(systemName: style == i ? "checkmark" : "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(style == i ? T.blue : T.chevGray)
                                }
                                .padding(.horizontal, 16).frame(minHeight: 56)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PressStyle(scale: 0.99))
                            if i < opts.count - 1 { RowSep() }
                        }
                    }
                    .bbCard()
                    .padding(.horizontal, 14)

                    GroupHead(text: "效果预览")
                    VStack(alignment: .leading, spacing: 6) {
                        Text("BB鸡 · 刚刚").font(.system(size: 13.5)).foregroundColor(T.sec)
                        Text(style == 2 ? "有新消息" : "星皓").font(.system(size: 15.5, weight: .semibold)).foregroundColor(T.ink)
                        Text(style == 0 ? "看我给你发的微信" : (style == 1 ? "有新消息" : "[消息]"))
                            .font(.system(size: 15)).foregroundColor(T.ink2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.white.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: Color(red: 0.06, green: 0.13, blue: 0.25).opacity(0.06), radius: 6, y: 4)
                    .padding(.horizontal, 14)
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

/* ==================== 51 推送 API（Bark） ==================== */
struct PushAPIView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("bbji30_bark_key") private var barkKey = ""
    @State private var keyDraft = ""
    @State private var toast = ""

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "推送 API", onBack: { dismiss() })
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        SettingRow(title: "推送通道", value: "Bark（自签 / 非巨魔）", showChevron: false)
                        RowSep()
                        SettingRow(title: "服务器地址", value: "bbji.xkmd.cn", showChevron: false)
                        RowSep()
                        HStack(spacing: 12) {
                            Text("Bark Key").font(.system(size: 15.5)).foregroundColor(T.ink)
                            Spacer()
                            TextField("从 Bark App 里复制", text: $keyDraft)
                                .font(.system(size: 14)).foregroundColor(T.ink)
                                .multilineTextAlignment(.trailing)
                                .textInputAutocapitalization(.never).disableAutocorrection(true)
                                .frame(maxWidth: 170)
                        }
                        .padding(.horizontal, 16).frame(minHeight: 52)
                    }
                    .bbCard()
                    .padding(.horizontal, 14).padding(.top, 4)

                    BigButton(title: "保存并测试", height: 50) {
                        barkKey = keyDraft.trimmingCharacters(in: .whitespaces)
                        toast = barkKey.isEmpty ? "先填 Bark Key" : "已保存（测试推送演示）"
                        H.ok()
                    }
                    .padding(.horizontal, 14).padding(.top, 14)

                    TipText(text: "保存后会立刻给你发一条测试推送，收到就说明通了。")

                    Button {
                        H.tap()
                    } label: {
                        Text("Bark 配置教程 ›").font(.system(size: 15.5)).foregroundColor(T.blue)
                    }
                    .buttonStyle(PressStyle())
                    .padding(.top, 16)
                }
                .padding(.bottom, 30)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { keyDraft = barkKey }
    }
}

/* ==================== 52 Bark 配置教程 ==================== */
struct BarkGuideView: View {
    @Environment(\.dismiss) private var dismiss

    private let steps: [(String, String, String)] = [
        ("1", "App Store 搜 Bark 装上", "不用注册，打开就有 Key"),
        ("2", "把 Key 复制到 BB鸡", "设置 → 消息通知 → 推送 API"),
        ("3", "点「保存并测试」", "手机上马上会收到一条测试推送"),
    ]

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "Bark 配置教程", onBack: { dismiss() })
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Bark 配置教程")
                        .font(.system(size: 27, weight: .bold)).kerning(-0.8).foregroundColor(T.ink)
                        .padding(.horizontal, 18).padding(.top, 4)
                    Text("三步搞定，不用越狱")
                        .font(.system(size: 14.5)).foregroundColor(T.sec)
                        .padding(.horizontal, 18).padding(.top, 6)

                    VStack(alignment: .leading, spacing: 18) {
                        ForEach(steps, id: \.0) { s in
                            HStack(alignment: .top, spacing: 13) {
                                Circle().fill(T.gradCTA)
                                    .frame(width: 26, height: 26)
                                    .overlay(Text(s.0).font(.system(size: 14, weight: .bold)).foregroundColor(.white))
                                    .shadow(color: T.blue.opacity(0.3), radius: 4, y: 2)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(s.1).font(.system(size: 16, weight: .semibold)).foregroundColor(T.ink)
                                    Text(s.2).font(.system(size: 13.5)).foregroundColor(T.sec)
                                }
                            }
                        }
                    }
                    .padding(18)

                    Text("收不到？按这四条查")
                        .font(.system(size: 15, weight: .semibold)).foregroundColor(T.ink)
                        .padding(.horizontal, 18)
                    Text("① Bark 的通知权限是不是关了\n② Key 有没有多复制了空格\n③ 手机当时有没有网\n④ 后台保活开了没（关了会延迟）")
                        .font(.system(size: 14.5)).foregroundColor(Color(red: 0.494, green: 0.529, blue: 0.588))
                        .lineSpacing(8)
                        .padding(.horizontal, 18).padding(.top, 8)

                    Text("教程是从服务器拉的，改内容不用更新 App")
                        .font(.system(size: 13)).foregroundColor(T.tag2Gray)
                        .padding(.horizontal, 18).padding(.top, 16)
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

/* ==================== 53 通用设置 ==================== */
struct GeneralView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "通用设置", onBack: { dismiss() })
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        SettingRow(title: "主题", value: "跟随系统") { }
                        RowSep()
                        SettingRow(title: "字号", value: "标准（已调大）") { }
                        RowSep()
                        SettingRow(title: "聊天背景") { }
                    }
                    .bbCard()
                    .padding(.horizontal, 14).padding(.top, 4).padding(.bottom, 12)

                    VStack(spacing: 0) {
                        SettingRow(title: "自动下载图片", value: "仅 Wi-Fi") { }
                        RowSep()
                        SettingRow(title: "清空缓存", value: cacheText) {
                            URLCache.shared.removeAllCachedResponses()
                            ImgStore.shared = ImgStore()
                            H.ok()
                        }
                    }
                    .bbCard()
                    .padding(.horizontal, 14)
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var cacheText: String {
        let b = URLCache.shared.currentDiskUsage
        return ByteCountFormatter.string(fromByteCount: Int64(b), countStyle: .file)
    }
}

/* ==================== 54 帮助与反馈 ==================== */
struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "帮助与反馈", onBack: { dismiss() })
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 0) {
                        SettingRow(title: "常见问题") { }
                        RowSep()
                        SettingRow(title: "联系官方（发消息）") { }
                        RowSep()
                        SettingRow(title: "我是开发者 / 想部署服务器") { }
                    }
                    .bbCard()
                    .padding(.horizontal, 14).padding(.top, 4)

                    GroupHead(text: "我提过的")
                    VStack(spacing: 0) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("「希望手机端也能看到已读」")
                                    .font(.system(size: 15)).foregroundColor(T.ink)
                                Text("官方回复：这版已经有啦")
                                    .font(.system(size: 13)).foregroundColor(Color(red: 0.043, green: 0.604, blue: 0.341))
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 16).padding(.vertical, 14)
                    }
                    .bbCard()
                    .padding(.horizontal, 14)

                    SoftButton(title: "写点反馈") { }
                        .padding(.horizontal, 14).padding(.top, 14)
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

/* ==================== 55 关于我们 ==================== */
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "关于我们", onBack: { dismiss() })
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        LogoMark(size: 84)
                        Text("BB鸡").font(.system(size: 20, weight: .bold)).foregroundColor(T.ink).padding(.top, 12)
                        Text("iOS 版 · v3.0.0（1）")
                            .font(.system(size: 14.5)).foregroundColor(T.sec).padding(.top, 5)
                    }
                    .padding(.vertical, 26)

                    VStack(spacing: 0) {
                        SettingRow(title: "检查更新", value: "已是最新") { }
                        RowSep()
                        SettingRow(title: "历史公告", value: "3 条") { }
                        RowSep()
                        SettingRow(title: "隐私政策") { }
                    }
                    .bbCard()
                    .padding(.horizontal, 14)

                    Text("© 2026 BB鸡 · 手机端")
                        .font(.system(size: 13)).foregroundColor(T.tag2Gray)
                        .padding(.top, 18)
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
