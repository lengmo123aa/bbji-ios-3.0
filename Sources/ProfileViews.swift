import SwiftUI
import PhotosUI

/* ==================================================================
   资料 / 新建聊天 / 加好友 / 扫一扫 / 选人（效果图 21 22 23 24 25 26 59）
   ================================================================== */

/* ==================== 21 好友资料 ==================== */
struct FriendProfileView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let userId: String
    @State private var moreMenu = false
    @State private var callState: CallState? = nil
    @State private var editingRemark = false
    @State private var remark = ""

    private var p: Person? { store.people[userId] }
    private var burn: Binding<Bool> {
        Binding(get: { store.burn.contains(userId) }, set: { _ in store.toggleBurn(userId) })
    }

    var body: some View {
        AppBg()
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    /* 资料头（.prof：头像 104 + 名字 22/700） */
                    VStack(spacing: 0) {
                        Ava(name: p?.display ?? "", size: 104, online: p?.online, img: p?.avatar ?? "")
                            .padding(.top, 8)
                        Text(p?.display ?? userId)
                            .font(.system(size: 22, weight: .bold)).kerning(-0.5)
                            .foregroundColor(T.ink).padding(.top, 12)
                        Text("BB鸡号 \(p?.bbji.isEmpty == false ? p!.bbji : userId)")
                            .font(.system(size: 13.5)).foregroundColor(T.sec).padding(.top, 5)
                    }
                    .padding(.bottom, 14)

                    /* 四个操作块（.acts） */
                    HStack(spacing: 11) {
                        actItem("phone", "语音通话") { callState = .voiceOut }
                        actItem("video", "视频通话") { callState = .video }
                        actItem("magnifyingglass", "搜索") { }
                        actItem("ellipsis", "更多") { withAnimation { moreMenu = true } }
                    }
                    .padding(.horizontal, 14).padding(.bottom, 14)

                    VStack(spacing: 0) {
                        SettingRow(title: "备注", value: p?.remark.isEmpty == false ? p!.remark : "未设置") {
                            remark = p?.remark ?? ""
                            editingRemark = true
                        }
                        RowSep()
                        SettingRow(title: "共同群聊", value: "\(store.groups.count) 个", showChevron: false)
                    }
                    .bbCard()
                    .padding(.horizontal, 14).padding(.bottom, 12)

                    VStack(spacing: 0) {
                        ToggleRow(title: "免打扰", on: .constant(store.muted.contains(userId))) { store.toggleMute(userId) }
                        RowSep()
                        ToggleRow(title: "消息通知", on: .constant(!store.muted.contains(userId))) { store.toggleMute(userId) }
                        RowSep()
                        ToggleRow(title: "阅后即焚", on: burn) { store.toggleBurn(userId) }
                    }
                    .bbCard()
                    .padding(.horizontal, 14).padding(.bottom, 12)

                    VStack(spacing: 0) {
                        SettingRow(title: "清空聊天记录") { }
                        RowSep()
                        SettingRow(title: "删除联系人", showChevron: false, danger: true) {
                            H.warn()
                            store.delFriend(id: userId)
                            dismiss()
                        }
                    }
                    .bbCard()
                    .padding(.horizontal, 14)
                }
                .padding(.bottom, 40)
            }

            /* 22 更多菜单 */
            if moreMenu {
                Color.black.opacity(0.18).ignoresSafeArea()
                    .onTapGesture { withAnimation { moreMenu = false } }
                    .zIndex(5)
                VStack(spacing: 0) {
                    menuRow("textformat", "设置备注") {
                        moreMenu = false
                        remark = p?.remark ?? ""
                        editingRemark = true
                    }
                    RowSep(left: 44)
                    menuRow("bell.slash", "加入黑名单") { moreMenu = false; H.warn() }
                    RowSep(left: 44)
                    menuRow("info.circle", "投诉") { moreMenu = false }
                    RowSep(left: 44)
                    menuRow("trash", "删除联系人", danger: true) {
                        moreMenu = false
                        store.delFriend(id: userId)
                        dismiss()
                    }
                }
                .frame(width: 226)
                .background(Color.white.opacity(0.97))
                .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                .shadow(color: Color(red: 0.06, green: 0.13, blue: 0.25).opacity(0.2), radius: 20, y: 16)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 24).padding(.top, 52)
                .zIndex(6)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .top) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").font(.system(size: 19, weight: .semibold)).foregroundColor(T.blue)
                        .frame(width: 34, alignment: .leading)
                }
                .buttonStyle(PressStyle())
                Spacer()
                Button { withAnimation { moreMenu = true } } label: {
                    Image(systemName: "ellipsis").font(.system(size: 18)).foregroundColor(T.blue)
                }
                .buttonStyle(PressStyle())
            }
            .padding(.horizontal, 14).frame(height: 48)
        }
        .fullScreenCover(item: $callState) { st in CallScreen(state: st, name: p?.display ?? "") }
        .alert("设置备注", isPresented: $editingRemark) {
            TextField("备注名", text: $remark)
            Button("保存") {
                store.setRemark(id: userId, remark: remark)
                H.ok()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("备注只有你自己看得到")
        }
    }

    private func actItem(_ icon: String, _ label: String, action: @escaping () -> Void) -> some View {
        Button {
            H.tap()
            action()
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 20)).foregroundColor(T.blue)
                Text(label).font(.system(size: 12.5)).foregroundColor(T.ink2)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 11)
            .background(Color.white.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color(red: 0.33, green: 0.44, blue: 0.62).opacity(0.06), radius: 6, y: 4)
        }
        .buttonStyle(PressStyle(scale: 0.95))
    }

    private func menuRow(_ icon: String, _ title: String, danger: Bool = false, action: @escaping () -> Void) -> some View {
        Button {
            H.tap()
            action()
        } label: {
            HStack(spacing: 11) {
                Image(systemName: icon).font(.system(size: 16)).foregroundColor(danger ? T.red : T.blue)
                    .frame(width: 24)
                Text(title).font(.system(size: 15.5)).foregroundColor(danger ? T.red : T.ink)
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold))
                    .foregroundColor(danger ? Color(red: 1.0, green: 0.706, blue: 0.686) : T.chevGray)
            }
            .padding(.horizontal, 14).frame(minHeight: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle(scale: 0.98))
    }
}

