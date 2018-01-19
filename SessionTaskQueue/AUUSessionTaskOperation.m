//
//  AUUSessionTaskOperation.m
//  SessionTaskQueue
//
//  Created by 胡金友 on 2018/1/18.
//

#import "AUUSessionTaskOperation.h"

static NSString *_NSOperationFinishedKey = @"isFinished";
static NSString *_NSOperationExecutingKey = @"isExecuting";


@interface AUUSessionTaskOperation ()

@property (nonatomic, readwrite) BOOL taskFinished;
@property (nonatomic, readwrite) BOOL taskExecuting;

/**
 这条operation是否进入过队列，并且从队列中开始执行
 
 这个参数是为了处理一种错误情况：
 如果外部在添加一个`task`到`operationQueue`之前就已经`resume`了，或者其对应的`operaion`开没有开始就被
 调用`completeExecute`了，那么在其完成之后调用`completeExecute`的时候会导致线程池处理出错从而出现`crash`。
 */
@property (assign, nonatomic) BOOL hadEnqueue;

@property (nonatomic, strong, readwrite) NSURLSessionTask *dataTask;


@end

@implementation AUUSessionTaskOperation

+ (instancetype)operationWithTask:(NSURLSessionTask *)dataTask {
    AUUSessionTaskOperation *operation = [[self alloc] init];
    operation.dataTask = dataTask;
    return operation;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _taskFinished = NO;
        _taskExecuting = NO;
    }
    return self;
}

- (void)start {
    if ([self isCancelled]) {
        [self willChangeValueForKey:_NSOperationFinishedKey];
        self.taskFinished = YES;
        [self didChangeValueForKey:_NSOperationFinishedKey];
        return;
    }
    
    self.hadEnqueue = YES;
    
    [self willChangeValueForKey:_NSOperationExecutingKey];
    self.taskExecuting = YES;
    [self didChangeValueForKey:_NSOperationExecutingKey];
    
    [self main];
}

- (void)main {
    [self.dataTask resume];
}

- (void)cancel {
    [self.dataTask cancel];
    [super cancel];
}

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
    return self.taskExecuting;
}

- (BOOL)isFinished {
    return self.taskFinished;
}

- (void)completeExecute {
    if (self.hadEnqueue) {
        self.dataTask = nil;
        [self willChangeValueForKey:_NSOperationFinishedKey];
        [self willChangeValueForKey:_NSOperationExecutingKey];
        self.taskExecuting = NO;
        self.taskFinished = YES;
        [self didChangeValueForKey:_NSOperationFinishedKey];
        [self didChangeValueForKey:_NSOperationExecutingKey];
    } else {
        // 取消线程，避免线程池中过度的累积
        [self cancel];
    }
}

@end

