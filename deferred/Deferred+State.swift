//
//  Deferred+State.swift
//  deferred
//
//  Created by Arthur Borisow on 3/28/15.
//  Copyright (c) 2015 Arthur Borisow. All rights reserved.
//

import Foundation

extension Deferred {
    // MARK: resolving
    public func resolveWith(arg: AnyObject?) {
        setState(.Resolved, andRunCallbacksWithArg: arg)
    }
    
    public func resolve() {
        resolveWith(nil)
    }
    
    // MARK: rejecting
    public func rejectWith(arg: AnyObject?) {
        setState(.Rejected, andRunCallbacksWithArg: arg)
    }
    
    public func reject() {
        rejectWith(nil)
    }
    
    // MARK: state
    public func rejected() -> Bool {
        var s: State?
        dispatch_sync(qState) { s = self.state }
        return s == .Rejected
    }
    
    public func resolved() -> Bool {
        var s: State?
        dispatch_sync(qState) { s = self.state }
        return s == .Resolved
    }
}