//
//  OperationQueue+Helper.swift
//  AsyncTaskQueue
//
//  Created by 胡金友 on 2018/1/27.
//

import UIKit

/// 队列任务监听的类型
///
/// - Changed: 当有变化的时候就回调
/// - AllCompleted: 当所有任务都结束以后回调
public enum OperationQueueObserverType {
    case Changed
    case AllCompleted
}

public extension Operation {
    
    /// 给当前的Operation添加多个依赖
    ///
    /// - Parameter operations: Operation列表
    public func addDependencies(_ operations:[Operation]?) {
        if let ops = operations {
            for op in ops {
                self.addDependency(op)
            }
        }
    }
}

public extension OperationQueue {
    
    /// 单例并行队列
    /// `maxConcurrentOperationCount`默认设置为10
    public class var concurrent: OperationQueue {
        get { return Global.concurrent }
    }
    
    /// 单例串行队列
    /// 不建议修改`maxConcurrentOperationCount`
    public class var serial: OperationQueue {
        get { return Global.serial }
    }
    
    /// 添加一个sesstionTask到队列中
    ///
    /// - Parameter sessionTask: sessionTask
    public func addSessionTask(_ sessionTask:URLSessionTask) {
        self.addOperation(SessionTaskOperation(task: sessionTask))
    }
    
    /// 添加一个异步的任务到队列中
    ///
    /// - Parameter asyncBlock: 异步任务
    ///         finished: 当设置为True的时候表示结束闭包任务
    public func addAsyncOperation(_ asyncBlock:@escaping ((_ finished : inout Bool) -> Void)) {
        self.addOperation(AsyncBlockOperation(asyncTask: asyncBlock))
    }
    
    /// 完成一个sessionTask任务，因为无法监听其过程，所以，需要再任务完成以后调用这个方法来通知队列任务完成
    ///
    /// - Parameter sessionTask: sessionTask
    public func completeSessionTask(_ sessionTask:URLSessionTask) {
        self.completeOperation(self.operationFrom(sessionTask))
    }
    
    /// 完成一个operation任务，主要是针对`sessionTask`因为无法监听其过程，所以，需要再任务完成以后调用这个方法来通知队列任务完成
    ///
    /// - Parameter operation: SessionTaskOperation
    public func completeOperation(_ operation:SessionTaskOperation?) {
        if let op = operation {
            op.completeExecute()
        }
    }
    
    /// 根据一个网络请求的task来找到对应的Operation
    ///
    /// - Parameter sessionTask: sessionTask
    /// - Returns: SessiontaskOperation
    public func operationFrom(_ sessionTask:URLSessionTask) -> SessionTaskOperation? {
        for operation in self.operations {
            if operation.isKind(of: SessionTaskOperation.self) {
                if (operation as! SessionTaskOperation).sessionTask?.taskIdentifier == sessionTask.taskIdentifier {
                    return (operation as! SessionTaskOperation)
                }
            }
        }
        
        return nil
    }
    
    /// 取消所有的sessiontaskOperation
    public func cancelAllSessionTaskOperations() {
        for operation in self.operations {
            if operation.isKind(of: SessionTaskOperation.self) {
                operation.cancel()
            }
        }
    }
}

public extension OperationQueue {
    
    /// 添加一个队列任务的监听
    ///
    /// - Parameters:
    ///   - type: 监听的任务类型
    ///   - callback: 回调的闭包
    func addObserverWith(_ type: OperationQueueObserverType, callback:@escaping ((_ queue: OperationQueue) -> Void)) {
        let model = self.associatedModel.responseModel(with: type)
        model.block = callback
        self.addOperationObserver()
    }
    
    /// 添加一个队列任务的监听
    ///
    /// - Parameters:
    ///   - type: 监听的任务类型
    ///   - target: 回调目标
    ///   - action: 回调方法
    func addObserverWith(_ type:OperationQueueObserverType, _ target:AnyObject, _ action:Selector) {
        let model = self.associatedModel.responseModel(with: type)
        model.target = target
        model.action = action
        self.addOperationObserver()
    }
    
    /// 添加监听的方法
    fileprivate func addOperationObserver() {
        if !self.associatedModel.addedOperationObserver {
            self.addObserver(self, forKeyPath: "operations", options: [.new, .old], context: nil)
            self.associatedModel.addedOperationObserver = true
        }
    }
    
    /// KVO
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "operations" {
            self.callbackWith(type: .Changed)
            if self.operationCount == 0 {
                self.callbackWith(type: .AllCompleted)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

/// 数据缓存model的key
fileprivate let holderAssociatedKey = "OperationQueue._OperationQueueHolder.associatedKey"

/// 队列私有属性方法的扩充类
fileprivate extension OperationQueue {

    func callbackWith(type:OperationQueueObserverType) {
        let responseModel = self.associatedModel.responseModel(with: type)
        if let block = responseModel.block {
            block(self)
        }
        
        if let target = responseModel.target , let action = responseModel.action {
            if target.responds(to: action) {
                let _ = target.perform(action, with: self)
            }
        }
    }
    
    /// 缓存各种扩充属性的model
    var associatedModel:_OperationQueueAssociatedModel {
        get {
            var model = objc_getAssociatedObject(self, holderAssociatedKey)
            if model == nil {
                model = _OperationQueueAssociatedModel()
                objc_setAssociatedObject(self, holderAssociatedKey, model, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return model as! _OperationQueueAssociatedModel
        }
    }
    
    /// 外部使用单利类创建方法
    class Global {
        public static let concurrent = Global.operationCreation(10)
        public static let serial = Global.operationCreation(1)
        
        private class func operationCreation(_ maxConcurrentOperationCount:Int) -> OperationQueue {
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = maxConcurrentOperationCount
            return queue
        }
        
        private init () { }
    }
}

/// 各种回调信息的保存model
fileprivate class _OperationChangeResponseModel {
    /// 回调的对象
    weak var target:AnyObject?
    /// 回调的方法
    var action:Selector?
    /// 回调的闭包
    var block:((_ queue: OperationQueue) -> Void)?
}

/// 队列扩充各种属性的保存类，减少runtime方法的使用
fileprivate class _OperationQueueAssociatedModel {
    /// 是否已经添加了kvo
    var addedOperationObserver:Bool = false
    /// kvo回调对象各种信息的缓存字典
    var operationObserver:[OperationQueueObserverType : _OperationChangeResponseModel] = [:]
    /// 根据监听类型来获取对应的缓存model
    func responseModel(with type:OperationQueueObserverType) -> _OperationChangeResponseModel {
        var model = self.operationObserver[type]
        if model == nil {
            model = _OperationChangeResponseModel()
            operationObserver[type] = model
        }
        return model!
    }
}
