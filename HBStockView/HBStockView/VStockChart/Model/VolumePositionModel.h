//
//  VolumePositionModel.h
//  HBStockView
//
//  Created by Vols on 2017/2/28.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface VolumePositionModel : NSObject

@property (nonatomic, assign) CGPoint startPoint;       // 开始点

@property (nonatomic, assign) CGPoint endPoint;         // 结束点

@property (nonatomic, copy  ) NSString * dayDesc;       // 日期

+ (instancetype)modelWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint dayDesc:(NSString *)dayDesc;

@end
