//
//  VGCDTimer.m
//  GCDTimer
//
//  Created by Vols on 2015/11/28.
//  Copyright © 2015年 vols. All rights reserved.
//

#import "VGCDTimer.h"

@implementation VGCDTimer{
    dispatch_source_t   _dispatch_timer;
}


- (instancetype) initWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats queue:(dispatch_queue_t)queue block:(dispatch_block_t)block {

    NSAssert(queue != NULL, @"queue can't be NULL");
    
    if ((self = [super init])) {
        _dispatch_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        
        dispatch_source_set_timer(_dispatch_timer,
                                  dispatch_time(DISPATCH_TIME_NOW, 0),
                                  interval * NSEC_PER_SEC,
                                  0);
        
        dispatch_source_set_event_handler(_dispatch_timer, ^{
            
            if (block) {
                block();
            }
            if (!repeats) {
                dispatch_source_cancel(_dispatch_timer);
            }
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), queue, ^{
            dispatch_resume(_dispatch_timer);
        });
    }
    return self;
}


- (instancetype)initWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(dispatch_block_t)block {
    return self = [self initWithTimeInterval:seconds repeats:repeats queue:dispatch_get_main_queue() block:block];
}


+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats queue:(dispatch_queue_t)queue block:(dispatch_block_t)block
{
    return [[VGCDTimer alloc] initWithTimeInterval:interval repeats:repeats queue:queue block:block];
}

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(dispatch_block_t)block
{
    return [self scheduledTimerWithTimeInterval:interval repeats:repeats queue:dispatch_get_main_queue() block:block];
}


- (void)invalidate {
    dispatch_source_cancel(_dispatch_timer);
}

- (void)dealloc {
    dispatch_source_cancel(_dispatch_timer);
}


@end
