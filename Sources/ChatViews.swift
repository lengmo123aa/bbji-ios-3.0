import SwiftUI
import PhotosUI

/* ==================================================================
   聊天（效果图 12 13 14 15 16 17 18 19 20）
   ================================================================== */

struct ChatView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var session: Session
    @Environment(\.dismiss) private var dismiss
    let convId: String
    let isGroup: Bool

    @State private var draft = ""
    @State private var quote: Msg? = nil
    @State private var plusOpen = false
    @State private var recording = false
    @State private var recSeconds = 0
    @State private var viewerURL: URL? = nil
    @State private var forwardMsg: Msg? = nil
    @State private var callState: CallState? = nil
    @State private var pickerOpen = false
    @State private var lastCount = 0
    @FocusState private var focused: Bool

    private var title: String { store.name(of: convId, isGroup: isGroup) }
    private var msgs: [Msg] { store.thread(convId) }
    private var burnOn: Bool { store.burn.contains(convId) }
    private var group: ChatGroup? { isGroup ? store.groupOf(convId) : nil }
    private var peer: Person? { isGroup ? nil : store.people[convId] }

    var body: some View {
        ZStack(alignment: .top) {
        AppBg()
        VStack(spacing: 0) {
            navBar
            messages
            if burnOn { burnBar }
            if let q = quote { quoteBar(q) }
            if plusOpen { PlusPanel(onImage: { pickerOpen = true }, onCall: { callState = .voiceOut }, onVideo: { callState = .video }) }
            inputBar
        }
        }
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(item: $viewerURL) { url in ImageViewer(url: url, onForward: {
            viewerURL = nil
            forwardMsg = Msg(id: "v", from: "", to: "", text: "[图片]", ts: 0, kind: "image")
        }) }
        .fullScreenCover(item: $callState) { st in CallScreen(state: st, name: title) }
        .sheet(isPresented: $pickerOpen) { PhotoPicker { data, name in
            Task { await store.sendImage(to: convId, data: data, name: name) }
        } }
        .sheet(item: $forwardMsg) { m in
            NavigationStack { ForwardView(text: m.kind == "image" ? "[图片]" : m.text, fileId: m.fileId ?? "") }
        }
        .onAppear { store.markRead(convId); lastCount = msgs.count }
        .onChange(of: msgs.count) { n in
            store.markRead(convId)
            lastCount = n
        }
    }

    /* ---------- 顶栏（.navbar 高 48 / 名字 18 / 群显示人数） ---------- */
    private var navBar: some View {
        NavBar(title: title,
               subtitle: isGroup ? subtitleForGroup : "",
               avatarId: isGroup ? "" : (peer?.avatar ?? ""),
               online: isGroup ? nil : peer?.online,
               onBack: { dismiss() }) {
            HStack(spacing: 16) {
                Button { H.tap(); callState = .voiceOut } label: {
                    Image(systemName: "phone").font(.system(size: 18)).foregroundColor(T.blue)
                }
                .buttonStyle(PressStyle())
                Button { H.tap(); callState = .video } label: {
                    Image(systemName: "video").font(.system(size: 18)).foregroundColor(T.blue)
                }
                .buttonStyle(PressStyle())
                NavigationLink(value: isGroup ? Route.groupSettings(id: convId) : Route.friendProfile(id: convId)) {
                    Image(systemName: "ellipsis").font(.system(size: 18)).foregroundColor(T.blue)
                }
                .buttonStyle(PressStyle())
            }
        }
    }

    private var subtitleForGroup: String {
        let g = store.groupOf(convId)
        guard let g else { return "" }
        let online = g.members.filter { store.people[$0]?.online == true }.count
        return "\(online) 人在线 · \(g.members.count) 人"
    }

    /* ---------- 消息区 ---------- */
    private var messages: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(Array(msgs.enumerated()), id: \.element.id) { i, m in
                        let showDay = i == 0 || (m.ts - msgs[i - 1].ts) > 5 * 60 * 1000
                        if showDay {
                            Text(dayText(m.ts)).font(.system(size: 13)).foregroundColor(T.ter)
                                .padding(.top, 4).id("day-" + m.id)
                        }
                        if isGroup && m.from != store.meUserId,
                           i == 0 || msgs[i - 1].from != m.from {
                            HStack {
                                Text(store.name(of: m.from, isGroup: false))
                                    .font(.system(size: 13)).foregroundColor(T.sec)
                                Spacer()
                            }
                            .padding(.leading, 46)
                        }
                        BubbleRow(msg: m,
                                  isGroup: isGroup,
                                  onImage: { if let f = m.fileId { viewerURL = store.fileURL(f) } },
                                  onQuote: { quote = m },
                                  onForward: { forwardMsg = m },
                                  onRecall: { store.recall(m.id) })
                            .id(m.id)
                    }
                    Color.clear.frame(height: 6).id("bottom")
                }
                .padding(.horizontal, 14).padding(.top, 4)
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) { proxy.scrollTo("bottom", anchor: .bottom) }
                }
            }
            .onChange(of: msgs.count) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) { proxy.scrollTo("bottom", anchor: .bottom) }
                }
            }
        }
    }

    /* ---------- 引用条（15） ---------- */
    private func quoteBar(_ q: Msg) -> some View {
        HStack(spacing: 10) {
            Rectangle().fill(T.blue).frame(width: 3, height: 30).cornerRadius(1.5)
            Text("引用 \(store.name(of: q.from, isGroup: isGroup))：\(q.text.isEmpty ? "[图片]" : q.text)")
                .font(.system(size: 13.5)).foregroundColor(T.sec).lineLimit(1)
            Spacer()
            Button {
                H.tap()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { quote = nil }
            } label: {
                Image(systemName: "xmark").font(.system(size: 14, weight: .semibold)).foregroundColor(T.ter)
            }
            .buttonStyle(PressStyle())
        }
        .padding(.horizontal, 16).padding(.vertical, 8)
        .background(Color.white.opacity(0.85))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    /* ---------- 阅后即焚横幅（20） ---------- */
    private var burnBar: some View {
        HStack(spacing: 5) {
            Text("🔥").font(.system(size: 12))
            Text("阅后即焚已开启 · 看完自动销毁")
                .font(.system(size: 12.5)).foregroundColor(T.pink)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 7)
        .background(T.pink.opacity(0.09))
    }

    /* ---------- 输入条（.cbar：fld 高 40 / 圆角 12 / 图标 24） ---------- */
    private var inputBar: some View {
        HStack(spacing: 11) {
            Button {
                H.tap()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    recording = true
                    plusOpen = false
                }
            } label: {
                Image(systemName: "mic").font(.system(size: 23)).foregroundColor(Color(red: 0.604, green: 0.639, blue: 0.69))
            }
            .buttonStyle(PressStyle())

            TextField("输入消息", text: $draft, axis: .vertical)
                .font(.system(size: 15.5)).foregroundColor(T.ink)
                .lineLimit(1...4)
                .padding(.horizontal, 12).frame(minHeight: 40)
                .background(focused ? Color.white : T.fldBg)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .focused($focused)
                .onSubmit { send() }

            Button {
                H.tap()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    plusOpen.toggle()
                    recording = false
                }
            } label: {
                Image(systemName: plusOpen ? "xmark.circle" : "plus.circle")
                    .font(.system(size: 23)).foregroundColor(Color(red: 0.604, green: 0.639, blue: 0.69))
            }
            .buttonStyle(PressStyle())

            if !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button {
                    send()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18)).foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(T.gradCTA)
                        .clipShape(Circle())
                        .shadow(color: T.blue.opacity(0.3), radius: 5, y: 3)
                }
                .buttonStyle(PressStyle())
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 9).padding(.bottom, 4)
        .background(.ultraThinMaterial)
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: draft.isEmpty)
        .overlay {
            if recording { RecordOverlay(onCancel: { withAnimation { recording = false } },
                                          onDone: { seconds in
                                              withAnimation { recording = false }
                                              let s = storeSendText("🎙 语音消息（\(seconds)s）")
                                              _ = s
                                          }) }
        }
    }

    private func send() {
        let s = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return }
        H.tap(.medium)
        var text = s
        if let q = quote {
            let qn = store.name(of: q.from, isGroup: isGroup)
            text = "「\(qn)：\(q.text.isEmpty ? "[图片]" : q.text)」\n\(s)"
        }
        store.send(to: convId, text: text)
        draft = ""
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { quote = nil }
        focused = true
    }

    private func storeSendText(_ s: String) -> Bool {
        store.send(to: convId, text: s)
        return true
    }
}

