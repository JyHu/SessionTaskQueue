//
//  _AUUOperationQueueHolder.m
//  SessionTaskQueue
//
//  Created by 胡金友 on 2018/1/24.
//

#import "_AUUOperationQueueHolder.h"
#import "AUUSessionTaskQueue.h"
#import <objc/runtime.h>

@implementation _AUUOperationQueueHolder

@end


@implementation _AUUOperationChangeResponseModel
@end


@implementation _AUUOperationQueueAssociatedModel

- (_AUUOperationChangeResponseModel *)responseModelWithType:(NSUInteger)type {
    _AUUOperationChangeResponseModel *model = [self.operationChangedDict objectForKey:@(type)];
    if (!model) {
        model = [[_AUUOperationChangeResponseModel alloc] init];
        [self.operationChangedDict setObject:model forKey:@(type)];
    }
    return model;
}

- (NSMutableDictionary<NSNumber *,_AUUOperationChangeResponseModel *> *)operationChangedDict {
    if (!_operationChangedDict) {
        _operationChangedDict = [[NSMutableDictionary alloc] init];
    }
    return _operationChangedDict;
}

@end


@implementation NSOperationQueue (_AUUOperationQueueHolder)

- (_AUUOperationQueueAssociatedModel *)associatedModel {
    _AUUOperationQueueAssociatedModel *associatedModel = objc_getAssociatedObject(self, @selector(associatedModel));
    if (!associatedModel) {
        associatedModel = [[_AUUOperationQueueAssociatedModel alloc] init];
        [self setAssociatedModel:associatedModel];
    }
    return associatedModel;
}

- (void)setAssociatedModel:(_AUUOperationQueueAssociatedModel *)associatedModel {
    objc_setAssociatedObject(self, @selector(associatedModel), associatedModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
