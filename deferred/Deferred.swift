//
//  Deferred.swift
//  deferred
//
//  Created by Arthur Borisow on 3/21/15.
//  Copyright (c) 2015 Arthur Borisow. All rights reserved.
//

import Foundation

public class Deferred: Promise {
    public private(set) var state: State = .Pending
    private var arg: AnyObject?
    
    private var callbacks: [State : [Callback]]? = {
        var dict = [State : [Callback]]()
        dict[.Rejected] = []
        dict[.Resolved] = []
        
        return dict
    }()
    
    public init() {}
    
    public func promise() -> Promise {
        return PromiseImplementation(deferred: self)
    }
    
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
        return state == .Rejected
    }
    
    public func resolved() -> Bool {
        return state == .Resolved
    }
    
    // MARK: callbacks
    public func done(callback: Callback) -> Promise {
        addOrRunCallback(callback, to: .Resolved)
        return self
    }
    
    public func fail(callback: Callback) -> Promise {
        addOrRunCallback(callback, to: .Rejected)
        return self
    }
    
    public func always(callback: Callback) -> Promise {
        addOrRunCallback(callback, to: .Resolved)
        addOrRunCallback(callback, to: .Rejected)
        return self
    }

    // MARK: private helpers
    private func addOrRunCallback(callback: Callback, to: State) {
        switch (state, to) {
        case (.Pending, _):
            callbacks![to]?.append(callback)
        case (.Resolved, .Resolved),
             (.Rejected, .Rejected):
            callback(arg)
        default:
            break
        }
    }
    
    private func setState(state: State, andRunCallbacksWithArg arg: AnyObject?) {
        switch self.state {
        case .Pending:
            self.state = state
            self.arg = arg
            for callback in callbacks![state]! {
                callback(arg)
            }
            callbacks = nil
        default:
            break
        }
    }
}