/* ==================== 气泡（.b：max 240 / padding 11-14 / 圆角 18 / 15.5px） ==================== */
struct BubbleRow: View {
    @EnvironmentObject var store: Store
    let msg: Msg
    let isGroup: Bool
    let onImage: () -> Void
    let onQuote: () -> Void
    let onForward: () -> Void
    let onRecall: () -> Void
    @State private var burnGone = false

    private var mine: Bool { msg.from == store.meUserId }
    private var peerId: String {
        let g = msg.to == "all" || msg.to.hasPrefix("g")
        return g ? msg.to : (mine ? msg.to : msg.from)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            if mine { Spacer(minLength: 40) }
            if !mine {
                Ava(name: store.name(of: msg.from, isGroup: false), size: 38,
                    img: store.people[msg.from]?.avatar ?? "")
            }
            VStack(alignment: mine ? .trailing : .leading, spacing: 4) {
                content
                if mine {
                    if msg.id.hasPrefix("c") {
                        Text("发送中…").font(.system(size: 12)).foregroundColor(T.ter)
                    } else {
                        Text("已读").font(.system(size: 12)).foregroundColor(T.blue.opacity(0.75))
                    }
                }
            }
            if !mine { Spacer(minLength: 40) }
            if mine {
                Ava(name: store.meName, size: 38, img: store.myAvatar)
            }
        }
        .opacity(burnGone ? 0 : 1)
        .contextMenu { menuItems }
    }

    @ViewBuilder private var content: some View {
        if msg.recalled || burnGone {
            Text(mine ? "你撤回了一条消息" : "对方撤回了一条消息")
                .font(.system(size: 13)).foregroundColor(T.ter).padding(.vertical, 4)
        } else if msg.kind == "image", let f = msg.fileId, let u = store.fileURL(f) {
            Button {
                H.tap()
                onImage()
            } label: {
                NetImg(url: u)
                    .frame(width: 170, height: 170)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.05), lineWidth: 0.5))
            }
            .buttonStyle(PressStyle())
        } else if msg.text.hasPrefix("🎙") {
            voiceBubble
        } else {
            Text(msg.text)
                .font(.system(size: 15.5)).lineSpacing(4)
                .foregroundColor(mine ? .white : T.ink)
                .padding(.horizontal, 14).padding(.vertical, 11)
                .frame(maxWidth: 250, alignment: .leading)
                .background(bubbleBg)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: mine ? T.blue.opacity(0.30) : Color(red: 0.33, green: 0.44, blue: 0.62).opacity(0.06),
                        radius: 6, y: 4)
        }
    }

    private var bubbleBg: some View {
        Group {
            if mine { T.gradCTA } else { Color.white.opacity(0.92) }
        }
    }

    private var voiceBubble: some View {
        HStack(spacing: 9) {
            Circle().fill(mine ? Color.white.opacity(0.22) : T.blue.opacity(0.12))
                .frame(width: 30, height: 30)
                .overlay(Image(systemName: "play.fill").font(.system(size: 13)).foregroundColor(mine ? .white : T.blue))
            Waveform(bars: 16, color: mine ? .white.opacity(0.62) : Color(red: 0.765, green: 0.808, blue: 0.859))
            Text(String(msg.text.dropFirst(3).prefix(6)))
                .font(.system(size: 13)).foregroundColor(mine ? .white.opacity(0.85) : T.sec)
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
        .background(bubbleBg)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    @ViewBuilder private var menuItems: some View {
        Button { H.tap(); onQuote() } label: { Label("引用", systemImage: "text.quote") }
        if msg.kind != "image" && !msg.text.isEmpty {
            Button { UIPasteboard.general.string = msg.text } label: { Label("复制", systemImage: "doc.on.doc") }
        }
        Button { H.tap(); onForward() } label: { Label("转发", systemImage: "arrowshape.turn.up.right") }
        if mine && !msg.id.hasPrefix("c") {
            Button(role: .destructive) { onRecall() } label: { Label("撤回", systemImage: "arrow.uturn.backward") }
        }
    }
}

/* 波形条 */
struct Waveform: View {
    var bars: Int
    var color: Color
    private let heights: [CGFloat] = [7, 12, 17, 9, 14, 19, 10, 15, 8, 18, 13, 9]
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<bars, id: \.self) { i in
                Capsule().fill(color).frame(width: 2.5, height: heights[i % heights.count])
            }
        }
        .frame(height: 20)
    }
}

