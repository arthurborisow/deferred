//
//  Promise.swift
//  deferred
//
//  Created by Arthur Borisow on 3/21/15.
//  Copyright (c) 2015 Arthur Borisow. All rights reserved.
//

import Foundation    

class PromiseImplementation: Promise {
    var state: State { return deferred.state }
    private var deferred: Deferred
    
    init(deferred: Deferred) {
        self.deferred = deferred
    }
    
    // MARK: state
    func rejected() -> Bool {
        return deferred.rejected()
    }
    
    func resolved() -> Bool {
        return deferred.resolved()
    }
    
    // MARK: callbacks
    func done(callback: Callback) -> Promise {
        return deferred.done(callback)
    }
    
    func fail(callback: Callback) -> Promise {
        return deferred.fail(callback)
    }
    
    func always(callback: Callback) -> Promise {
        return deferred.always(callback)
    }
}