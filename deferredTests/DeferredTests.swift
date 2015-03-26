//
//  deferredTests.swift
//  deferredTests
//
//  Created by Arthur Borisow on 3/21/15.
//  Copyright (c) 2015 Arthur Borisow. All rights reserved.
//

import UIKit
import XCTest

class DeferredTests: XCTestCase {
    var deferred: Deferred!
    var counter: Int!
    
    override func setUp() {
        super.setUp()
        
        deferred = Deferred()
        deferred.done { _ in
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
        deferred = nil
        
        super.tearDown()
    }
    
    func testResolve() {
        deferred.resolve()
        
        XCTAssert(deferred.resolved())
        XCTAssert(deferred.state == .Resolved)
        XCTAssert(counter == 1 + 4)
    }
    
    func testResolveWith() {
        deferred.resolveWith(42)
        
        XCTAssert(deferred.resolved())
        XCTAssert(deferred.state == .Resolved)
        XCTAssert(counter == 1 + 4 + 42 + 42)
    }
    
    func testReject() {
        deferred.reject()
        
        XCTAssert(deferred.rejected())
        XCTAssert(deferred.state == .Rejected)
        XCTAssert(counter == 2 + 4)
    }
    
    func testRejectWith() {
        deferred.rejectWith(4242)
        
        XCTAssert(deferred.rejected())
        XCTAssert(deferred.state == .Rejected)
        XCTAssert(counter == 2 + 4 + 4242 + 4242)
    }
    
    func testRejectAfterResolve() {
        deferred.resolve()
        let c = counter
        deferred.reject()
        
        XCTAssert(deferred.resolved())
        XCTAssert(deferred.state == .Resolved)
        XCTAssert(c == counter)
    }
    
    func testResolveAfterReject() {
        deferred.reject()
        let c = counter
        deferred.resolve()
        
        XCTAssert(deferred.rejected())
        XCTAssert(deferred.state == .Rejected)
        XCTAssert(c == counter)
    }
    
    func testAddingCallbacksAfterResolving() {
        deferred.resolve()
        let c = counter
        deferred.done { _ in
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
        deferred.done { _ in
            self.counter = self.counter + 42
        }.fail { _ in
            self.counter = self.counter + 4242
        }.always { _ in
            self.counter = self.counter + 424242
        }
        
        XCTAssert(counter == c + 4242 + 424242)
    }

}
