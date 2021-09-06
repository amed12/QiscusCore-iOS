//
//  RoomListModel.swift
//  QiscusCore
//
//  Created by Arief Nur Putranto on 26/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//
import Foundation
import SwiftyJSON

public enum RoomType: String {
    case single = "single"
    case group = "group"
    case channel = "public_channel"
    
    static let all = [single,group,channel]
}

public class Meta {
    public let currentPage : Int?
    public let totalRoom : Int?
    
    init(json: JSON) {
        self.currentPage    = json["current_page"].int ??  json["total_page"].intValue
        self.totalRoom    = json["total_room"].int ?? json["total_data"].intValue
    }
    
}

public class MetaRoomParticipant {
    public let currentPage : Int?
    public let perPage : Int?
    public let total : Int?
    
    init(json: JSON) {
        self.currentPage    = json["current_page"].int ??  0
        self.perPage        = json["per_page"].int ?? 0
        self.total          = json["total"].int ?? 0
    }
    
}

open class QChatRoom {
    public var onChange : (QMessage) -> Void = { _ in} // data binding
    public internal(set) var id : String = ""
    public internal(set) var name : String = ""
    public internal(set) var uniqueId : String = ""
    public internal(set) var avatarUrl : URL? = nil
    public internal(set) var type : RoomType                  = .group
    public var extras : String? = nil
    // can be update after got new comment
    public internal(set) var lastComment : QMessage?      = nil
    public internal(set) var participants : [QParticipant]?    = nil
    public internal(set) var totalParticipants : Int = 0
    public internal(set) var unreadCount : Int = -1
    
    init() {}
    
    init(json: JSON) {
        self.id             = json["id_str"].stringValue
        self.name           = json["room_name"].stringValue
        self.uniqueId       = json["unique_id"].stringValue
        self.avatarUrl      = json["avatar_url"].url ?? nil
        self.extras        = json["options"].string ?? nil
        self.unreadCount    = json["unread_count"].intValue
        let _lastComment    = json["last_comment"]
        
        self.lastComment    = QMessage(json: _lastComment, qiscusCore: nil)
        if let _participants    = json["participants"].array {
            var data = [QParticipant]()
            for i in _participants {
                data.append(QParticipant(json: i))
            }
            self.participants = data
        }
        
        self.totalParticipants = json["participants"].array?.count ?? 0
        if let _type = json["chat_type"].string {
            if _type == "group"{
                let _is_public_channel = json["is_public_channel"].bool ?? false
                
                if _is_public_channel == true {
                     self.type = .channel
                }else{
                    self.type = .group
                }
                
            }else{
                self.type = .single
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case idstr = "id_str"
        case name = "room_name"
        case uniqueId = "unique_id"
        case avatarUrl = "avatar_url"
        case chatType = "chat_type"
        case options = "options"

        case unreadCount = "unread_count"
    }
    
//    /// set room delegate to get event, and make sure set nil to disable event
//    public var delegate: QiscusCoreRoomDelegate? {
//        set {
//            QiscusEventManager.shared.roomDelegate = newValue
//            if newValue != nil {
//                QiscusEventManager.shared.room  = self
//                QiscusCore.realtime.subscribeRooms(rooms: [self])
//            }else {
//                QiscusCore.realtime.unsubscribeRooms(rooms: [self])
//                QiscusEventManager.shared.room  = nil
//            }
//        }
//        get {
//            return QiscusEventManager.shared.roomDelegate
//        }
//    }
    
    
}