/* ==================== 13 加号面板（.ppanel：浅灰条 + 白方块 + 细线图标） ==================== */
struct PlusPanel: View {
    let onImage: () -> Void
    let onCall: () -> Void
    let onVideo: () -> Void
    @State private var toast = ""

    private let cells: [(String, String)] = [
        ("photo", "图片"), ("camera", "拍摄"), ("folder", "文件"), ("mappin", "位置"),
        ("person.crop.rectangle", "名片"), ("phone", "语音通话"), ("video", "视频通话"), ("megaphone", "群公告"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 16) {
                ForEach(cells.indices, id: \.self) { i in
                    Button {
                        H.tap()
                        switch cells[i].1 {
                        case "图片": onImage()
                        case "语音通话": onCall()
                        case "视频通话": onVideo()
                        default: toast = cells[i].1 + "下一版开放"
                        }
                    } label: {
                        VStack(spacing: 7) {
                            RoundedRectangle(cornerRadius: 17, style: .continuous)
                                .fill(Color.white)
                                .frame(width: 56, height: 56)
                                .shadow(color: Color(red: 0.08, green: 0.12, blue: 0.2).opacity(0.07), radius: 5, y: 4)
                                .overlay(Image(systemName: cells[i].0)
                                    .font(.system(size: 24, weight: .light))
                                    .foregroundColor(Color(red: 0.235, green: 0.275, blue: 0.345)))
                            Text(cells[i].1).font(.system(size: 13)).foregroundColor(Color(red: 0.482, green: 0.522, blue: 0.584))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PressStyle(scale: 0.94))
                }
            }
            .padding(.horizontal, 12).padding(.top, 16).padding(.bottom, 18)
            if !toast.isEmpty {
                Text(toast).font(.system(size: 12.5)).foregroundColor(T.sec).padding(.bottom, 8)
            }
        }
        .background(Color(red: 0.949, green: 0.957, blue: 0.973))
        .overlay(Rectangle().fill(Color(red: 0.906, green: 0.925, blue: 0.953)).frame(height: 1), alignment: .top)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

/* ==================== 17 录音浮层 ==================== */
struct RecordOverlay: View {
    let onCancel: () -> Void
    let onDone: (Int) -> Void
    @State private var seconds = 0
    @State private var timer: Timer? = nil

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack {
                Circle().fill(T.blue.opacity(0.14)).frame(width: 150, height: 150)
                Image(systemName: "mic").font(.system(size: 46)).foregroundColor(T.blue)
                    .scaleEffect(seconds % 2 == 0 ? 1.0 : 1.06)
                    .animation(.easeInOut(duration: 0.5), value: seconds % 2)
            }
            Waveform(bars: 14, color: T.blue)
            Text("松开发送 · 上滑取消")
                .font(.system(size: 14)).foregroundColor(T.sec)
            HStack(spacing: 26) {
                Button { timer?.invalidate(); onCancel() } label: {
                    Text("取消").font(.system(size: 15)).foregroundColor(T.sec)
                        .padding(.horizontal, 22).padding(.vertical, 10)
                        .background(Color.white).clipShape(Capsule())
                }
                .buttonStyle(PressStyle())
                Button {
                    timer?.invalidate()
                    onDone(max(seconds, 1))
                } label: {
                    Text("发送").font(.system(size: 15, weight: .medium)).foregroundColor(.white)
                        .padding(.horizontal, 22).padding(.vertical, 10)
                        .background(T.gradCTA).clipShape(Capsule())
                }
                .buttonStyle(PressStyle())
            }
            Spacer()
        }
        .padding(.bottom, 90)
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in seconds += 1 }
        }
        .onDisappear { timer?.invalidate() }
    }
}

