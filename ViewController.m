//
//  ViewController.m
//  GCDTimer
//
//  Created by shuanghui xu on 2017/11/13.
//  Copyright © 2017年 shuanghui xu. All rights reserved.
//

#import "ViewController.h"
#import "MD_GCDTimerManager.h"

@interface ViewController ()
@property (nonatomic, strong) MD_GCDTimerManager *timerManager;
@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@end

static NSString * const myTimer = @"MyTimer";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* 启动一个timer，每隔2秒执行一次。每次执行打印一条log记录，在执行到n==10的时候cancel掉timer。 */
    //    [self demoNSTimer];//branch
    [self demoGCDTimer];
    
    /*
     *  苹果的开发人员应该发现了NSTimer比较严重的循环引用缺陷，所以在iOS10上提供了使用block的NSTimer接口：
     *  + (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
     *                                      repeats:(BOOL)repeats
     *                                        block:(void (^)(NSTimer *timer))block;
     */

    //    [self demoNSTimerAfteriOS10]; //123
}

- (void)demoNSTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                  target:self
                                                selector:@selector(doSomething)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)demoGCDTimer {
    __weak typeof(self) weakSelf = self;
    [[MD_GCDTimerManager sharedInstance] scheduledDispatchTimerWithName:myTimer
                                                           timeInterval:1.0
                                                                  queue:nil
                                                                repeats:YES
                                                           actionOption:AbandonPreviousAction
                                                                 action:^{
                                                                     [weakSelf doSomething];
                                                                 }];
}

- (void)demoNSTimerAfteriOS10 {
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                 repeats:YES
                                                   block:^(NSTimer * _Nonnull timer) {
                                                       [weakSelf doSomething];
                                                   }];
}

/* timer每次执行打印一条log记录，在执行到n==10的时候cancel掉timer */
- (void)doSomething {
    static NSUInteger n = 0;
    NSLog(@"myTimer runs %lu times!", (unsigned long)n++);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.numberLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)n++];
    });
    
//    if (n >= 10) {
//        [self.timer invalidate];
//        [[MD_GCDTimerManager sharedInstance] cancelTimerWithName:myTimer];
//    }
}


@end
