//
//  AUUAsyncBlockOperation.m
//  SessionTaskQueue
//
//  Created by 胡金友 on 2018/1/20.
//

#import "AUUAsyncBlockOperation.h"

@interface AUUAsyncBlockOperation()

@property (copy, nonatomic, readwrite) AUUAsyncOperationTask asyncTask;

@end

@implementation AUUAsyncBlockOperation

+ (instancetype)operationWithAsyncTask:(AUUAsyncOperationTask)asyncTask {
    AUUAsyncBlockOperation *operation = [[self alloc] init];
    operation.asyncTask = [asyncTask copy];
    return operation;
}

- (void)cancel {
    self.asyncTask = nil;
    [super cancel];
}

- (void)main {
    BOOL finished = NO;
    self.asyncTask(&finished);
    
    while (!finished) {
        [[NSRunLoop currentRunLoop] runMode:NSRunLoopCommonModes beforeDate:[NSDate distantFuture]];
    }
}

@end
