//
//  VTimeLineMaskView.h
//  HBStockView
//
//  Created by Vols on 2017/3/2.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTimeLineModel.h"

@interface VTimeLineMaskView : UIView

//当前长按选中的model
@property (nonatomic, strong) VTimeLineModel    * selectedModel;
@property (nonatomic, assign) CGPoint           selectedPoint;

// 当前的滑动scrollview
@property (nonatomic, strong) UIScrollView *stockScrollView;

@end
