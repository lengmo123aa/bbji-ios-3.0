import SwiftUI
import PhotosUI

/* ==================================================================
   主框架 + 消息 / 通讯录 / 我（效果图 06 07 08 09 10 11 59）
   ================================================================== */

/// 全局路由（每条 NavigationStack 都挂同一份 destination 映射）
enum Route: Hashable {
    case chat(id: String, isGroup: Bool)
    case newFriends
    case friendProfile(id: String)
    case myProfile
    case editNick
    case avatarPick
    case newChat
    case addFriend
    case scan
    case groupSettings(id: String)
    case groupMembers(id: String)
    case groupQR(id: String)
    case invite(id: String)
    case pickMembers
    case settings
    case account
    case privacy
    case lockSetPw
    case lockRules
    case notify
    case keepAlive
    case pushStyle
    case pushAPI
    case barkGuide
    case general
    case help
    case about
    case forward(text: String, fileId: String)
}

func appDestinations() -> some View {
    EmptyView()
}

struct MainTabs: View {
    @EnvironmentObject var store: Store
    @State private var tab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if tab == 0 { MessagesView() }
                else if tab == 1 { ContactsView() }
                else { MeView() }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            TabBar(sel: $tab)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

/// 每条栈共用：把 Route 映射到页面
struct Destinations: ViewModifier {
    func body(content: Content) -> some View {
        content.navigationDestination(for: Route.self) { r in
            switch r {
            case .chat(let id, let g): ChatView(convId: id, isGroup: g)
            case .newFriends: NewFriendsView()
            case .friendProfile(let id): FriendProfileView(userId: id)
            case .myProfile: MyProfileView()
            case .editNick: EditNickView()
            case .avatarPick: EmptyView()
            case .newChat: NewChatView()
            case .addFriend: AddFriendView()
            case .scan: ScanView()
            case .groupSettings(let id): GroupSettingsView(gid: id)
            case .groupMembers(let id): GroupMembersView(gid: id)
            case .groupQR(let id): GroupQRView(gid: id)
            case .invite(let id): InviteView(gid: id)
            case .pickMembers: PickMembersView()
            case .settings: SettingsHomeView()
            case .account: AccountView()
            case .privacy: PrivacyView()
            case .lockSetPw: LockSetPwView()
            case .lockRules: LockRulesView()
            case .notify: NotifyView()
            case .keepAlive: KeepAliveView()
            case .pushStyle: PushStyleView()
            case .pushAPI: PushAPIView()
            case .barkGuide: BarkGuideView()
            case .general: GeneralView()
            case .help: HelpView()
            case .about: AboutView()
            case .forward(let text, let file): ForwardView(text: text, fileId: file)
            }
        }
    }
}
extension View { func appDest() -> some View { modifier(Destinations()) } }

/* ==================== 06 消息列表 ==================== */
struct MessagesView: View {
    @EnvironmentObject var store: Store
    @State private var plusMenu = false
    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .top) {
                AppBg()
                VStack(spacing: 0) {
                    TopTitle("消息") {
                        Button {
                            H.tap()
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) { plusMenu = true }
                        } label: {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 24, weight: .regular)).foregroundColor(T.blue)
                        }
                        .buttonStyle(PressStyle())
                    }
                    SearchBar(placeholder: "搜索聊天、联系人、消息")

                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            let list = store.convs
                            if list.isEmpty {
                                EmptyHint(text: "还没有聊天，去通讯录找个人聊聊吧")
                            }
                            ForEach(list) { c in
                                SwipeableRow(conv: c) {
                                    path.append(.chat(id: c.id, isGroup: c.isGroup))
                                }
                                if c.id != list.last?.id { RowSep(left: 0) }
                            }
                        }
                        .padding(.bottom, 90)
                    }
                }
                /* 08 右上角 ＋ 的下拉菜单 */
                if plusMenu {
                    Color.black.opacity(0.001)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture { withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { plusMenu = false } }
                        .zIndex(5)
                    PlusMenu { r in
                        plusMenu = false
                        if let r { path.append(r) }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 14).padding(.top, 92)
                    .zIndex(6)
                }
            }
            .appDest()
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

