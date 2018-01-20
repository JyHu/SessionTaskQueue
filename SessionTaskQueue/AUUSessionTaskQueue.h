//
//  AUUSessionTaskQueue.h
//  SessionTaskQueue
//
//  Created by 胡金友 on 2018/1/18.
//

#import <Foundation/Foundation.h>

@class AUUSessionTaskOperation;

@interface NSOperationQueue (AUUSessionTaskOperation)

/**
 初始化一个全局的并行队列，这里默认的最大并行线程数为10，可以自己设置

 @return self
 */
+ (instancetype)globalConcurrentQueue;

/**
 初始化一个全局的模拟串行队列，最大并行线程数为1，不建议自己设置
 
 "模拟" 是因为对于NSOperationQueue来说可以设置其`maxConcurrentOperationCount`参数来设置其最大的并行线程数，
 这里为了达到串行的目的，默认的设置了最大并行线程数为1，而且在`Configuration`为`Debug`的时候设置了线程数设置的监听，
 当有外部设置了这个参数的时候，会用crash来提示使用者这里的并行线程数不可修改，但是当在`Release`的时候这个监听将不会存在

 @return self
 */
+ (instancetype)globalSerialQueue;

/**
 初始化一个模拟串行队列，最大并行线程数为1，不建议自己设置

 @return self
 */
+ (instancetype)serialQueue;

/**
 添加一个带有异步操作的block，
 原生的`addOperationWithBlock`只能添加block里的同步任务

 @param asyncBlock 需要包含异步操作的block
 */
- (void)addAsyncOperationWithBlock:(void (^)(BOOL *finished))asyncBlock;

/**
 添加一个task到当前的队列中，自动的为其生成一条operation

 @param sessionTask task
 */
- (void)addSessionTask:(NSURLSessionTask *)sessionTask;

/**
 在网络请求完成(结束)以后，需要结束这条operation

 @param operation operation
 */
- (void)completeOperation:(AUUSessionTaskOperation *)operation;

/**
 在网络请求完成(结束)以后，需要结束这条task对应的operation

 @param sessionTask task
 */
- (void)completeOperationWithSessionTask:(NSURLSessionTask *)sessionTask;

/**
 根据一个网络请求的task在当前队列里找到对应的operation

 @param sessionTask task
 @return operation
 */
- (AUUSessionTaskOperation *)operationForSessionTask:(NSURLSessionTask *)sessionTask;

/**
 取消所有的网络请求
 */
- (void)cancelAllSessionTaskOperations;

@end

