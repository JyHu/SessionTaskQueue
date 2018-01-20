//
//  AUUAsyncBlockOperation.h
//  SessionTaskQueue
//
//  Created by 胡金友 on 2018/1/20.
//

#import <Foundation/Foundation.h>

/**
 包含有异步执行任务的block

 @param finished 结束这个任务所在的operation
 */
typedef void (^AUUAsyncOperationTask) (BOOL *finished);

@interface AUUAsyncBlockOperation : NSOperation

/**
 根据一个包含异步任务的block来创建一个operation

 @param asyncTask 包含异步任务的block
 @return self
 */
+ (instancetype)operationWithAsyncTask:(AUUAsyncOperationTask)asyncTask;

/**
 包含异步任务的block
 */
@property (copy, nonatomic, readonly) AUUAsyncOperationTask asyncTask;

@end