/* ＋菜单（.pmenu：宽 170→220 / 圆角 14→17 / 行 40→48） */
private struct PlusMenu: View {
    let go: (Route?) -> Void
    var body: some View {
        VStack(spacing: 0) {
            menuRow("qrcode.viewfinder", "扫一扫") { go(.scan) }
            RowSep(left: 44)
            menuRow("person.badge.plus", "加好友") { go(.addFriend) }
            RowSep(left: 44)
            menuRow("person.2.badge.plus", "新建群聊") { go(.pickMembers) }
            RowSep(left: 44)
            menuRow("qr.code", "我的二维码") { go(.groupQR(id: "me")) }
        }
        .background(Color.white.opacity(0.98))
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        .shadow(color: Color(red: 0.06, green: 0.13, blue: 0.25).opacity(0.22), radius: 20, y: 16)
        .frame(width: 220)
    }

    private func menuRow(_ icon: String, _ title: String, action: @escaping () -> Void) -> some View {
        Button {
            H.tap()
            action()
        } label: {
            HStack(spacing: 11) {
                Image(systemName: icon).font(.system(size: 17)).foregroundColor(T.blue)
                    .frame(width: 24)
                Text(title).font(.system(size: 15.5)).foregroundColor(T.ink)
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundColor(T.chevGray)
            }
            .padding(.horizontal, 14).frame(minHeight: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle(scale: 0.98))
    }
}

/* ==================== 07 左滑（自绘：行推出 + 三个按钮盖住） ==================== */
struct SwipeableRow: View {
    @EnvironmentObject var store: Store
    let conv: Conv
    let tap: () -> Void
    @State private var offset: CGFloat = 0
    @State private var open = false
    private let buttonW: CGFloat = 72

    var body: some View {
        ZStack(alignment: .trailing) {
            HStack(spacing: 0) {
                swipeButton(conv.pinned ? "取消置顶" : "置顶", T.swipeGray) {
                    store.togglePin(conv.id)
                    close()
                }
                swipeButton(conv.muted ? "提醒" : "免打扰", T.swipeOrange) {
                    store.toggleMute(conv.id)
                    close()
                }
                swipeButton("删除", T.red) {
                    H.tap(.medium)
                    store.hideConv(conv.id)
                    close()
                }
            }
            row
                .background(conv.pinned ? Color(red: 0.906, green: 0.941, blue: 1.0) : Color.clear)
                .offset(x: offset)
        }
        .contentShape(Rectangle())
        .gesture(swipeGesture)
        .onTapGesture {
            if open { close() } else { tap() }
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 18, coordinateSpace: .local)
            .onChanged { v in
                let base: CGFloat = open ? -buttonW * 3 : 0
                offset = min(0, base + v.translation.width)
            }
            .onEnded { v in
                let base: CGFloat = open ? -buttonW * 3 : 0
                let target = min(0, base + v.translation.width)
                let shouldOpen = target < -buttonW * 1.6
                H.sel()
                withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                    offset = shouldOpen ? -buttonW * 3 : 0
                    open = shouldOpen
                }
            }
    }

