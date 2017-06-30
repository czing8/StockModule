//
//  VScrollMenuView.h
//  StockChart
//
//  Created by Vols on 2017/3/3.
//  Copyright © 2017年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, VScrollMenuLayoutStyle) {
    VScrollMenuLayoutStyleInScreen = 1,
    VScrollMenuLayoutStyleOutScreen
};



@class VScrollMenuView;

@protocol VScrollMenuViewDelegate <NSObject>

@required
- (void)scrollMenu:(VScrollMenuView *)scrollMenu didSelectedIndex:(NSInteger)index;

@end


@interface VScrollMenuView : UIView


@property (nonatomic, weak) id <VScrollMenuViewDelegate> delegate;

@property (nonatomic, strong) UIColor   * bgColor;
@property (nonatomic, strong) UIColor   * lineSelectedColor;
@property (nonatomic, strong) UIColor   * textNormalColor;
@property (nonatomic, strong) UIColor   * textSelectedColor;
@property (nonatomic, strong) UIFont    * titleFont;





/**
 @param titleItems  传入标题数组
 @param style       是否限制所有的按钮都在一屏内
 */
- (instancetype)initWithTitles:(NSArray <NSString *>*)titleItems layoutStyle: (VScrollMenuLayoutStyle)style;


/**
 选中按钮
 @param index 按钮index = 0,1,...
 */
- (void)selectIndex:(NSInteger)index;

@end
