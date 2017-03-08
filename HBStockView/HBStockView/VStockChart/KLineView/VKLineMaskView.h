//
//  VKLineMaskView.h
//  HBStockView
//
//  Created by Vols on 2017/3/7.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLineModel.h"
#import "VKLinePosition.h"

@interface VKLineMaskView : UIView

//当前长按选中的model
@property (nonatomic, strong) VLineModel        * selectedModel;
@property (nonatomic, assign) VKLinePosition    * selectedPosition;


// 当前的滑动scrollview
@property (nonatomic, strong) UIScrollView *stockScrollView;

@end
