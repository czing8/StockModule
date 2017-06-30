//
//  VRefreshBtn.h
//  PopupViewExample
//
//  Created by Vols on 2017/6/23.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VRefreshBtn : UIView

@property (nonatomic, copy) void(^clickHandler)();

@end
