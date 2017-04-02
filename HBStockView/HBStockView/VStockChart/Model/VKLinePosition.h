//
//  VKLinePositionModel.h
//  HBStockView
//
//  Created by Vols on 2017/3/6.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface VKLinePosition : NSObject

@property (nonatomic, assign) CGPoint openPoint;    // 开盘点
@property (nonatomic, assign) CGPoint closePoint;   // 收盘点

@property (nonatomic, assign) CGPoint highPoint;    // 最高点
@property (nonatomic, assign) CGPoint lowPoint;     // 最低点

+ (instancetype)modelWith:(CGPoint)openPoint :(CGPoint)closePoint :(CGPoint)highPoint :(CGPoint)lowPoint;

@end