/* ==================== 23 我的资料 ==================== */
struct MyProfileView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var session: Session
    @Environment(\.dismiss) private var dismiss
    @State private var avatarSheet = false

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "我的资料", onBack: { dismiss() })
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        SettingRow(title: "头像", showChevron: true, trailingOverride: {
                            AnyView(Ava(name: store.meName, size: 48, img: store.myAvatar))
                        }) {
                            avatarSheet = true
                        }
                        RowSep()
                        NavLinkRow(title: "昵称", value: store.meName, route: .editNick)
                        RowSep()
                        SettingRow(title: "性别", value: "不显示", showChevron: false)
                        RowSep()
                        SettingRow(title: "个性签名", value: "还没写", showChevron: false)
                    }
                    .bbCard()
                    .padding(.horizontal, 14).padding(.bottom, 12)

                    VStack(spacing: 0) {
                        SettingRow(title: "BB鸡号", value: store.meId, showChevron: false)
                        RowSep()
                        SettingRow(title: "绑定邮箱", value: store.myEmail, showChevron: false)
                    }
                    .bbCard()
                    .padding(.horizontal, 14)
                }
                .padding(.top, 4).padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $avatarSheet) {
            AvatarSheet(onPicked: { data, name in
                Task {
                    let e = await store.uploadAvatar(data: data, name: name)
                    if e.isEmpty { H.ok() } else { H.warn() }
                }
            })
        }
    }
}

/* SettingRow：自定义 trailing（头像那行用） */
extension SettingRow {
    init(title: String, showChevron: Bool, trailingOverride: @escaping () -> AnyView, action: @escaping () -> Void) {
        self.init(title: title, value: "", showChevron: showChevron, trailing: trailingOverride(), action: action)
    }
}

