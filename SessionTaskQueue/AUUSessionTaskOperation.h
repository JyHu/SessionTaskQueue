//
//  AUUSessionTaskOperation.h
//  SessionTaskQueue
//
//  Created by 胡金友 on 2018/1/18.
//

#import <UIKit/UIKit.h>

@interface AUUSessionTaskOperation : NSOperation

/**
 根据一个网络请求的task初始化一个operation

 @param dataTask task
 @return operation
 */
+ (instancetype)operationWithTask:(NSURLSessionTask *)dataTask;

/**
 当前operation内对应的task
 */
@property (nonatomic, strong, readonly) NSURLSessionTask *dataTask;

/**
 在当前的网络请求完成(结束)以后，用来结束这条operation，否则这条线程在没有`cancel`的情况下就不会退出，
 导致`operationQueue`里的线程数只会增加不会下降
 */
- (void)completeExecute;

@end
