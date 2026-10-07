import SwiftUI

/* ==================================================================
   群（效果图 30 31 32 33）
   ================================================================== */

/* ==================== 30 群设置 ==================== */
struct GroupSettingsView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let gid: String
    @State private var mute = false
    @State private var pin = false
    @State private var renaming = false
    @State private var newName = ""

    private var g: ChatGroup? { store.groupOf(gid) }
    private var burn: Binding<Bool> {
        Binding(get: { store.burn.contains(gid) }, set: { _ in store.toggleBurn(gid) })
    }

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: g?.name ?? "群聊", onBack: { dismiss() })
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if let g {
                        GroupHead(text: "群成员 \(g.members.count) 人")
                        VStack(spacing: 0) {
                            memberGrid(g)
                            RowSep()
                            NavigationLink(value: Route.groupMembers(id: gid)) {
                                rowLabel("查看全部 \(g.members.count) 人", value: "")
                            }
                            .buttonStyle(PressStyle(scale: 0.99))
                        }
                        .bbCard()
                        .padding(.horizontal, 14)

                        GroupHead(text: "群聊设置")
                        VStack(spacing: 0) {
                            SettingRow(title: "群名称", value: g.name) {
                                newName = g.name
                                renaming = true
                            }
                            RowSep()
                            SettingRow(title: "群公告", value: "还没设置") { }
                            RowSep()
                            NavigationLink(value: Route.groupQR(id: gid)) {
                                rowLabel("群二维码", value: "")
                            }
                            .buttonStyle(PressStyle(scale: 0.99))
                        }
                        .bbCard()
                        .padding(.horizontal, 14).padding(.bottom, 12)

                        VStack(spacing: 0) {
                            ToggleRow(title: "消息免打扰", on: $mute)
                            RowSep()
                            ToggleRow(title: "置顶聊天", on: $pin)
                            RowSep()
                            ToggleRow(title: "阅后即焚", on: burn)
                            RowSep()
                            SettingRow(title: "我在本群的昵称", value: store.meName) { }
                        }
                        .bbCard()
                        .padding(.horizontal, 14).padding(.bottom, 12)

                        VStack(spacing: 0) {
                            SettingRow(title: "退出群聊", showChevron: false, danger: true) {
                                H.warn()
                                store.groupLeave(gid)
                                dismiss()
                            }
                        }
                        .bbCard()
                        .padding(.horizontal, 14)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            mute = store.muted.contains(gid)
            pin = store.pinned.contains(gid)
        }
        .onChange(of: mute) { _ in if !store.muted.contains(gid) { store.toggleMute(gid) } }
        .onChange(of: pin) { _ in store.togglePin(gid) }
        .alert("改群名", isPresented: $renaming) {
            TextField("群名称", text: $newName)
            Button("保存") {
                store.groupRename(gid, name: newName)
                H.ok()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("群成员都能看到新的群名")
        }
    }

    /* 成员九宫格（.mem：5 列 / 头像 54） */
    private func memberGrid(_ g: ChatGroup) -> some View {
        let shown = Array(g.members.prefix(7))
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 5), spacing: 12) {
            ForEach(shown, id: \.self) { id in
                VStack(spacing: 6) {
                    Ava(name: store.name(of: id, isGroup: false), size: 54,
                        online: store.people[id]?.online, img: store.people[id]?.avatar ?? "")
                    Text(store.name(of: id, isGroup: false))
                        .font(.system(size: 12)).foregroundColor(T.sec).lineLimit(1)
                }
            }
            NavigationLink(value: Route.invite(id: gid)) {
                VStack(spacing: 6) {
                    ZStack {
                        Circle().fill(Color.white).frame(width: 54, height: 54)
                            .overlay(Circle().stroke(Color(red: 0.788, green: 0.824, blue: 0.871),
                                                     style: StrokeStyle(lineWidth: 1.2, dash: [4])))
                        Image(systemName: "plus").font(.system(size: 15, weight: .medium)).foregroundColor(T.sec)
                    }
                    Text("邀请").font(.system(size: 12)).foregroundColor(T.sec)
                }
            }
            .buttonStyle(PressStyle(scale: 0.94))
        }
        .padding(.horizontal, 14).padding(.top, 12).padding(.bottom, 8)
    }

    private func rowLabel(_ title: String, value: String) -> some View {
        HStack(spacing: 10) {
            Text(title).font(.system(size: 15.5)).foregroundColor(T.ink)
            Spacer()
            if !value.isEmpty { Text(value).font(.system(size: 14)).foregroundColor(T.ter) }
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(T.chevGray)
        }
        .padding(.horizontal, 16).frame(minHeight: 52)
        .contentShape(Rectangle())
    }
}

