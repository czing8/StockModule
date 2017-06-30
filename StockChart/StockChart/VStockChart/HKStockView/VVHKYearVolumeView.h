//
//  VLineVolumeView.h
//  HBStockView
//
//  Created by Vols on 2017/3/29.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VStockGroup.h"

@interface VVHKYearVolumeView : UIView

- (void)drawViewWithXPosition:(CGFloat)xPosition stockGroup:(VStockGroup *)stockGroup;

@end
