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
    private let qState = dispatch_queue_create("edu.self.deferred.q.state", DISPATCH_QUEUE_CONCURRENT)
    private let qCallbacks = dispatch_queue_create("edu.self.deferred.q.callbacks", DISPATCH_QUEUE_CONCURRENT)
    
    
    private var callbacks: [State : [CallbackInvoker]] = [State : [CallbackInvoker]]()
    
    public init() {
        callbacks[.Rejected] = []
        callbacks[.Resolved] = []
    }
    
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
        var s: State?
        dispatch_sync(qState) { s = self.state }
        return s == .Rejected
    }
    
    public func resolved() -> Bool {
        var s: State?
        dispatch_sync(qState) { s = self.state }
        return s == .Resolved
    }
    
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

    // MARK: private helpers
    private func addOrRunCallback(callback: Callback, to: State, on queue: dispatch_queue_t = dispatch_get_main_queue()) {
        dispatch_async(qState) {
            switch (self.state, to) {
            case (.Pending, _):
                dispatch_barrier_async(self.qCallbacks) {
                    let _ = self.callbacks[to]?.append(CallbackInvoker(callback: callback, q: queue))
                }
            case (.Resolved, .Resolved),
                 (.Rejected, .Rejected):
                CallbackInvoker(callback: callback, q: queue).invoke(self.arg)
            default:
                break
            }
        }
    }
    
    private func setState(state: State, andRunCallbacksWithArg arg: AnyObject?) {
        dispatch_barrier_async(qState) {
            switch self.state {
            case .Pending:
                self.state = state
                self.arg = arg
                dispatch_async(self.qCallbacks) {
                    for callbackInvoker in self.callbacks[state]! {
                        callbackInvoker.invoke(self.arg)
                    }
                }
            default:
                break
            }
        }
    }
}