    private func close() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) { offset = 0; open = false }
    }

    private func swipeButton(_ title: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium)).foregroundColor(.white)
                .frame(width: buttonW)
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle(scale: 0.97))
        .background(color)
    }

    private var row: some View {
        HStack(spacing: 12) {
            if conv.isGroup {
                Ava(name: conv.name, size: 56)
            } else {
                Ava(name: conv.name, size: 56, online: conv.online, img: store.avatarId(conv.id, isGroup: false))
            }
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(conv.name)
                        .font(.system(size: 17, weight: .semibold)).kerning(-0.3)
                        .foregroundColor(T.ink).lineLimit(1)
                    if conv.isGroup {
                        let n = store.groupOf(conv.id)?.members.count ?? 0
                        if n > 0 { ChipText(text: "\(n) 人", grey: true) }
                    }
                    if store.burn.contains(conv.id) {
                        Text("🔥").font(.system(size: 13))
                    }
                }
                Text(conv.text.isEmpty ? "开始聊聊吧" : conv.text)
                    .font(.system(size: 15)).foregroundColor(T.sec)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 6) {
                Text(timeText(conv.ts))
                    .font(.system(size: 13)).foregroundColor(T.ter)
                if conv.muted {
                    Image(systemName: "bell.slash").font(.system(size: 13)).foregroundColor(T.ter)
                } else if conv.unread > 0 {
                    BadgeNum(n: conv.unread)
                }
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 7)
        .contentShape(Rectangle())
        .background(T.page)
        .contextMenu {
            Button { store.markRead(conv.id) } label: { Label("标为已读", systemImage: "checkmark.circle") }
            Button { store.togglePin(conv.id) } label: { Label(conv.pinned ? "取消置顶" : "置顶聊天", systemImage: "pin") }
            Button { store.toggleMute(conv.id) } label: { Label(conv.muted ? "取消免打扰" : "消息免打扰", systemImage: "bell.slash") }
            Button(role: .destructive) { store.hideConv(conv.id) } label: { Label("删除聊天", systemImage: "trash") }
        }
    }
}

/* ==================== 09 通讯录 ==================== */
struct ContactsView: View {
    @EnvironmentObject var store: Store
    @State private var path: [Route] = []

    private var sections: [(String, [Person])] {
        let groups = Dictionary(grouping: store.friends) { p -> String in
            let c = p.display.prefix(1).uppercased()
            return ("A"..."Z").contains(c) ? c : "#"
        }
        return groups.keys.sorted { a, b in
            if a == "#" { return false }
            if b == "#" { return true }
            return a < b
        }.map { ($0, groups[$0]!.sorted { $0.display < $1.display }) }
    }

    var body: some View {
        NavigationStack(path: $path) {
            AppBg()
            VStack(spacing: 0) {
                TopTitle("通讯录") {
                    Button {
                        H.tap()
                        path.append(.addFriend)
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 22, weight: .regular)).foregroundColor(T.blue)
                    }
                    .buttonStyle(PressStyle())
                }
                SearchBar(placeholder: "搜索联系人")

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            SettingRow(icon: "person.badge.plus", iconGrad: 2, title: "新的朋友",
                                       value: pendingCount, showChevron: true) { path.append(.newFriends) }
                            RowSep(left: 47)
                            SettingRow(icon: "bubble.left.and.bubble.right", iconGrad: 4, title: "群聊",
                                       value: "\(store.groups.count) 个") { path.append(.pickMembers) }
                        }
                        .bbCard()
                        .padding(.horizontal, 14).padding(.bottom, 4)

                        ForEach(sections, id: \.0) { letter, people in
                            GroupHead(text: "\(letter) · \(people.count) 位好友")
                            VStack(spacing: 0) {
                                ForEach(people) { p in
                                    Button {
                                        H.tap()
                                        path.append(.friendProfile(id: p.id))
                                    } label: {
                                        HStack(spacing: 12) {
                                            Ava(name: p.display, size: 40, online: p.online, img: p.avatar)
                                            Text(p.display).font(.system(size: 16, weight: .medium)).foregroundColor(T.ink)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 16).frame(minHeight: 54)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PressStyle(scale: 0.99))
                                    if p.id != people.last?.id { RowSep(left: 16) }
                                }
                            }
                            .bbCard()
                            .padding(.horizontal, 14).padding(.bottom, 4)
                        }
                        if store.friends.isEmpty {
                            EmptyHint(text: "还没有好友，点右上角加一个")
                        }
                    }
                    .padding(.bottom, 90)
                }
            }
            .appDest()
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var pendingCount: String {
        let n = store.reqs.filter { !$0.outgoing && $0.state == "pending" }.count
        return n > 0 ? "\(n) 条请求" : ""
    }
}