/* ==================== 16 看图（全屏 + 捏合缩放） ==================== */
struct ImageViewer: View {
    @Environment(\.dismiss) private var dismiss
    let url: URL
    let onForward: () -> Void
    @State private var scale: CGFloat = 1

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            NetImg(url: url, fill: false)
                .scaleEffect(scale)
                .gesture(
                    MagnificationGesture()
                        .onChanged { v in scale = max(1, min(4, v)) }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { scale = 1 }
                        }
                )
                .onTapGesture(count: 2) {
                    H.tap()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { scale = scale > 1.5 ? 1 : 2.4 }
                }
                .onTapGesture {
                    dismiss()
                }
            VStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 19, weight: .semibold)).foregroundColor(.white)
                    }
                    .buttonStyle(PressStyle())
                    Spacer()
                }
                .padding(.horizontal, 16)
                Spacer()
                HStack {
                    viewerItem("arrowshape.turn.up.right", "转发") { onForward() }
                    viewerItem("square.and.arrow.down", "保存") { H.ok() }
                    viewerItem("photo", "原图") { }
                    viewerItem("ellipsis", "更多") { }
                }
                .padding(.vertical, 14).padding(.bottom, 20)
                .background(LinearGradient(colors: [.black.opacity(0.55), .black.opacity(0)], startPoint: .bottom, endPoint: .top).ignoresSafeArea())
            }
        }
    }

    private func viewerItem(_ icon: String, _ label: String, action: @escaping () -> Void) -> some View {
        Button {
            H.tap()
            action()
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 21)).foregroundColor(.white)
                Text(label).font(.system(size: 13)).foregroundColor(.white.opacity(0.85))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PressStyle())
    }
}

