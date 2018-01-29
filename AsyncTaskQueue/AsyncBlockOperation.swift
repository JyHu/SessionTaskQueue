//
//  AsyncBlockOperation.swift
//  SessionTaskQueue-Swift
//
//  Created by 胡金友 on 2018/1/20.
//

import UIKit

typealias AsyncOperationTask = ((_ finished : inout Bool) -> Void)

class AsyncBlockOperation: Operation {
    
    private var asyncTask:AsyncOperationTask?
    
    init(asyncTask: @escaping AsyncOperationTask) {
        super.init()
        self.asyncTask = asyncTask
    }
    
    override func cancel() {
        self.asyncTask = nil
        super.cancel()
    }
    
    override func main() {
        if let task = self.asyncTask {
            var finished = false
            task(&finished)
            
            while !finished {
                RunLoop.current.run(mode: RunLoopMode.commonModes, before: NSDate.distantFuture)
            }
        }
    }
}
