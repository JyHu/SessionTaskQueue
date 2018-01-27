//
//  NSOperation+AUUDependency.h
//  SessionTaskQueue
//
//  Created by 胡金友 on 2018/1/24.
//

#import <Foundation/Foundation.h>

@interface NSOperation (AUUDependency)

- (void)addDependencies:(NSArray <NSOperation *>*)operations;

@end
