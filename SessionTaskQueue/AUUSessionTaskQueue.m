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

@interface NSOperationQueue (_Private)
#ifdef DEBUG
/**
 测试参数，用以标志是否是串行的队列
 */
@property (assign, nonatomic) BOOL isSerial;
#endif
@end


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
    queue.isSerial = YES;
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

#ifdef DEBUG

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (keyPath && [keyPath isEqualToString:@"maxConcurrentOperationCount"]) {
        if (self.isSerial) {
            NSAssert(0, @"对于串行队列最好不要自己设置并行线程数，如果想要并行的队列，请选择其他方法。");
        }
    }
}

- (void)setIsSerial:(BOOL)isSerial {
    objc_setAssociatedObject(self, @selector(isSerial), @(isSerial), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isSerial {
    id obj = objc_getAssociatedObject(self, @selector(isSerial));
    return obj ? [obj boolValue] : NO;
}

#endif

@end
