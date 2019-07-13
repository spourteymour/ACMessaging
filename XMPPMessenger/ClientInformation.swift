//
//  ClientInformation.swift
//  XMPPMessenger
//
//  Created by Sepandat Pourtaymour on 13/07/2019.
//  Copyright © 2019 Sepandat Pourtaymour. All rights reserved.
//

import Foundation

enum MessageComponent: String {
    case senderId = "senderId"
    case text = "text"
    case timestamp = "timestamp"
    case receiverId = "receiverId"
    case imageUrl = "imageUrl"
    case imageHeight = "imageHeight"
    case imageWidth = "imageWidth"
    case videoUrl = "videoUrl"
    case id = "id"
    
    static func components() -> [MessageComponent] {
        return [.id, .senderId, .receiverId, .timestamp, .text, .imageUrl, .imageWidth, .imageHeight, .videoUrl]
    }
}

struct ClientInformation {
    var host: String
    var port: UInt16
    var otherInfo = [String: String]()
    
    var messageKeys = [MessageComponent: String]()
    init(url: String?) {
        var propertyListFormat = PropertyListSerialization.PropertyListFormat.xml
        var urlToUse: URL?
        if let receivedUrlString = url, let receivedUrl = URL(string: receivedUrlString) {
            urlToUse = receivedUrl
        } else {
            if let bundlePath = Bundle.main.path(forResource: "ConnectionInformation", ofType: ".plist") {
                let fileURL = URL(fileURLWithPath: bundlePath)
                urlToUse = fileURL
            }
        }
        guard let finalUrl = urlToUse, let plistData = try? Data(contentsOf: finalUrl),
            let plistDictionary = try? PropertyListSerialization.propertyList(from: plistData, options: .mutableContainersAndLeaves, format: &propertyListFormat) as? [String: String],
            let serverURLString = plistDictionary["host_name"],
            let portString = plistDictionary["host_port"],
            let port = UInt16(portString) else {
                fatalError("XMPPManager Crashed! Please make sure you have your plist added to the project, or have provided a valid url string for the plist.")
        }
        
        self.host = serverURLString
        self.port = port
        self.otherInfo = plistDictionary
        setupMessageComponents()
    }
    
    fileprivate mutating func setupMessageComponents() {
        let components = MessageComponent.components()
        components.forEach {
            guard let componentName = otherInfo[$0.rawValue] else {
                fatalError("XMPPManager Crashed! Please make sure you have your Message components added, and that the keys matches the values in the project. Could not find name or value for \($0.rawValue)")
            }
            messageKeys.updateValue(componentName, forKey: $0)
        }
    }
    
    init(hostname: String, port: UInt16, otherInfo: [String: String]) {
        self.host = hostname
        self.port = port
        self.otherInfo = otherInfo
    }
}
