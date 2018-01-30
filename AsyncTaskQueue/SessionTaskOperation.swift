//
//  SessionTaskOperation.swift
//  SessionTaskQueue-Swift
//
//  Created by 胡金友 on 2018/1/20.
//

import UIKit

private let _OperationFinishedKey = "isFinished"
private let _OperationExecutingKey = "isExecuting"

public class SessionTaskOperation: Operation {
    
    private var _task:URLSessionTask?
    
    private var hadEnqueue:Bool = false
    
    private var taskFinished:Bool = false
    private var taskExecuting:Bool = false
    
    public var sessionTask:URLSessionTask? {
        return self._task
    }
    
    public init(task:URLSessionTask) {
        super.init()
        self._task = task
    }
    
    override public func start() {
        guard !self.isCancelled else {
            self.willChangeValue(forKey: _OperationFinishedKey)
            self.taskFinished = true
            self.didChangeValue(forKey: _OperationFinishedKey)
            return
        }
        
        self.hadEnqueue = true
        
        self.willChangeValue(forKey: _OperationExecutingKey)
        self.taskExecuting = true
        self.didChangeValue(forKey: _OperationExecutingKey)
        
        self.main()
    }
    
    override public func main() {
        if let task = self.sessionTask {
            task.resume()
        }
    }
    
    override public func cancel() {
        if let task = self.sessionTask {
            task.cancel()
        }
        
        super.cancel()
    }
    
    override public var isAsynchronous: Bool {
        return true
    }
    
    override public var isExecuting: Bool {
        return self.taskExecuting
    }
    
    override public var isFinished: Bool {
        return self.taskFinished
    }
    
    public func completeExecute() {
        if self.hadEnqueue {
            self._task = nil
            self.willChangeValue(forKey: _OperationFinishedKey)
            self.willChangeValue(forKey: _OperationExecutingKey)
            
            self.taskExecuting = false
            self.taskFinished = true
            
            self.didChangeValue(forKey: _OperationFinishedKey)
            self.didChangeValue(forKey: _OperationExecutingKey)
        } else {
            self.cancel()
        }
    }
}
