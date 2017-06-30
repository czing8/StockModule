//
//  VolumeView.h
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//  成交量视图

#import <UIKit/UIKit.h>
#import "VStockGroup.h"

@interface VVTimeVolumeView : UIView

- (void)drawViewWithXPosition:(CGFloat)xPosition stockGroup:(VStockGroup *)stockGroup;

@end
