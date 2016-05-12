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
public class dispatch
{
    public class async
    {
        public class func bg(block: dispatch_block_t) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block)
        }
        
        public class func main(block: dispatch_block_t) {
            dispatch_async(dispatch_get_main_queue(), block)
        }
    }
    
	public class sync
    {
		public class func bg(block: dispatch_block_t) {
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block)
        }
        
        public class func main(block: dispatch_block_t) {
            if NSThread.isMainThread() {
                block()
            }
            else {
                dispatch_sync(dispatch_get_main_queue(), block)
            }
        }
    }
    
    public class func after(seconds:CGFloat,_ block: dispatch_block_t) {
        
        let dispatchTime = Int64(seconds * CGFloat(NSEC_PER_SEC))
        
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, dispatchTime), dispatch_get_main_queue(), block)
    }    
}
