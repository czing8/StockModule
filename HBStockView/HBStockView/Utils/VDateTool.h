//
//  VDateTool.h
//  HBUIs
//
//  Created by Vols on 2017/2/13.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDateTool : NSObject

/*
 *  周日是1，周一是2 ……
 */
+ (NSInteger)getNowWeekday;

+ (BOOL)isBetweenFromHour:(NSInteger)fromHour :(NSInteger)fromMinute toHour:(NSInteger)toHour :(NSInteger)toMinute;

@end
