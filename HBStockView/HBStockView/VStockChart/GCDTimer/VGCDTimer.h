//
//  VGCDTimer.h
//  GCDTimer
//
//  Created by Vols on 2015/11/28.
//  Copyright © 2015年 vols. All rights reserved.
//

/*******************************************
 NSTimer 会强引用 target，而RunLoop会强持有NSTimer，So 只有把NSTimer invalidate后，才能释放timer的target，在delloc中调用invalidate 永远不会执行，驳论，很容易出现内存泄漏。 而如果放在viewWillDisappear里，某些场景又不合适，来回创建timer。
 
 NSTimer受runloop的影响，由于runloop需要处理很多任务，导致NSTimer的精度降低，在日常开发中，如果我们需要对定时器的精度要求很高的话，可以考虑dispatch_source_t去实现。dispatch_source_t精度很高，系统自动触发，系统级别的源。
 
 使用 GCD Timer 的好处在于不依赖 runloop，因此任何线程都可以使用。

 *******************************************/

#import <Foundation/Foundation.h>

@interface VGCDTimer : NSObject

/*
 *  timer将被放入的队列，也就是最终action执行的队列。
 */
- (instancetype) initWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats queue:(dispatch_queue_t)queue block:(dispatch_block_t)block;
+ (instancetype) scheduledTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats queue:(dispatch_queue_t)queue block:(dispatch_block_t)block;


/*
 *  启动一个timer，默认在主线程中运行。
 */
- (instancetype) initWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(dispatch_block_t)block;
+ (instancetype) scheduledTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(dispatch_block_t)block;

- (void)setTimeInterval:(NSTimeInterval)interval;

- (void)invalidate;

@end
