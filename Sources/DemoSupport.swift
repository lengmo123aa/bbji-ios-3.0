import SwiftUI

/* ==================================================================
   演示模式（只给 CI 截图用）：launch 带 -demo 进主界面，带 -page X 深链到某一页。
   正常使用完全不走这段。
   ================================================================== */
extension ProcessInfo {
    static var isDemo: Bool { processInfo.arguments.contains("-demo") }
    static var demoPage: String? {
        if let i = processInfo.arguments.firstIndex(of: "-page"), i + 1 < processInfo.arguments.count {
            return processInfo.arguments[i + 1]
        }
        return nil
    }
}

extension Session {
    func demoLogin() {
        myName = "象象"
        myId = "10086"
        myEmail = "xiang@example.com"
        loggedIn = true
    }
}

extension Store {
    func seedDemo() {
        if !people.isEmpty { return }
        meUserId = "u_me"
        meName = "象象"

        func person(_ id: String, _ name: String, _ online: Bool, _ bbji: String) {
            people[id] = Person(id: id, name: name, online: online, account: name, bbji: bbji)
        }
        person("u_xiang", "象象", true, "10086")
        person("u_wang", "老王", true, "10001")
        person("u_alex", "Alex", false, "10002")
        person("u_liming", "李明", false, "10003")
        person("u_yufang", "玉芳", false, "10004")
        person("u_xing", "星皓", true, "10005")

        friends = [people["u_alex"]!, people["u_liming"]!, people["u_wang"]!, people["u_xiang"]!, people["u_yufang"]!]
            .sorted { $0.name < $1.name }
        groups = [ChatGroup(id: "g_test", name: "测试群",
                            members: ["u_me", "u_wang", "u_xiang", "u_alex", "u_liming", "u_xing"]),
                  ChatGroup(id: "g_design", name: "设计小组",
                            members: ["u_me", "u_yufang", "u_liming"])]
        allIn = true

        let now = Date().timeIntervalSince1970 * 1000
        var ts = now - 3600_000
        func add(_ from: String, _ to: String, _ text: String) {
            ts += 60_000
            msgs.append(Msg(id: "d\(ts)", from: from, to: to, text: text, ts: ts))
        }
        add("u_xiang", "u_me", "好的，收到！😊")
        add("u_me", "u_xiang", "周末一起去逛街吧？")
        add("u_xiang", "u_me", "那边新开了一家店，我拍了照片")
        add("u_wang", "g_test", "今晚一起吃饭吧～")
        add("u_me", "g_test", "已上传最新版本")
        add("u_xing", "u_me", "这个方案不错，赞！")
        add("u_liming", "g_design", "这版配色我调好了，你看下")
        pinned = ["g_test"]
        muted = ["u_xing"]
        markRead("g_test")
        /* 锁屏截图要用：预置一个 4 位锁定密码 */
        if UserDefaults.standard.string(forKey: "bbji30_lock_pw").isNullOrIntEmpty {
            UserDefaults.standard.set("1234", forKey: "bbji30_lock_pw")
        }
    }
}

/// demo 页面名 → Route 深链
func demoRoute(_ page: String) -> (tab: Int, route: Route?)? {
    switch page {
    case "messages": return (0, nil)
    case "chat": return (0, .chat(id: "u_xiang", isGroup: false))
    case "group": return (0, .chat(id: "g_test", isGroup: true))
    case "groupset": return (0, .groupSettings(id: "g_test"))
    case "members": return (0, .groupMembers(id: "g_test"))
    case "qr": return (0, .groupQR(id: "g_test"))
    case "newchat": return (0, .newChat)
    case "scan": return (0, .scan)
    case "forward": return (0, .forward(text: "这版配色我调好了，你看下", fileId: ""))
    case "contacts": return (1, nil)
    case "newfriends": return (1, .newFriends)
    case "friend": return (1, .friendProfile(id: "u_wang"))
    case "addfriend": return (1, .addFriend)
    case "me": return (2, nil)
    case "myprofile": return (2, .myProfile)
    case "settings": return (2, .settings)
    case "account": return (2, .account)
    case "privacy": return (2, .privacy)
    case "lockset": return (2, .lockSetPw)
    case "notify": return (2, .notify)
    case "keepalive": return (2, .keepAlive)
    case "pushstyle": return (2, .pushStyle)
    case "pushapi": return (2, .pushAPI)
    case "bark": return (2, .barkGuide)
    case "general": return (2, .general)
    case "help": return (2, .help)
    case "about": return (2, .about)
    default: return nil
    }
}