extension URL: Identifiable { public var id: String { absoluteString } }
extension CallState: Identifiable { public var id: String { rawValue } }

/* ==================== 18 转发 ==================== */
struct ForwardView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let text: String
    let fileId: String
    @State private var selected: [String] = []
    @State private var done = false

    var body: some View {
        ZStack(alignment: .top) {
        AppBg()
        VStack(spacing: 0) {
            NavBar(title: "转发到…", onBack: { dismiss() })
            SearchBar(placeholder: "搜索聊天、联系人")
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if !store.convs.isEmpty {
                        GroupHead(text: "最近聊天")
                        groupRows(store.convs.map { ("\($0.name)", $0.id, $0.isGroup) })
                    }
                    GroupHead(text: "好友")
                    groupRows(store.friends.map { ($0.display, $0.id, false) })
                }
                .padding(.bottom, 20)
            }
            bottomBar
        }
        }
        .onDisappear { if done { } }
    }

    private func groupRows(_ items: [(String, String, Bool)]) -> some View {
        VStack(spacing: 0) {
            ForEach(items, id: \.1) { item in
                let checked = selected.contains(item.1)
                Button {
                    H.sel()
                    if checked { selected.removeAll { $0 == item.1 } } else { selected.append(item.1) }
                } label: {
                    HStack(spacing: 12) {
                        Ava(name: item.0, size: 40)
                        Text(item.0).font(.system(size: 15.5)).foregroundColor(T.ink)
                        Spacer()
                        Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 21))
                            .foregroundColor(checked ? T.blue : Color(red: 0.79, green: 0.82, blue: 0.87))
                    }
                    .padding(.horizontal, 16).frame(minHeight: 54)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressStyle(scale: 0.99))
                if item.1 != items.last?.1 { RowSep() }
            }
        }
        .bbCard()
        .padding(.horizontal, 14)
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(selected.isEmpty ? "选一个人转发" : "已选 \(selected.count) 个")
                    .font(.system(size: 15.5, weight: .medium)).foregroundColor(T.ink)
                Text("转发后对方能直接看到内容")
                    .font(.system(size: 12.5)).foregroundColor(T.sec)
            }
            Spacer()
            Button {
                guard !selected.isEmpty else { return }
                H.ok()
                for to in selected { store.send(to: to, text: text) }
                done = true
                dismiss()
            } label: {
                Text(selected.isEmpty ? "转发" : "转发(\(selected.count))")
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

/* ==================== 拍照/相册选图（发图片用） ==================== */
struct PhotoPicker: UIViewControllerRepresentable {
    let onPick: (Data, String) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var cfg = PHPickerConfiguration()
        cfg.filter = .images
        cfg.selectionLimit = 1
        let vc = PHPickerViewController(configuration: cfg)
        vc.delegate = context.coordinator
        return vc
    }
    func updateUIViewController(_ vc: PHPickerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        init(_ p: PhotoPicker) { parent = p }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            guard let item = results.first?.itemProvider, item.canLoadObject(ofClass: UIImage.self) else { return }
            item.loadObject(ofClass: UIImage.self) { [weak self] obj, _ in
                guard let img = obj as? UIImage,
                      let data = img.jpegData(compressionQuality: 0.82) else { return }
                DispatchQueue.main.async {
                    self?.parent.onPick(data, item.suggestedName ?? "pic.jpg")
                }
            }
        }
    }
}
