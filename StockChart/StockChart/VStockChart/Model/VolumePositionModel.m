//
//  VolumePositionModel.m
//  StockChart
//
//  Created by Vols on 2017/2/28.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VolumePositionModel.h"

@implementation VolumePositionModel

+ (instancetype)modelWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint dayDesc:(NSString *)dayDesc {
    VolumePositionModel *volumePositionModel = [VolumePositionModel new];
    volumePositionModel.startPoint = startPoint;
    volumePositionModel.endPoint = endPoint;
    volumePositionModel.dayDesc = dayDesc;
    return volumePositionModel;
}

@end
