//
//  VDateTool.m
//  HBUIs
//
//  Created by Vols on 2017/2/13.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VDateTool.h"

@implementation VDateTool

+ (NSDateComponents *)getCalendar {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDate *now = [NSDate date];
    // 话说在真机上需要设置区域，才能正确获取本地日期，天朝代码:zh_CN
    calendar.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    dateComponents = [calendar components:unitFlags fromDate:now];
    
    return dateComponents;
}

// 获取当前是星期几
+ (NSInteger)getNowWeekday {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDate *now = [NSDate date];
    // 话说在真机上需要设置区域，才能正确获取本地日期，天朝代码:zh_CN
    calendar.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    comps = [calendar components:unitFlags fromDate:now];
    return [comps weekday];
}


+ (BOOL)isBetweenFromHour:(NSInteger)fromHour :(NSInteger)fromMinute toHour:(NSInteger)toHour :(NSInteger)toMinute {
    NSDate *fromDate = [self getCustomDateWithHour:fromHour minute:fromMinute];
    NSDate *toDate = [self getCustomDateWithHour:toHour minute:toMinute];
    NSDate *currentDate = [NSDate date];
    if ([currentDate compare:fromDate] == NSOrderedDescending && [currentDate compare:toDate] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}

+ (NSDate *)getCustomDateWithHour:(NSInteger)hour minute:(NSInteger)minute {

    NSDate *currentDate = [NSDate date];
    NSCalendar*currentCalendar=[[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *currentComps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    NSLog(@"-----------weekday is %zd",[currentComps weekday]); //在这里需要注意的是：星期日是数字1，星期一时数字2，以此类推。。。
    
    NSDateComponents*resultComps=[[NSDateComponents alloc]init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];
    [resultComps setMinute:minute];

    NSCalendar*resultCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    return [resultCalendar dateFromComponents:resultComps];
}


/**
 * 判断当前时间是否处于某个时间段内
 *
 * @param startTime 开始时间
 * @param expireTime 结束时间
 */
- (BOOL)validateWithStartTime:(NSString *)startTime withExpireTime:(NSString *)expireTime {
    
    NSDate *today = [NSDate date];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    // 时间格式,此处遇到过坑,建议时间HH大写,手机24小时进制和12小时禁止都可以完美格式化
    [dateFormat setDateFormat:@"HH:mm"];
    
    NSDate *start = [dateFormat dateFromString:startTime];
    NSDate *expire = [dateFormat dateFromString:expireTime];
    
    if ([today compare:start] == NSOrderedDescending && [today compare:expire] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}

@end
