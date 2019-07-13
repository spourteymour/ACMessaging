//
//  Image.swift
//  XMPPMessenger
//
//  Created by Sepandat Pourtaymour on 13/07/2019.
//  Copyright © 2019 Sepandat Pourtaymour. All rights reserved.
//

import UIKit

struct Image {
    var url: String?
    var height: CGFloat?
    var width: CGFloat?
    
    
    init?(dictionary: [String: Any]) {
        url = dictionary[CommunicationManager.shared.imageUrlKey] as? String
        height = dictionary[CommunicationManager.shared.imageHeightKey] as? CGFloat
        width = dictionary[CommunicationManager.shared.imageWidthKey] as? CGFloat

    }

    
    init(url: String?, width: CGFloat?, height: CGFloat?) {
        self.url = url
        self.width = width
        self.height = height
    }

    func encode(with coder: NSCoder) {
        coder.encode(url, forKey: CommunicationManager.shared.imageUrlKey)
        coder.encode(height, forKey: CommunicationManager.shared.imageHeightKey)
        coder.encode(width, forKey: CommunicationManager.shared.imageWidthKey)
    }
}

extension Image: Codable {
    
}
