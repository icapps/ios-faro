//
//  AirRivet
//
//  Created by Stijn Willems on 07/04/16.
//  2016 iCapps. MIT Licensed.
//

import Foundation
/**
Use class functions to easily change queue's.
*/
open class dispatch {
    
    open class async {
        open class func bg(_ block: @escaping ()->()) {
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: block)
        }
        
        open class func main(_ block: @escaping ()->()) {
            DispatchQueue.main.async(execute: block)
        }
    }
    
	open class sync {
		open class func bg(_ block: ()->()) {
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).sync(execute: block)
        }
        
        open class func main(_ block: ()->()) {
            if Thread.isMainThread {
                block()
            }
            else {
                DispatchQueue.main.sync(execute: block)
            }
        }
    }
    
    open class func after(_ seconds: Float,_ block: @escaping ()->()) {
        let dispatchTime = Int64(seconds * Float(NSEC_PER_SEC))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(dispatchTime) / Double(NSEC_PER_SEC), execute: block)
    }    
}