/* ==================== 25 换头像 bottom sheet ==================== */
struct AvatarSheet: View {
    let onPicked: (Data, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var pickerOpen = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.25).ignoresSafeArea()
                .onTapGesture { dismiss() }
            VStack(spacing: 0) {
                Text("换头像")
                    .font(.system(size: 13.5, weight: .medium)).foregroundColor(T.sec)
                    .padding(.top, 16).padding(.bottom, 10)
                VStack(spacing: 0) {
                    sheetRow("从相册选择") { pickerOpen = true }
                    RowSep()
                    sheetRow("拍一张") { dismiss() }
                    RowSep()
                    sheetRow("用系统头像") { dismiss() }
                }
                .bbCard(20)
                .padding(.horizontal, 12)
                Button {
                    H.tap()
                    dismiss()
                } label: {
                    Text("取消").font(.system(size: 16, weight: .medium)).foregroundColor(T.blue)
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(PressStyle())
                .padding(.horizontal, 12).padding(.top, 8).padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $pickerOpen) {
            PhotoPicker { data, name in
                onPicked(data, name)
                dismiss()
            }
        }
    }

    private func sheetRow(_ title: String, action: @escaping () -> Void) -> some View {
        Button {
            H.tap()
            action()
        } label: {
            Text(title).font(.system(size: 17)).foregroundColor(T.ink)
                .frame(maxWidth: .infinity).frame(minHeight: 52)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle(scale: 0.98))
    }
}

/* ==================== 24 改昵称 ==================== */
struct EditNickView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var saving = false

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "改昵称", onBack: { dismiss() })
            VStack(spacing: 0) {
                HStack {
                    TextField("昵称", text: $name)
                        .font(.system(size: 16)).foregroundColor(T.ink)
                    Spacer()
                    Text("\(name.count)/12").font(.system(size: 14)).foregroundColor(T.ter)
                }
                .padding(.horizontal, 16).frame(minHeight: 52)
            }
            .bbCard()
            .padding(.horizontal, 14).padding(.top, 4)
            TipText(text: "昵称最长 12 个字，改完好友那边会看到新的。")
            Spacer()
            BigButton(title: "保存", busy: saving, height: 50) {
                Task {
                    saving = true
                    let e = await store.setName(name)
                    saving = false
                    if e.isEmpty { H.ok(); dismiss() } else { H.warn() }
                }
            }
            .padding(.horizontal, 14).padding(.bottom, 22)
        }
        .onAppear { name = store.meName }
    }
}

/* ==================== 26 新建聊天 ==================== */
struct NewChatView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var path: [Route] = []

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "新建聊天", onBack: { dismiss() })
            SearchBar(placeholder: "搜索联系人")
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 11) {
                        quickItem("person.2.fill", "新建群聊", blue: true) { path.append(.pickMembers) }
                        quickItem("person.badge.plus", "添加好友", blue: false) { path.append(.addFriend) }
                        quickItem("qrcode.viewfinder", "扫一扫", blue: false) { path.append(.scan) }
                    }
                    .padding(.horizontal, 14).padding(.bottom, 8)

                    GroupHead(text: "最近联系人")
                    VStack(spacing: 0) {
                        ForEach(store.friends) { p in
                            Button {
                                H.tap()
                                path.append(.chat(id: p.id, isGroup: false))
                            } label: {
                                HStack(spacing: 12) {
                                    Ava(name: p.display, size: 40, online: p.online, img: p.avatar)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(p.display).font(.system(size: 16, weight: .medium)).foregroundColor(T.ink)
                                        Text(p.online ? "在线" : "离线")
                                            .font(.system(size: 12.5)).foregroundColor(T.sec)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(T.chevGray)
                                }
                                .padding(.horizontal, 16).frame(minHeight: 58)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PressStyle(scale: 0.99))
                            if p.id != store.friends.last?.id { RowSep() }
                        }
                        if store.friends.isEmpty { EmptyHint(text: "还没有联系人") }
                    }
                    .bbCard()
                    .padding(.horizontal, 14)
                }
                .padding(.bottom, 30)
            }
        }
        .appDest()
        .toolbar(.hidden, for: .navigationBar)
    }

    private func quickItem(_ icon: String, _ label: String, blue: Bool, action: @escaping () -> Void) -> some View {
        Button {
            H.tap()
            action()
        } label: {
            VStack(spacing: 9) {
                ZStack {
                    Circle().fill(blue ? AnyShapeStyle(T.gradCTA) : AnyShapeStyle(T.fldBg))
                        .frame(width: 52, height: 52)
                        .shadow(color: blue ? T.blue.opacity(0.28) : .clear, radius: 6, y: 4)
                    Image(systemName: icon).font(.system(size: 21))
                        .foregroundColor(blue ? .white : Color(red: 0.478, green: 0.518, blue: 0.573))
                }
                Text(label).font(.system(size: 13)).foregroundColor(T.ink2)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 13)
            .background(Color.white.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color(red: 0.33, green: 0.44, blue: 0.62).opacity(0.06), radius: 6, y: 4)
        }
        .buttonStyle(PressStyle(scale: 0.96))
    }
}

