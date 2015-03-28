//
//  deferredTests.swift
//  deferredTests
//
//  Created by Arthur Borisow on 3/21/15.
//  Copyright (c) 2015 Arthur Borisow. All rights reserved.
//

import UIKit
import XCTest

class PromiseTests: XCTestCase {
    var deferred: Deferred!
    var promise: Promise!
    var counter: Int!
    
    override func setUp() {
        super.setUp()
        
        deferred = Deferred()
        promise = deferred.promise().done { _ in
            self.counter = self.counter + 1
        }.done { c in
            if let c = c as? Int {
                self.counter = self.counter + c
            }
        }.fail { _ in
            self.counter = self.counter + 2
        }.fail { c in
            if let c = c as? Int {
                self.counter = self.counter + c
            }
        }.always { _ in
            self.counter = self.counter + 4
        }.always { c in
            if let c = c as? Int {
                self.counter = self.counter + c
            }
        }
        
        let exp = expectationWithDescription("resolve")
        deferred.always { _ in
            exp.fulfill()
        }
        
        counter = 0
    }
    
    private func wait() {
        waitForExpectationsWithTimeout(1, handler: {_ in })
    }
    
    func testResolve() {
        deferred.resolve()
        
        wait()
        
        XCTAssert(promise.resolved())
        XCTAssert(promise.state == .Resolved)
        XCTAssert(counter == 1 + 4)
    }
    
    func testResolveWith() {
        deferred.resolveWith(42)
        
        wait()
        
        XCTAssert(promise.resolved())
        XCTAssert(promise.state == .Resolved)
        XCTAssert(counter == 1 + 4 + 42 + 42)
    }
    
    func testReject() {
        deferred.reject()
        
        wait()
        
        XCTAssert(promise.rejected())
        XCTAssert(promise.state == .Rejected)
        XCTAssert(counter == 2 + 4)
    }
    
    func testRejectWith() {
        deferred.rejectWith(4242)
        
        wait()
        
        XCTAssert(promise.rejected())
        XCTAssert(promise.state == .Rejected)
        XCTAssert(counter == 2 + 4 + 4242 + 4242)
    }
    
    func testRejectAfterResolve() {
        deferred.resolve()
        
        wait()
        
        let c = counter
        deferred.reject()
        
        XCTAssert(promise.resolved())
        XCTAssert(promise.state == .Resolved)
        XCTAssert(c == counter)
    }
    
    func testResolveAfterReject() {
        deferred.reject()
        
        wait()
        
        let c = counter
        deferred.resolve()
        
        XCTAssert(promise.rejected())
        XCTAssert(promise.state == .Rejected)
        XCTAssert(c == counter)
    }
    
    func testAddingCallbacksAfterResolving() {
        deferred.resolve()
        
        wait()
        
        let c = counter
        let exp = expectationWithDescription("testAddingCallbacksAfterResolving")
        promise.done { _ in
            self.counter = self.counter + 42
        }.fail { _ in
            self.counter = self.counter + 4242
        }.always { _ in
            self.counter = self.counter + 424242
        }.always { _ in
            exp.fulfill()
        }
        
        wait()
        
        XCTAssert(counter == c + 42 + 424242)
    }
    
    func testAddingCallbacksAfterRejecting() {
        deferred.reject()
        
        wait()
        
        let c = counter
        
        let exp = expectationWithDescription("testAddingCallbacksAfterRejecting")
        promise.done { _ in
            self.counter = self.counter + 42
        }.fail { _ in
            self.counter = self.counter + 4242
        }.always { _ in
            self.counter = self.counter + 424242
        }.always { _ in
            exp.fulfill()
        }
        
        wait()
        
        XCTAssert(counter == c + 4242 + 424242)
    }
    
    func testAddingOnSpecifiedQueue() {
        var d = Deferred()
        let q = dispatch_queue_create("edu.self.deferred.q.test", DISPATCH_QUEUE_SERIAL)
        var c = 0
        let exp = expectationWithDescription("testAddingOnSpecifiedQueue")
        deferred.doneOn(q) { _ in
            c = 10
            exp.fulfill()
        }
        deferred.resolve()
        
        wait()
        
        XCTAssert(c == 10)
    }
}
