import Foundation
// Use class functions to easily change queue's.
public class dispatch { // tailor:disable
    
    public class async { // tailor:disable
        public class func bg(block: dispatch_block_t) { // tailor:disable
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block)
        }
        
        public class func main(block: dispatch_block_t) {
            dispatch_async(dispatch_get_main_queue(), block)
        }

    }
    
    public class sync { // tailor:disable
        public class func bg(block: dispatch_block_t) { // tailor:disable
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
    
    public class func after(seconds: Float,_ block: dispatch_block_t) { // tailor:disable

        let dispatchTime = Int64(seconds * Float(NSEC_PER_SEC))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, dispatchTime), dispatch_get_main_queue(), block)
    }
    
}
