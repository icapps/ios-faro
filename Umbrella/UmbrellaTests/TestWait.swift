//
//  TestWait.swift
//  Umbrella
//
//  Created by Stijn Willems on 29/11/15.
//  Copyright © 2015 dooz. All rights reserved.
//

import Foundation
import UIKit

class TestWait: NSObject {
	
	var isWaiting = false
	var expectations = Set<String>()
	
	func waitForTime(seconds:CGFloat) {
		
		dispatch.after(seconds) {
			dispatch.async.main({ () -> Void in
				self.finish()
			})
		}
		
		self.waitUntillFinish()
	}
 
	func waitUntillFinish() {
		isWaiting = true
		
		while isWaiting {
			NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0.1))
		}
	}
	
	func fulFillExpectation(expectation:String) {
		
		if expectations.contains(expectation) {
			
			expectations.remove(expectation)
			
			if expectations.isEmpty {
				self.finish()
			}
		}
		else {
			let localExp = expectation
			dispatch.async.main {
				print("TestWait did not contain expectation \(localExp). Either you did not set it or you fullfilled it already.")
			}
			
		}
	}
	
	func waitUntillFinishWithTimeout(timeOut:CGFloat, completion:((success:Bool,unfulFilledExpectations:Set<String>)->())) {
		isWaiting = true
		
		let startTime = NSDate().timeIntervalSince1970
		
		while isWaiting {
			NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0.1))
			
			let currentTime = NSDate().timeIntervalSince1970
			
			if CGFloat(currentTime - startTime) > timeOut {
				
				completion(success: expectations.isEmpty, unfulFilledExpectations: expectations)
				
				return
			}
		}
		completion(success: expectations.isEmpty, unfulFilledExpectations: expectations)
	}
	
	func finish() {
		isWaiting = false
	}
}