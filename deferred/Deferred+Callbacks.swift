//
//  Deferred+Callbacks.swift
//  deferred
//
//  Created by Arthur Borisow on 3/28/15.
//  Copyright (c) 2015 Arthur Borisow. All rights reserved.
//

import Foundation

extension Deferred {
    // MARK: callbacks
    public func done(callback: Callback) -> Promise {
        addOrRunCallback(callback, to: .Resolved)
        return self
    }
    public func doneOn(q: dispatch_queue_t, callback: Callback) -> Promise {
        addOrRunCallback(callback, to: .Resolved, on: q)
        return self
    }
    
    public func fail(callback: Callback) -> Promise {
        addOrRunCallback(callback, to: .Rejected)
        return self
    }
    
    public func failOn(q: dispatch_queue_t, callback: Callback) -> Promise {
        addOrRunCallback(callback, to: .Rejected, on: q)
        return self
    }
    
    public func always(callback: Callback) -> Promise {
        addOrRunCallback(callback, to: .Resolved)
        addOrRunCallback(callback, to: .Rejected)
        return self
    }
    
    public func alwaysOn(q: dispatch_queue_t, callback: Callback) -> Promise {
        addOrRunCallback(callback, to: .Resolved, on: q)
        addOrRunCallback(callback, to: .Rejected, on: q)
        return self
    }
}