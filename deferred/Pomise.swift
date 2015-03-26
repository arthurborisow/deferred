//
//  Pomise.swift
//  deferred
//
//  Created by Arthur Borisow on 3/21/15.
//  Copyright (c) 2015 Arthur Borisow. All rights reserved.
//

import Foundation

public typealias Callback = AnyObject? -> Void

public protocol Promise {
    var state: State { get }
    
    // MARK: state
    func rejected() -> Bool
    func resolved() -> Bool
    
    // MARK: callbacks
    func done(callback: Callback) -> Promise
    func fail(callback: Callback) -> Promise
    func always(callback: Callback) -> Promise
}