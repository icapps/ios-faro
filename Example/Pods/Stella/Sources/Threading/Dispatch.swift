//
//  Dispatch.swift
//  Pods
//
//  Created by Jelle Vandebeeck on 06/06/16.
//
//

/**
 Submits a block for asynchronous execution on the main dispatch queue.
 
 - Parameter block: The block to submit to the target dispatch queue.
 */
public func dispatch_on_main(block: dispatch_block_t) {
    dispatch_async(dispatch_get_main_queue()) { 
        block()
    }
}

/**
 Submits a block for asynchronous execution on a background dispatch queue.
 
 - Parameter block: The block to submit to the target dispatch queue.
 */
public func dispatch_in_background(block: dispatch_block_t) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        block()
    }
}

/**
 Submits a block for asynchronous execution on the main dispatch queue after a delay.
 
 - Parameter seconds: The delay before the block is executed expressed in seconds.
 - Parameter block: The block to submit to the target dispatch queue.
 */
public func dispatch_on_main(after seconds: UInt64, block: dispatch_block_t) {
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * NSEC_PER_SEC))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
        block()
    }
}

/**
 Submits a block for synchronous execution. Trigger the completetion function from the
 calling object in order to indicate that the asynchronous execution fininshed.
 
 Example:
 ```
 dispatch_wait { completion in
    performAsynchrounousTask {
        completion()
    }
 }
 ```
 
 - Parameter block: The block to submit to the target dispatch queue.
 */
public func dispatch_wait(for block: (completion: () -> ()) -> ()) {
    let semaphore = dispatch_semaphore_create(0)!
    let queue = dispatch_queue_create("com.icapps.stella.waitqueue", nil)!
    dispatch_async(queue) {
        block {
            dispatch_semaphore_signal(semaphore)
        }
    }
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
}