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

- (void)testForQueue:(NSOperationQueue *)queue {
    for (NSInteger i = 0; i < 50; i ++) {
        NSString *u1 = @"http://f.hiphotos.baidu.com/image/pic/item/503d269759ee3d6db032f61b48166d224e4ade6e.jpg";
        NSString *u2 = @"https://github.com/casatwy/RTNetworking/archive/master.zip";
        NSURL *url = [NSURL URLWithString:arc4random_uniform(2) ?  u1: u2];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        __block NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [queue completeOperationWithSessionTask:task];
            
            NSLog(@"task identifier : %@/%@  ->  %@", @(task.taskIdentifier), @(queue.operationCount), task.currentRequest.URL.absoluteString);
            
            if (queue.operationCount == 0) {
                NSLog(@"\n\n==============================================\n");
            }
        }];
        
        // 测试提前complete出现的问题
        if (arc4random_uniform(20) == 4) {
            [task resume];
        }
        [queue addSessionTask:task];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
