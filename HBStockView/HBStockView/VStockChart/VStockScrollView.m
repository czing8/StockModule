//
//  VStockScrollView.m
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VStockScrollView.h"

#import "UIColor+StockTheme.h"
#import "Masonry.h"

@implementation VStockScrollView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    if (self.isShowBgLine) {
        [self drawBgLinesOnContenx:context];
    }
    
}

- (void)drawBgLinesOnContenx:(CGContextRef)context {
    if (self.stockType == VStockChartTypeTimeLine) {
        
    }
    // k线图，包括 日K、周K、月k
    else  {
        //单纯的画了一下背景线
        CGContextSetStrokeColorWithColor(context, [UIColor VStock_bgLineColor].CGColor);
        CGContextSetLineWidth(context, 0.5);
        CGFloat unitHeight = (self.frame.size.height*[VStockChartConfig lineChartRadio])/4;
        
//        const CGPoint line1[] = {CGPointMake(0, 1),CGPointMake(self.contentSize.width, 1)};
        const CGPoint line2[] = {CGPointMake(0, unitHeight),CGPointMake(self.contentSize.width, unitHeight)};
        const CGPoint line3[] = {CGPointMake(0, unitHeight*2),CGPointMake(self.contentSize.width, unitHeight*2)};
        const CGPoint line4[] = {CGPointMake(0, unitHeight*3),CGPointMake(self.contentSize.width, unitHeight*3)};
//        const CGPoint line5[] = {CGPointMake(0, unitHeight*4),CGPointMake(self.contentSize.width, unitHeight*4)};
//        const CGPoint line6[] = {CGPointMake(0, self.frame.size.height * (1 - [VStockChartConfig volumeViewRadio]) ),CGPointMake(self.contentSize.width, self.frame.size.height * (1 - [VStockChartConfig volumeViewRadio]))};
        
//        CGContextStrokeLineSegments(context, line1, 2);
        CGContextStrokeLineSegments(context, line2, 2);
        CGContextStrokeLineSegments(context, line3, 2);
        CGContextStrokeLineSegments(context, line4, 2);
//        CGContextStrokeLineSegments(context, line5, 2);
//        CGContextStrokeLineSegments(context, line6, 2);
        
        CGContextSetStrokeColorWithColor(context, [UIColor borderLineColor].CGColor);
//        CGContextSetAllowsAntialiasing(context, NO);
        
        CGRect rectangle = self.bounds;
        rectangle.size.height =  (int)(rectangle.size.height*[VStockChartConfig lineChartRadio]);
        NSLog(@"rectangle:%@", NSStringFromCGRect(rectangle));
        CGContextAddRect(context, rectangle);
        CGContextStrokePath(context);
    }
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [UIView new];
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _contentView;
}

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self);
        make.width.equalTo(@(contentSize.width));
        make.height.equalTo(self);
    }];
}

@end
