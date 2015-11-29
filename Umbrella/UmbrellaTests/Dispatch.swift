//
//  Dispatch.swift
//  Umbrella
//
//  Created by Stijn Willems on 29/11/15.
//  Copyright © 2015 dooz. All rights reserved.
//

import Foundation
import UIKit

class dispatch
{
	class async
	{
		class func bg(block: dispatch_block_t) {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block)
		}
		
		class func main(block: dispatch_block_t) {
			dispatch_async(dispatch_get_main_queue(), block)
		}
	}
	
	class sync
	{
		class func bg(block: dispatch_block_t) {
			dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block)
		}
		
		class func main(block: dispatch_block_t) {
			if NSThread.isMainThread() {
				block()
			}
			else {
				dispatch_sync(dispatch_get_main_queue(), block)
			}
		}
	}
	
	class func after(seconds:CGFloat,_ block: dispatch_block_t) {
		
		let dispatchTime = Int64(seconds * CGFloat(NSEC_PER_SEC))
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, dispatchTime), dispatch_get_main_queue(), block)
	}
	
}