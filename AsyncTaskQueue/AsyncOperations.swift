//
//  AsyncOperations.swift
//  AsyncTaskQueue
//
//  Created by 胡金友 on 2018/1/30.
//

import UIKit

public protocol OperationTaskProtocol {
    func completeExecute()
}

open class AsyncOperation: Operation, OperationTaskProtocol {
    fileprivate var opFinished:Bool = false
    
    override open func cancel() {
        self.opFinished = true
        super.cancel()
    }
    
    public func completeExecute() {
        self.opFinished = true
    }
}

public class AsyncBlockOperation: AsyncOperation {
    private var asyncTask:(() -> Void)?
    
    public init(asyncTask: @escaping (() -> Void)) {
        super.init()
        self.asyncTask = asyncTask
    }
    
    override public func main() {
        if let task = self.asyncTask, !self.opFinished {
            task()
            while !self.opFinished {
                RunLoop.current.run(mode: RunLoopMode.commonModes, before: NSDate.distantFuture)
            }
        }
    }
}

public class SessionTaskOperation: AsyncOperation {
    private var _task:URLSessionTask?
    public var sessionTask:URLSessionTask? {
        return self._task
    }
    
    public init(task:URLSessionTask) {
        super.init()
        self._task = task
    }
    
    override public func main() {
        if let task = self.sessionTask, !self.opFinished {
            task.resume()
            while !self.opFinished {
                RunLoop.current.run(mode: RunLoopMode.commonModes, before: NSDate.distantFuture)
            }
        }
    }
}
