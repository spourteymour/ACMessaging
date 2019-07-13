//
//  CommunicationManager.swift
//  XMPPMessenger
//
//  Created by Sepandat Pourtaymour on 13/07/2019.
//  Copyright © 2019 Sepandat Pourtaymour. All rights reserved.
//

import Foundation
import XMPPFramework

enum XMPPControllerError: Error {
    case wrongUserJID
}

//previously ChatDelegate
protocol XMPPManagerDelegate: class {
    var id: String {get}
    
    func didReceive(message:Message)
    
    func didConnect(to host: String)
    func didDisconnect(from host: String, error: Error?)

    func didTimeOut(from host: String)
    func didReceiveError(error: Error)
    
    func didRegister(with host: String)
    func didAuthenticate(with host: String)
    
    func didReceiveIQ(iq: XMPPIQ)
    func didReceivePresence(presence: ACChatPresence)
    func didReceiveRosterItem(item: DDXMLElement, fromRoster roster: XMPPRoster)
    func didReceiveMessage(message: Message)
    
    func didSendMessage(message: Message)
}

let dummyHostServer = "vps395261.ovh.net"
let dummyHostPort: UInt16 = 5222

class CommunicationManager: NSObject {
    static let communicationQueue = DispatchQueue(label: "communication-queue")
    static let shared = CommunicationManager(url: nil)
    
    var xmppStream: XMPPStream
    
    fileprivate var clientInfo: ClientInformation
    fileprivate var currentUserId:XMPPJID? = nil
    var credentials: UserCredential?
    var delegates:MulticastDelegate<XMPPManagerDelegate>! = nil
    var userIdInConversation:String? = nil

    init(url: String?) {
        let info = ClientInformation(url: url)
        self.clientInfo = info
        self.xmppStream = XMPPStream()
        self.xmppStream.hostName = info.host
        self.xmppStream.hostPort = info.port
        self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
        
        super.init()
        self.xmppStream.addDelegate(self, delegateQueue: CommunicationManager.communicationQueue)
    }
    
    init(hostName: String, hostPort: UInt16 = 5222) {
        self.clientInfo = ClientInformation(hostname: hostName, port: hostPort, otherInfo: [:])
        self.xmppStream = XMPPStream()
        self.xmppStream.hostName = hostName
        self.xmppStream.hostPort = hostPort
        self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
        
        super.init()
        self.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    func login(id: String, password: String) {
        let creds = UserCredential(id: id, password: password, userInfo: [:])
        self.credentials = creds
        self.xmppStream.myJID = creds.jabberID
        _ = connect()
    }
    
    func add(delegate:XMPPManagerDelegate, currentUserInConversation:String? = nil) {
        self.delegates.addDelegate(delegate)
    }
    
    func remove(delegate:XMPPManagerDelegate, currentUserInConversation:String? = nil) {
        if currentUserInConversation != nil {
            userIdInConversation = nil
        }
        delegates.remove(delegate)
        if !delegates.hasDelegate {
            //TODO: Detach from XMPPDelegate?
        }
    }
    
    fileprivate func goOnline() {
        let presence = XMPPPresence()
        //        let domain = xmppStream.myJID.domain
        
        //        if domain == "gmail.com" || domain == "gtalk.com" || domain == "talk.google.com" {
        //            let priority = DDXMLElement.element(withName: "priority", stringValue: "24") as! DDXMLElement
        //            presence?.addChild(priority)
        //        }
        let priority = DDXMLElement.element(withName: "priority", stringValue: "24") as! DDXMLElement
        presence.addChild(priority)
        xmppStream.send(presence)
    }
    
    fileprivate func goOffline() {
        let presence = XMPPPresence(type: "unavailable")
        xmppStream.send(presence)
    }
    
    //
    //    func register(username:String, password:String) {
    //        do {
    //            try xmppStream.register(withPassword: CurrentUser.instance.id())
    //        } catch {
    //
    //        }
    //    }
    
    func connect() -> Bool {
        if !xmppStream.isConnected {
            guard let creds = credentials else { return false }
            
            if !xmppStream.isDisconnected {
                return true
            }
            
            xmppStream.myJID = creds.jabberID
            
            do {
                try xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
                print("Connection success")
                return true
            } catch XMPPStreamErrorCode.invalidParameter {
                
                print("Something went wrong!")
                return false
            } catch XMPPStreamErrorCode.invalidProperty {
                
                print("Something went wrong!")
                return false
            } catch XMPPStreamErrorCode.invalidState {
                
                print("Something went wrong!")
                return false
            } catch XMPPStreamErrorCode.invalidType {
                
                print("Something went wrong!")
                return false
            } catch {
                print("Something went wrong!")
                return false
            }
        } else {
            return true
        }
    }
    
    func disconnect() {
        goOffline()
        xmppStream.disconnect()
    }
    
    
    func sendMessage(message:Message) {
        let receiverJID = XMPPJID(string: message.recipientId!)
        let msg = XMPPMessage(type: "chat", to: receiverJID)
        if let messageText = message.text {
            let element:DDXMLNode = DDXMLNode.attribute(withName: textKey, stringValue: messageText) as! DDXMLNode
            msg.addAttribute(element)
        }
        if let messageFrom = message.senderId {
            let element:DDXMLNode = DDXMLNode.attribute(withName: senderIdKey, stringValue: messageFrom) as! DDXMLNode
            msg.addAttribute(element)
        }
        if let messageTimestamp = message.timestamp?.stringValue {
            let element:DDXMLNode = DDXMLNode.attribute(withName: timestampKey, stringValue: messageTimestamp) as! DDXMLNode
            msg.addAttribute(element)
        }
        if let messageVidUrl = message.videoUrl {
            let element:DDXMLNode = DDXMLNode.attribute(withName: videoUrlKey, stringValue: messageVidUrl) as! DDXMLNode
            msg.addAttribute(element)
        }
        if let messageImageUrl = message.imageUrl {
            var array:[DDXMLNode] = []
            if let height = message.imageHeight?.stringValue {
                let heightElement:DDXMLNode = DDXMLNode.element(withName: imageHeightKey, stringValue: height) as! DDXMLNode
                array.append(heightElement)
            }
            if let width = message.imageWidth?.stringValue {
                let widthElement:DDXMLNode = DDXMLNode.element(withName: imageWidthKey, stringValue: width) as! DDXMLNode
                array.append(widthElement)
            }
            if let width = message.imageHeight?.stringValue {
                let widthElement:DDXMLNode = DDXMLNode.element(withName: imageWidthKey, stringValue: width) as! DDXMLNode
                array.append(widthElement)
            }

            let imageUrlElement:DDXMLNode = DDXMLNode.element(withName: imageUrlKey, stringValue: messageImageUrl) as! DDXMLNode
            let imageUrlAtt:DDXMLNode = DDXMLNode.attribute(withName: imageUrlKey, stringValue: messageImageUrl) as! DDXMLNode
            
            if array.count > 0 {
                let element:DDXMLNode = DDXMLNode.element(withName: imageUrlKey, children: array, attributes: [imageUrlAtt]) as! DDXMLNode
                msg.addAttribute(element)
            } else {
                msg.addAttribute(imageUrlElement)
            }
        }
        print(msg)
        xmppStream.send(msg)
        delegates.invoke{$0.didSendMessage(message: message)}
//        saveSentMessage(message: message)
    }
}


extension CommunicationManager: XMPPStreamDelegate {
    //MARK: XMPP Callback Methods
    
