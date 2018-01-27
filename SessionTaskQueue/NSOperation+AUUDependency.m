//
//  NSOperation+AUUDependency.m
//  SessionTaskQueue
//
//  Created by 胡金友 on 2018/1/24.
//

#import "NSOperation+AUUDependency.h"

@implementation NSOperation (AUUDependency)

- (void)addDependencies:(NSArray<NSOperation *> *)operations {
    if (operations && operations.count > 0) {
        for (NSOperation *operation in operations) {
            [self addDependency:operation];
        }
    }
}

@end
