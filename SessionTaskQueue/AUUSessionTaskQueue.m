//
//  AUUSessionTaskQueue.m
//  SessionTaskQueue
//
//  Created by 胡金友 on 2018/1/18.
//

#import "AUUSessionTaskQueue.h"
#import "AUUSessionTaskOperation.h"
#import <objc/runtime.h>
#import "AUUAsyncBlockOperation.h"
#import "_AUUOperationQueueHolder.h"

@implementation NSOperationQueue (AUUSessionTaskOperation)

+ (instancetype)globalConcurrentQueue {
    static NSOperationQueue *concurrentQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        concurrentQueue = [self queueWithMaxConcurrentOperationCount:10];
    });
    return concurrentQueue;
}

+ (instancetype)globalSerialQueue {
    static NSOperationQueue *serialQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serialQueue = [self serialQueue];
    });
    return serialQueue;
}

+ (instancetype)serialQueue {
    NSOperationQueue *queue = [self queueWithMaxConcurrentOperationCount:1];
#ifdef DEBUG
    queue.associatedModel.isSerial = YES;
#endif
    return queue;
}

+ (instancetype)queueWithMaxConcurrentOperationCount:(NSUInteger)maxConcurrentOperationCount {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:maxConcurrentOperationCount];
#ifdef DEBUG
    [queue addObserver:queue forKeyPath:@"maxConcurrentOperationCount" options:NSKeyValueObservingOptionNew context:nil];
#endif
    return queue;
}

- (void)addSessionTask:(NSURLSessionTask *)sessionTask {
    [self addOperation:[AUUSessionTaskOperation operationWithTask:sessionTask]];
}

- (void)addAsyncOperationWithBlock:(void (^)(BOOL *))asyncBlock {
    [self addOperation:[AUUAsyncBlockOperation operationWithAsyncTask:asyncBlock]];
}

- (void)completeOperationWithSessionTask:(NSURLSessionTask *)sessionTask {
    [self completeOperation:[self operationForSessionTask:sessionTask]];
}

- (void)completeOperation:(AUUSessionTaskOperation *)operation {
    [operation completeExecute];
}

- (AUUSessionTaskOperation *)operationForSessionTask:(NSURLSessionTask *)sessionTask {
    for (AUUSessionTaskOperation *operation in self.operations) {
        if ([operation isKindOfClass:[AUUSessionTaskOperation class]]) {
            if (operation.dataTask.taskIdentifier == sessionTask.taskIdentifier) {
                return operation;
            }
        }
    }
    
    return nil;
}

- (void)cancelAllSessionTaskOperations {
    for (AUUSessionTaskOperation *operation in self.operations) {
        if ([operation isKindOfClass:[AUUSessionTaskOperation class]]) {
            [operation cancel];
        }
    }
}

- (void)addObserverWithType:(AUUOperationQueueObserverType)type observerBlock:(void (^)(NSOperationQueue *))observerBlock {
    _AUUOperationChangeResponseModel *responseModel = [self.associatedModel responseModelWithType:type];
    responseModel.block = [observerBlock copy];
    
    [self addOperationsObserver];
}

- (void)addObserverWithType:(AUUOperationQueueObserverType)type observerTarget:(id)target action:(SEL)action {
    _AUUOperationChangeResponseModel *responseModel = [self.associatedModel responseModelWithType:type];
    responseModel.target = target;
    responseModel.action = action;
    
    [self addOperationsObserver];
}

- (void)addOperationsObserver {
    if (!self.associatedModel.addedOperationsObserver) {
        [self addObserver:self forKeyPath:@"operations" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        self.associatedModel.addedOperationsObserver = YES;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
#ifdef DEBUG
    if (keyPath && [keyPath isEqualToString:@"maxConcurrentOperationCount"]) {
        if (self.associatedModel.isSerial) {
            NSAssert(0, @"对于串行队列最好不要自己设置并行线程数，如果想要并行的队列，请选择其他方法。");
        }
    } else
#endif
        if ([keyPath isEqualToString:@"operations"]) {
            //            NSLog(@"change:%@ \n operations:%@ \ncount:%@", change, self.operations, @(self.operationCount));
            //            NSLog(@"-----------------------------");
            
            [self callbackWithObserverType:AUUOperationQueueObserverTypeOperationChanged];
            
            if (self.operationCount == 0) {
                [self callbackWithObserverType:AUUOperationQueueObserverTypeAllCompleted];
            }
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    
}

- (void)callbackWithObserverType:(AUUOperationQueueObserverType)type {
    _AUUOperationChangeResponseModel *responseModel = [self.associatedModel responseModelWithType:type];
    
    if (responseModel.block) {
        responseModel.block(self);
    }
    
    if (responseModel.target && responseModel.action && [responseModel.target respondsToSelector:responseModel.action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [responseModel.target performSelector:responseModel.action withObject:self];
#pragma clang diagnostic pop
    }
}
@end