    fileprivate func getCombinedHostName(from stream: XMPPStream) -> String {
        var toRet = ""
        if let name = stream.hostName {
            let port = String(describing: stream.hostPort)
            toRet = String(format: "%@: %@", name, port )
        }
        return toRet
    }
    
    func xmppStreamDidConnect(sender: XMPPStream!) {
        guard let cred = credentials, let password = cred.hashedPassword else {
            disconnect()
            return
        }
        
        delegates.invoke{$0.didConnect(to: getCombinedHostName(from: sender))}
        
        do {
            try xmppStream.authenticate(withPassword: password)
        } catch {
            print("Could not authenticate")
        }
    }
    
    func xmppStreamWasTold(toDisconnect sender: XMPPStream) {
        delegates.invoke{$0.didDisconnect(from: getCombinedHostName(from: sender), error: nil)}
    }
    
    func xmppStreamDidDisconnect(_ sender: XMPPStream, withError error: Error?) {
        delegates.invoke{$0.didDisconnect(from: getCombinedHostName(from: sender), error: error)}
    }
    
    func xmppStreamConnectDidTimeout(_ sender: XMPPStream) {
        delegates.invoke{$0.didTimeOut(from: getCombinedHostName(from: sender))}
        print("timeout")
    }
    
    func xmppStreamDidRegister(_ sender: XMPPStream) {
        delegates.invoke{$0.didRegister(with: getCombinedHostName(from: sender))}
        print("Registered Successfully")
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        delegates.invoke{$0.didAuthenticate(with: getCombinedHostName(from: sender))}
        goOnline()
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool {
        //TODO: Do something about the IQ
        delegates.invoke{$0.didReceiveIQ(iq: iq)}
        print("Did receive IQ")
        return false
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        let presenceType = presence.type
        let myUsername = sender.myJID?.user
        let presenceFromUser = presence.from?.user
        
        if presenceFromUser != myUsername {
            print("Did receive presence from \(String(describing: presenceFromUser))")
            if presenceType == "available" {
                print("Buddy went online: \(String(describing: presenceFromUser))@gmail.com")
                //                delegate.buddyWentOnline(name: "\(presenceFromUser)@gmail.com")
            } else if presenceType == "unavailable" {
                print("Buddy went offline: \(String(describing: presenceFromUser))@gmail.com")
                //                delegate.buddyWentOffline(name: "\(presenceFromUser)@gmail.com")
            }
        }
        let presence = ACChatPresence(type: presence.type, show: presence.show, status: presence.status, priority: presence.priority, availability: ACChatPresenceAvailability.withXMPPPresence(presence: presence))
        delegates.invoke{$0.didReceivePresence(presence: presence)}
    }
    
    func xmppRoster(sender: XMPPRoster!, didReceiveRosterItem item: DDXMLElement!) {
        print("Did receive Roster item: \(String(describing: item))")
        delegates.invoke{ $0.didReceiveRosterItem(item: item, fromRoster: sender)}
    }
    
    //MARK: Send and Receive Message
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        
        print("Did receive message \(String(describing: message))")
        
        var messageDict:Dictionary<String,AnyObject> = [:]
        
        let idKey = clientInfo.messageKeys[MessageComponent.id]!
        let senderIdKey = clientInfo.messageKeys[MessageComponent.senderId]!
        let timestampKey = clientInfo.messageKeys[MessageComponent.timestamp]!
        let receiverIdKey = clientInfo.messageKeys[MessageComponent.receiverId]!
        let textKey = clientInfo.messageKeys[.text]!
        let imageUrlKey = clientInfo.messageKeys[MessageComponent.imageUrl]!
        let imageHeightKey = clientInfo.messageKeys[MessageComponent.imageHeight]!
        let imageWidthKey = clientInfo.messageKeys[MessageComponent.imageWidth]!
        let videoUrlKey = clientInfo.messageKeys[MessageComponent.videoUrl]!
        
        for attribute:DDXMLNode in message.attributes! {
            if attribute.name == textKey {
                messageDict[textKey] = attribute.stringValue as AnyObject?
            }
            
            if attribute.name == senderIdKey {
                messageDict[senderIdKey] = attribute.stringValue as AnyObject?
            }
            
            if attribute.name == timestampKey {
                messageDict[timestampKey] = attribute.stringValue as AnyObject?
            }
            
            if attribute.name == imageUrlKey {
                if (attribute.children?.count)! > 0 {
                    for childAtt:DDXMLNode in attribute.children! {
                        if childAtt.name == imageHeightKey {
                            messageDict[imageHeightKey] = childAtt.stringValue as AnyObject?
                        }
                        if childAtt.name == imageWidthKey {
                            messageDict[imageWidthKey] = childAtt.stringValue as AnyObject?
                        }
                    }
                }
                messageDict[imageUrlKey] = attribute.stringValue as AnyObject?
            }
            
            if attribute.name == videoUrlKey {
                messageDict[videoUrlKey] = attribute.stringValue as AnyObject?
            }
            
            messageDict[idKey] = attribute.uri as AnyObject?
        }
        
        messageDict[receiverIdKey] = message.to?.user as AnyObject?
        print("Did receive messageDict \(messageDict)")
        let message:Message = Message(dictionary: messageDict)
        delegates.invoke{$0.didReceive(message: message)}

//        if userIdInConversation != nil {
//            //In the chat view
//            if message.senderId == userIdInConversation {
//                delegates.invoke{$0.didReceive(message: message)}
//            } else {
//                //Message received, user in chat but the message received is not for the user in chat
//                //TODO: show a banner informing the user about the new message received
//                if delegate != nil {
//                    delegate.didReceive(message: message)
//                    //No need to send any notification, there's a delegate registered.
//                } else {
//                    //                    NotificationCenter.default.post(name: NSNotification.Name.shouldShowNewMessageReceipt, object: message)
//                }
//            }
//        } else {
//            //User is not chatting with anyone
//            if delegate != nil {
//                //Someone is the delegate, save the message and send the message to delegate.
//                delegate.didReceive(message: message)
//            } else {
//                //NO chat open, and no delegate.
//                //TODO: send a notification to display the banner, so wherever the useer is, they will see the notification.
//                //TODO: Add gesture recogniser to the banner so that when they tap on the banner, they will be redirected to the ChatLogController containing the user message.
//                //                NotificationCenter.default.post(name: NSNotification.Name.shouldShowNewMessageReceipt, object: message)
//            }
//        }
//        saveReceivedMessage(message: message)
        
    }
    
    func xmppStream(sender: XMPPStream!, didSendMessage message: XMPPMessage!) {
        print("Did send message \(String(describing: message))")
        //TODO: Save message in the user message dictionary
    }
}

extension CommunicationManager {
    var idKey: String {
        return clientInfo.messageKeys[MessageComponent.id]!
    }
    
    var senderIdKey: String {
        return clientInfo.messageKeys[MessageComponent.senderId]!
    }
    
    var timestampKey: String {
        return clientInfo.messageKeys[MessageComponent.timestamp]!
    }
    
    var receiverIdKey: String {
        return clientInfo.messageKeys[MessageComponent.receiverId]!
    }
    
    var textKey: String {
        return clientInfo.messageKeys[MessageComponent.text]!
    }
    
    var imageUrlKey: String {
        return clientInfo.messageKeys[MessageComponent.imageUrl]!
    }

    var imageHeightKey: String {
        return clientInfo.messageKeys[MessageComponent.imageHeight]!
    }

    var imageWidthKey: String {
        return clientInfo.messageKeys[MessageComponent.imageWidth]!
    }

    var videoUrlKey: String {
        return clientInfo.messageKeys[MessageComponent.videoUrl]!
    }
}