/* ==================== 加好友 ==================== */
struct AddFriendView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var found: Person? = nil
    @State private var tip = ""

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "添加好友", onBack: { dismiss() })
            SearchBar(placeholder: "搜 BB鸡号 / 账号") { q in
                search(q)
            }
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if let p = found {
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                Ava(name: p.display, size: 44, online: p.online, img: p.avatar)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(p.display).font(.system(size: 16, weight: .semibold)).foregroundColor(T.ink)
                                    Text("BB鸡号 \(p.bbji.isEmpty ? p.id : p.bbji)")
                                        .font(.system(size: 13)).foregroundColor(T.sec)
                                }
                                Spacer()
                                Button {
                                    H.tap()
                                    store.friendReq(to: p.id, msg: "加个好友吧")
                                    tip = "申请已发出，等对方同意"
                                    found = nil
                                    query = ""
                                } label: {
                                    Text("加好友")
                                        .font(.system(size: 14.5, weight: .medium)).foregroundColor(.white)
                                        .padding(.horizontal, 16).padding(.vertical, 9)
                                        .background(T.gradCTA).clipShape(Capsule())
                                }
                                .buttonStyle(PressStyle())
                            }
                            .padding(.horizontal, 16).frame(minHeight: 64)
                        }
                        .bbCard()
                        .padding(.horizontal, 14)
                    }
                    TipText(text: tip.isEmpty ? "输对方的 BB鸡号或账号搜索；对方同意之前，你只能发一条申请说明。" : tip)

                    GroupHead(text: "可能认识的人")
                    VStack(spacing: 0) {
                        let strangers = store.people.values.filter { p in
                            !store.friends.contains { $0.id == p.id } && p.id != store.meUserId
                        }.sorted { $0.name < $1.name }
                        ForEach(Array(strangers.prefix(6))) { p in
                            HStack(spacing: 12) {
                                Ava(name: p.display, size: 40, online: p.online, img: p.avatar)
                                Text(p.display).font(.system(size: 15.5)).foregroundColor(T.ink)
                                Spacer()
                                Image(systemName: "plus").font(.system(size: 14, weight: .semibold)).foregroundColor(T.sec)
                            }
                            .padding(.horizontal, 16).frame(minHeight: 54)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                query = p.bbji.isEmpty ? p.account : p.bbji
                                search(query)
                            }
                            if p.id != strangers.prefix(6).last?.id { RowSep() }
                        }
                        if strangers.isEmpty { EmptyHint(text: "暂无推荐") }
                    }
                    .bbCard()
                    .padding(.horizontal, 14)
                }
                .padding(.bottom, 30)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func search(_ q: String) {
        if let p = store.findUser(q) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) { found = p }
            tip = ""
        } else {
            withAnimation { found = nil }
            tip = "没找到「\(q)」，确认下 BB鸡号或账号"
        }
    }
}

