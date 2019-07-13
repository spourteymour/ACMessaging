//
//  ACChatPresence.swift
//  XMPPMessenger
//
//  Created by Sepandat Pourtaymour on 13/07/2019.
//  Copyright © 2019 Sepandat Pourtaymour. All rights reserved.
//

import Foundation
import XMPPFramework

enum ACChatPresenceAvailability {
    /** Do not disturb */
    case dnd
    /** Extended Away */
    case extAway
    /** Away */
    case away
    /** Unrecognized value, or not present */
    case other
    /** Active and available for chatting */
    case available
    
    static func withXMPPPresence(presence: XMPPPresence) -> ACChatPresenceAvailability {
        switch presence.showValue {
        case .away: return .away
        case .chat: return .available
        case .DND: return .dnd
        case .XA: return .extAway
        default: return .other
        }
    }
}

struct ACChatPresence {
    var type: String?
    var show: String?
    var status: String?
    var priority: Int?
    
    var availability: ACChatPresenceAvailability
}
