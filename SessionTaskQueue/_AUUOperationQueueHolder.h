//
//  _AUUOperationQueueHolder.h
//  SessionTaskQueue
//
//  Created by 胡金友 on 2018/1/24.
//

#import <Foundation/Foundation.h>

@interface _AUUOperationQueueHolder : NSObject

@end



@interface _AUUOperationChangeResponseModel : NSObject

@property (copy, nonatomic) void (^block)(NSOperationQueue *);
@property (weak, nonatomic) id target;
@property (nonatomic) SEL action;

@end

@interface _AUUOperationQueueAssociatedModel : NSObject

#ifdef DEBUG
/**
 测试参数，用以标志是否是串行的队列
 */
@property (assign, nonatomic) BOOL isSerial;
#endif

/**
 是否已经添加了对于operations的KVC监听
 */
@property (assign, nonatomic) BOOL addedOperationsObserver;

/**
 缓存所有的事件响应
 */
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, _AUUOperationChangeResponseModel *> *operationChangedDict;

/**
 根据监听类型在缓存中找到对应的响应缓存model

 @param type observer类型
 @return _AUUOperationChangeResponseModel
 */
- (_AUUOperationChangeResponseModel *)responseModelWithType:(NSUInteger)type;

@end

@interface NSOperationQueue (_AUUOperationQueueHolder)

/**
 属性扩充的缓存类，减少runtime添加属性的代码
 */
@property (nonatomic, strong) _AUUOperationQueueAssociatedModel *associatedModel;

@end
