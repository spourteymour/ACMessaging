//
//  MultiCast.swift
//  XMPPMessenger
//
//  Created by Sepandat Pourtaymour on 13/07/2019.
//  Copyright © 2019 Sepandat Pourtaymour. All rights reserved.
//

import Foundation

open class WeakDelegate: Equatable {
    
    public static func == (lhs: WeakDelegate, rhs: WeakDelegate) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String
    
    weak var delegate: AnyObject?
    
    public init(_ delegate: AnyObject, id: String) {
        self.delegate = delegate
        self.id = id
    }
}



/** This class provides support for invoking multiple delegate for multiple listeners. Each delegate is weak and when going over the list of delegates, invoke method automatically removes listeners, which no longer have valid reference.
 
 */

public protocol IdentifiableDelegte {
     var id: String {get}
}

open class MulticastDelegate<T> {
    
    private var delegates = [WeakDelegate]()
    
    public var hasDelegate: Bool {
        return delegates.count > 0
    }
    
    public init() {}
    
    public func addDelegate(_ delegate: T) {
        let lastIndex = String(delegates.count)
        let weakDelegate = WeakDelegate(delegate as AnyObject, id: lastIndex)
        delegates.append(weakDelegate)
    }
    
    public func invoke(_ invocation: (T) -> Void) {
        for i: Int in (0 ..< delegates.count).reversed() {
            let weakDelegate = delegates[i]
            
            if let delegate = weakDelegate.delegate as? T {
                invocation(delegate)
            } else {
                delegates.remove(at: i)
            }
        }
    }
    
    public func remove(_ delegate: T) {
        guard let identifiableDel = delegate as? IdentifiableDelegte else { return }
        
        delegates.removeAll {
            guard let comparedDel = $0 as? IdentifiableDelegte else { return false }
            return comparedDel.id == identifiableDel.id
        }
    }
}

