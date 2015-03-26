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
        
        counter = 0
    }
    
    override func tearDown() {
        promise = nil
        
        super.tearDown()
    }
    
    func testResolve() {
        deferred.resolve()
        
        XCTAssert(promise.resolved())
        XCTAssert(promise.state == .Resolved)
        XCTAssert(counter == 1 + 4)
    }
    
    func testResolveWith() {
        deferred.resolveWith(42)
        
        XCTAssert(promise.resolved())
        XCTAssert(promise.state == .Resolved)
        XCTAssert(counter == 1 + 4 + 42 + 42)
    }
    
    func testReject() {
        deferred.reject()
        
        XCTAssert(promise.rejected())
        XCTAssert(promise.state == .Rejected)
        XCTAssert(counter == 2 + 4)
    }
    
    func testRejectWith() {
        deferred.rejectWith(4242)
        
        XCTAssert(promise.rejected())
        XCTAssert(promise.state == .Rejected)
        XCTAssert(counter == 2 + 4 + 4242 + 4242)
    }
    
    func testRejectAfterResolve() {
        deferred.resolve()
        let c = counter
        deferred.reject()
        
        XCTAssert(promise.resolved())
        XCTAssert(promise.state == .Resolved)
        XCTAssert(c == counter)
    }
    
    func testResolveAfterReject() {
        deferred.reject()
        let c = counter
        deferred.resolve()
        
        XCTAssert(promise.rejected())
        XCTAssert(promise.state == .Rejected)
        XCTAssert(c == counter)
    }
    
    func testAddingCallbacksAfterResolving() {
        deferred.resolve()
        let c = counter
        promise.done { _ in
            self.counter = self.counter + 42
        }.fail { _ in
            self.counter = self.counter + 4242
        }.always { _ in
            self.counter = self.counter + 424242
        }
        
        XCTAssert(counter == c + 42 + 424242)
    }
    
    func testAddingCallbacksAfterRejecting() {
        deferred.reject()
        let c = counter
        promise.done { _ in
            self.counter = self.counter + 42
        }.fail { _ in
            self.counter = self.counter + 4242
        }.always { _ in
            self.counter = self.counter + 424242
        }
        
        XCTAssert(counter == c + 4242 + 424242)
    }
    
}