/* ==================== 10 新的朋友 ==================== */
struct NewFriendsView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "新的朋友", onBack: { dismiss() })
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    let pending = store.reqs.filter { !$0.outgoing && $0.state == "pending" }
                    if !pending.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(pending) { r in
                                reqRow(r)
                                if r.id != pending.last?.id { RowSep() }
                            }
                        }
                        .bbCard()
                        .padding(.horizontal, 14)
                    } else {
                        EmptyHint(text: "没有待处理的好友申请")
                    }

                    let done = store.reqs.filter { $0.state != "pending" }
                    if !done.isEmpty {
                        GroupHead(text: "已添加")
                        VStack(spacing: 0) {
                            ForEach(done) { r in
                                HStack(spacing: 12) {
                                    Ava(name: store.name(of: r.outgoing ? r.userId : r.userId, isGroup: false), size: 40)
                                    Text(store.name(of: r.userId, isGroup: false))
                                        .font(.system(size: 15.5)).foregroundColor(T.ink)
                                    Spacer()
                                    Text(r.state == "accepted" ? "已同意" : (r.outgoing ? "已发送" : "已拒绝"))
                                        .font(.system(size: 14)).foregroundColor(T.ter)
                                }
                                .padding(.horizontal, 16).frame(minHeight: 54)
                                if r.id != done.last?.id { RowSep() }
                            }
                        }
                        .bbCard()
                        .padding(.horizontal, 14)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }

    private func reqRow(_ r: FriendReq) -> some View {
        HStack(spacing: 12) {
            Ava(name: store.name(of: r.userId, isGroup: false), size: 44,
                img: store.people[r.userId]?.avatar ?? "")
            VStack(alignment: .leading, spacing: 3) {
                Text(store.name(of: r.userId, isGroup: false))
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(T.ink)
                if !r.msg.isEmpty {
                    Text("「\(r.msg)」")
                        .font(.system(size: 13.5)).foregroundColor(T.sec).lineLimit(1)
                }
            }
            Spacer()
            Button {
                H.ok()
                store.friendAck(from: r.userId, accept: true)
            } label: {
                Text("同意")
                    .font(.system(size: 14.5, weight: .medium)).foregroundColor(.white)
                    .padding(.horizontal, 15).padding(.vertical, 8)
                    .background(T.gradCTA)
                    .clipShape(Capsule())
                    .shadow(color: T.blue.opacity(0.28), radius: 4, y: 2)
            }
            .buttonStyle(PressStyle())
            Button {
                H.tap()
                store.friendAck(from: r.userId, accept: false)
            } label: {
                Text("拒绝").font(.system(size: 14.5)).foregroundColor(T.sec)
            }
            .buttonStyle(PressStyle())
        }
        .padding(.horizontal, 16).frame(minHeight: 64)
    }
}

/* ==================== 11 我 ==================== */
struct MeView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var session: Session
    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            AppBg()
            VStack(spacing: 0) {
                TopTitle("我")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            VStack(spacing: 0) {
                                Ava(name: store.meName, size: 104, img: store.myAvatar)
                                    .padding(.top, 22)
                                Text(store.meName.isEmpty ? session.myName : store.meName)
                                    .font(.system(size: 20, weight: .semibold)).kerning(-0.3)
                                    .foregroundColor(T.ink)
                                    .padding(.top, 12)
                                Text("BB鸡号 \(store.meId)")
                                    .font(.system(size: 13.5)).foregroundColor(T.sec)
                                    .padding(.top, 5).padding(.bottom, 18)
                            }
                        }
                        .bbCard()
                        .padding(.horizontal, 14).padding(.bottom, 12)

                        VStack(spacing: 0) {
                            SettingRow(icon: "person", iconGrad: 3, title: "我的资料") { path.append(.myProfile) }
                            RowSep(left: 47)
                            SettingRow(icon: "qr.code", iconGrad: 2, title: "我的二维码") { path.append(.groupQR(id: "me")) }
                        }
                        .bbCard()
                        .padding(.horizontal, 14).padding(.bottom, 12)

                        VStack(spacing: 0) {
                            SettingRow(icon: "gearshape", iconGrad: 0, title: "设置") { path.append(.settings) }
                        }
                        .bbCard()
                        .padding(.horizontal, 14)
                    }
                    .padding(.bottom, 90)
                }
            }
            .appDest()
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