/* ==================== 59 扫一扫 ==================== */
struct ScanView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var beamY: CGFloat = -80

    var body: some View {
        ZStack {
            Color(red: 0.055, green: 0.078, blue: 0.11).ignoresSafeArea()
            VStack(spacing: 0) {
                NavBar(title: "扫一扫", onBack: { dismiss() }, backTint: .white)
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(LinearGradient(colors: [Color(red: 0.15, green: 0.19, blue: 0.25), Color(red: 0.086, green: 0.11, blue: 0.15)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 230, height: 230)
                    corner(.topLeading).offset(x: -104, y: -104)
                    corner(.topTrailing).offset(x: 104, y: -104)
                    corner(.bottomLeading).offset(x: -104, y: 104)
                    corner(.bottomTrailing).offset(x: 104, y: 104)
                    Rectangle()
                        .fill(LinearGradient(colors: [Color(red: 0.29, green: 0.659, blue: 1.0).opacity(0), T.blue, Color(red: 0.29, green: 0.659, blue: 1.0).opacity(0)],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(height: 2.5)
                        .offset(y: beamY)
                }
                Text("对准二维码 / 条形码，放框里就自动识别\nBB鸡 的码 → 加好友 / 进群 / 登录电脑端")
                    .font(.system(size: 14)).foregroundColor(.white.opacity(0.82))
                    .multilineTextAlignment(.center).lineSpacing(6)
                    .padding(.horizontal, 36).padding(.top, 22)
                Spacer()
                HStack(spacing: 34) {
                    Text("相册").font(.system(size: 13.5)).foregroundColor(.white.opacity(0.6))
                    Text("扫码").font(.system(size: 13.5, weight: .medium)).foregroundColor(.white)
                    Text("我的码").font(.system(size: 13.5)).foregroundColor(.white.opacity(0.6))
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) { beamY = 80 }
        }
    }

    private func corner(_ a: Alignment) -> some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .trim(from: 0, to: 0.26)
            .stroke(.white, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
            .frame(width: 30, height: 30)
            .rotationEffect(rotation(for: a))
            .offset(offset(for: a))
    }

    private func rotation(for a: Alignment) -> Angle {
        switch a {
        case .topLeading: return .degrees(0)
        case .topTrailing: return .degrees(90)
        case .bottomTrailing: return .degrees(180)
        default: return .degrees(270)
        }
    }
    private func offset(for a: Alignment) -> CGSize {
        switch a {
        case .topLeading: return CGSize(width: 0, height: 0)
        case .topTrailing: return CGSize(width: 0, height: 0)
        case .bottomTrailing: return CGSize(width: 0, height: 0)
        default: return CGSize(width: 0, height: 0)
        }
    }
}

/* ==================== 选人（建群/邀请） ==================== */
struct PickMembersView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var selected: [String] = []

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "选择联系人", onBack: { dismiss() })
            SearchBar(placeholder: "搜索联系人")
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if !selected.isEmpty {
                        GroupHead(text: "已选 \(selected.count) 人")
                        HStack(spacing: 9) {
                            ForEach(selected, id: \.self) { id in
                                Ava(name: store.name(of: id, isGroup: false), size: 38,
                                    img: store.people[id]?.avatar ?? "")
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .bbCard()
                        .padding(.horizontal, 14)
                    }
                    GroupHead(text: "好友")
                    VStack(spacing: 0) {
                        ForEach(store.friends) { p in
                            let checked = selected.contains(p.id)
                            Button {
                                H.sel()
                                if checked { selected.removeAll { $0 == p.id } } else { selected.append(p.id) }
                            } label: {
                                HStack(spacing: 12) {
                                    Ava(name: p.display, size: 40, online: p.online, img: p.avatar)
                                    Text(p.display).font(.system(size: 15.5)).foregroundColor(T.ink)
                                    Spacer()
                                    Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 21))
                                        .foregroundColor(checked ? T.blue : Color(red: 0.79, green: 0.82, blue: 0.87))
                                }
                                .padding(.horizontal, 16).frame(minHeight: 54)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PressStyle(scale: 0.99))
                            if p.id != store.friends.last?.id { RowSep() }
                        }
                    }
                    .bbCard()
                    .padding(.horizontal, 14)
                    TipText(text: "建群要服务器支持，先选好人在邀请里用。")
                }
                .padding(.bottom, 20)
            }
            bottomBar
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var bottomBar: some View {
        HStack {
            Text(selected.isEmpty ? "选人之后点邀请" : "已选 \(selected.count) 人")
                .font(.system(size: 15.5)).foregroundColor(T.sec)
            Spacer()
            Button {
                H.ok()
                dismiss()
            } label: {
                Text("完成(\(selected.count))")
                    .font(.system(size: 15.5, weight: .medium)).foregroundColor(.white)
                    .padding(.horizontal, 22).frame(height: 44)
                    .background(selected.isEmpty ? AnyShapeStyle(T.ter) : AnyShapeStyle(T.gradCTA))
                    .clipShape(Capsule())
            }
            .buttonStyle(PressStyle())
            .disabled(selected.isEmpty)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}
