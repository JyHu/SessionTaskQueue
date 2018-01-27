//
//  ViewController.m
//  QueueDemo
//
//  Created by 胡金友 on 2018/1/18.
//

#import "ViewController.h"
#import "SessionTaskQueue.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (IBAction)testConcurrent:(id)sender {
    [self testForQueue:[NSOperationQueue globalConcurrentQueue]];
}

- (IBAction)testSerial:(id)sender {
    [self testForQueue:[NSOperationQueue globalSerialQueue]];
}

- (IBAction)partTempSerial:(id)sender {
    [self testForQueue:[NSOperationQueue serialQueue]];
}

- (IBAction)testDependency:(UIButton *)sender {
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 10;
    
    [queue addObserverWithType:AUUOperationQueueObserverTypeOperationChanged observerBlock:^(NSOperationQueue *queue) {
        NSLog(@"operachanged : %@", @(queue.operationCount));
    }];
    
    [queue addObserverWithType:AUUOperationQueueObserverTypeAllCompleted observerBlock:^(NSOperationQueue *queue) {
        NSLog(@"all finished");
        NSLog(@"\n\n==============================================\n");
    }];
    
    NSOperation *op0 = [self operationWithQueue:queue index:0 dependencies:nil];
    NSOperation *op1 = [self operationWithQueue:queue index:1 dependencies:@[op0]];
    NSOperation *op2 = [self operationWithQueue:queue index:2 dependencies:@[op0]];
    NSOperation *op3 = [self operationWithQueue:queue index:3 dependencies:@[op0]];
    NSOperation *op4 = [self operationWithQueue:queue index:4 dependencies:@[op0]];
    NSOperation *op5 = [self operationWithQueue:queue index:5 dependencies:@[op1, op2, op3]];
    NSOperation *op6 = [self operationWithQueue:queue index:6 dependencies:@[op5, op4]];
    NSOperation *op7 = [self operationWithQueue:queue index:7 dependencies:@[op6]];
    NSOperation *op8 = [self operationWithQueue:queue index:8 dependencies:@[op7]];
    NSOperation *op9 = [self operationWithQueue:queue index:9 dependencies:@[op8]];
    NSOperation *op10 = [self operationWithQueue:queue index:10 dependencies:@[op9]];
    NSOperation *op11 = [self operationWithQueue:queue index:11 dependencies:@[op9]];
    NSOperation *op12 = [self operationWithQueue:queue index:12 dependencies:@[op10, op11]];
    NSOperation *op13 = [self operationWithQueue:queue index:13 dependencies:@[op12]];
    NSOperation *op14 = [self operationWithQueue:queue index:14 dependencies:@[op13]];
}

- (void)testForQueue:(NSOperationQueue *)queue {
    for (NSInteger i = 0; i < 50; i ++) {
        [self operationWithQueue:queue index:i dependencies:nil];
    }
}

- (NSOperation *)operationWithQueue:(NSOperationQueue *)queue index:(NSInteger)ind dependencies:(NSArray <NSOperation *>*)dependencies {
    NSOperation *operation = nil;
    if (0) {
        NSString *u1 = @"http://f.hiphotos.baidu.com/image/pic/item/503d269759ee3d6db032f61b48166d224e4ade6e.jpg";
        NSString *u2 = @"https://github.com/casatwy/RTNetworking/archive/master.zip";
        NSURL *url = [NSURL URLWithString:arc4random_uniform(2) ?  u1: u2];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        __block NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [queue completeOperationWithSessionTask:task];
            
            NSLog(@"task identifier : %@/%@  ->  %@", @(ind), @(queue.operationCount), task.currentRequest.URL.absoluteString);
            
            if (queue.operationCount == 0) {
                NSLog(@"\n\n==============================================\n");
            }
        }];
        operation = [AUUSessionTaskOperation operationWithTask:task];
    } else {
        operation = [AUUAsyncBlockOperation operationWithAsyncTask:^(BOOL *finished) {
            NSTimeInterval t = (arc4random_uniform(30) + 5) / 20.0;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(t * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"%@/%@  -> %@", @(ind), @([queue operationCount]), @(t));
                *finished = YES;
            });
        }];
    }
    
    [operation addDependencies:dependencies];
    [queue addOperation:operation];
    
    return operation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
