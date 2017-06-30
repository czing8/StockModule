//
//  VFullScreenStockView.h
//  HBStockView
//
//  Created by Vols on 2017/3/9.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CloseHandlerBlock)();

@interface VFullScreenStockView : UIView

@property (nonatomic, copy) CloseHandlerBlock closeHandler;

@end
