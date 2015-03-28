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
    let qState = dispatch_queue_create("edu.self.deferred.q.state", DISPATCH_QUEUE_CONCURRENT)
    let qCallbacks = dispatch_queue_create("edu.self.deferred.q.callbacks", DISPATCH_QUEUE_CONCURRENT)
    
    private var callbacks: [State : [CallbackInvoker]] = [State : [CallbackInvoker]]()
    
    public init() {
        callbacks[.Rejected] = []
        callbacks[.Resolved] = []
    }
    
    public func promise() -> Promise {
        return PromiseImplementation(deferred: self)
    }

    // MARK: helpers
    func addOrRunCallback(callback: Callback, to: State, on queue: dispatch_queue_t = dispatch_get_main_queue()) {
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
    
    func setState(state: State, andRunCallbacksWithArg arg: AnyObject?) {
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