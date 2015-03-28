//
//  CallbackInvoker.swift
//  deferred
//
//  Created by Arthur Borisow on 3/28/15.
//  Copyright (c) 2015 Arthur Borisow. All rights reserved.
//

import Foundation

class CallbackInvoker {
    private var callback: Callback
    private var q: dispatch_queue_t
    
    init(callback: Callback, q: dispatch_queue_t = dispatch_get_main_queue()) {
        self.callback = callback
        self.q = q
    }
    
    func invoke(arg: AnyObject?) {
        dispatch_async(q) {
            self.callback(arg)
        }
    }
}