/* ==================== 31 群成员 ==================== */
struct GroupMembersView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let gid: String
    @State private var path: [Route] = []

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "群成员（\(store.groupOf(gid)?.members.count ?? 0)）", onBack: { dismiss() })
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    GroupHead(text: "群成员")
                    VStack(spacing: 0) {
                        let members = store.groupOf(gid)?.members ?? []
                        ForEach(members, id: \.self) { id in
                            Button {
                                H.tap()
                                path.append(.friendProfile(id: id))
                            } label: {
                                HStack(spacing: 12) {
                                    Ava(name: store.name(of: id, isGroup: false), size: 40,
                                        online: store.people[id]?.online, img: store.people[id]?.avatar ?? "")
                                    Text(store.name(of: id, isGroup: false))
                                        .font(.system(size: 15.5)).foregroundColor(T.ink)
                                    Spacer()
                                    if id == members.first {
                                        ChipText(text: "群主")
                                    }
                                    Text(store.people[id]?.online == true ? "在线" : "离线")
                                        .font(.system(size: 13)).foregroundColor(T.ter)
                                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(T.chevGray)
                                }
                                .padding(.horizontal, 16).frame(minHeight: 54)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PressStyle(scale: 0.99))
                            if id != members.last { RowSep() }
                        }
                        if members.isEmpty { EmptyHint(text: "群里还没有人") }
                    }
                    .bbCard()
                    .padding(.horizontal, 14)
                }
                .padding(.top, 2).padding(.bottom, 24)
            }
            SoftButton(title: "邀请好友进群") {
                path.append(.invite(id: gid))
            }
            .padding(.horizontal, 14).padding(.bottom, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

/* ==================== 32 群二维码 / 我的二维码 ==================== */
struct GroupQRView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let gid: String
    @State private var toast = ""

    private var title: String { gid == "me" ? (store.meName.isEmpty ? "我的二维码" : store.meName) : (store.groupOf(gid)?.name ?? "群二维码") }

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: gid == "me" ? "我的二维码" : "群二维码", onBack: { dismiss() })
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 14) {
                    QRBox(seed: gid == "me" ? (store.meId + store.meUserId) : gid)
                        .frame(width: 210, height: 210)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .shadow(color: Color(red: 0.06, green: 0.13, blue: 0.25).opacity(0.08), radius: 8, y: 6)
                    Text(title).font(.system(size: 17, weight: .semibold)).foregroundColor(T.ink)
                    Text(gid == "me" ? "扫一扫上面的二维码，加我好友" : "扫码就能申请加入 · 7 天后失效")
                        .font(.system(size: 13.5)).foregroundColor(T.sec)
                    if !toast.isEmpty {
                        Text(toast).font(.system(size: 13)).foregroundColor(T.blue)
                    }
                }
                .padding(.top, 20)
                Spacer()
                HStack(spacing: 10) {
                    SoftButton(title: "保存到相册") { toast = "已保存（演示）" }
                    SoftButton(title: "分享给好友") { toast = "分享（演示）" }
                }
                .padding(.horizontal, 14).padding(.bottom, 24)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

/* 假二维码（Canvas 按种子画，效果跟设计稿 .qrbox .fake 一致） */
struct QRBox: View {
    let seed: String
    var body: some View {
        Canvas { ctx, size in
            let n = 17
            let cell = size.width / CGFloat(n)
            var h = 7
            for ch in seed.unicodeScalars { h = (h &* 33 &+ Int(ch.value)) % 65537 }
            for row in 0..<n {
                for col in 0..<n {
                    h = (h &* 1103515245 &+ 12345) % 2147483647
                    let isAnchor = (row < 7 && col < 7) || (row < 7 && col >= n - 7) || (row >= n - 7 && col < 7)
                    if isAnchor {
                        let inEye = (row == 0 || row == 6 || col == 0 || col == 6) ||
                            ((2...4).contains(row % 7) && (2...4).contains(col % 7))
                        if inEye { ctx.fill(Path(CGRect(x: CGFloat(col) * cell, y: CGFloat(row) * cell, width: cell, height: cell)), with: .color(.black)) }
                    } else if h % 100 < 46 {
                        ctx.fill(Path(CGRect(x: CGFloat(col) * cell, y: CGFloat(row) * cell, width: cell, height: cell)), with: .color(.black))
                    }
                }
            }
        }
    }
}

/* ==================== 33 邀请进群 ==================== */
struct InviteView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let gid: String
    @State private var selected: [String] = []
    @State private var msg = "一起来聊聊吧"

    var body: some View {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "邀请好友进群", onBack: { dismiss() })
            SearchBar(placeholder: "搜索好友")
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
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
                    .padding(.horizontal, 14).padding(.bottom, 12)

                    VStack(spacing: 0) {
                        SettingRow(title: "邀请语", value: msg) {
                            // 简化：点一下换成下一句
                            msg = ["一起来聊聊吧", "进群一起玩", "有事儿群里说"][Int.random(in: 0..<3)]
                        }
                    }
                    .bbCard()
                    .padding(.horizontal, 14)
                    TipText(text: "对方会收到一条「谁邀请你进群」的消息，同意后才进群。")
                }
                .padding(.bottom, 20)
            }
            BigButton(title: selected.isEmpty ? "邀请" : "邀请（\(selected.count) 人）",
                      disabled: selected.isEmpty, height: 50) {
                H.ok()
                store.groupInvite(gid, ids: selected)
                dismiss()
            }
            .padding(.horizontal, 14).padding(.bottom, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
