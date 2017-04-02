//
//  VKLineMaskView.m
//  HBStockView
//
//  Created by Vols on 2017/3/7.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VKLineMaskView.h"
#import "VStockConstant.h"
#import "VStockChartConfig.h"
#import "UIColor+StockTheme.h"

@implementation VKLineMaskView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self drawDashLine];
}

// 绘制长按的背景线
- (void)drawDashLine {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat lengths[] = {3,3};
    CGContextSetLineDash(ctx, 0, lengths, 2);
    CGContextSetStrokeColorWithColor(ctx, [UIColor selectedLineColor].CGColor);
    CGContextSetLineWidth(ctx, 1.5);
    
    CGFloat x = self.stockScrollView.frame.origin.x + self.selectedPosition.closePoint.x - self.stockScrollView.contentOffset.x;
    
    //绘制横线
    CGContextMoveToPoint(ctx, self.stockScrollView.frame.origin.x, self.stockScrollView.frame.origin.y + self.selectedPosition.closePoint.y);
    CGContextAddLineToPoint(ctx, self.stockScrollView.frame.origin.x + self.stockScrollView.frame.size.width, self.stockScrollView.frame.origin.y + self.selectedPosition.closePoint.y);
    
    //绘制竖线
    CGContextMoveToPoint(ctx, x, self.stockScrollView.frame.origin.y);
    CGContextAddLineToPoint(ctx, x, self.stockScrollView.frame.origin.y + self.stockScrollView.bounds.size.height - kStockLineDayHeight/2.f);
    CGContextStrokePath(ctx);
    
    //绘制交叉圆点
    CGContextSetStrokeColorWithColor(ctx, [UIColor selectedPointColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor stockMainBgColor].CGColor);
    CGContextSetLineWidth(ctx, 1.5);
    CGContextSetLineDash(ctx, 0, NULL, 0);
    CGContextAddArc(ctx, x, self.stockScrollView.frame.origin.y + self.selectedPosition.closePoint.y, kStockPointRadius, 0, 2 * M_PI, 0);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    //绘制选中日期
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:9],NSForegroundColorAttributeName:[UIColor selectedRectTextColor]};
    NSString *dayText = self.selectedModel.day;
    CGRect textRect = [self rectOfNSString:dayText attribute:attribute];
    
    if (x + textRect.size.width/2.f + 2 > CGRectGetMaxX(self.stockScrollView.frame)) {
        CGContextSetFillColorWithColor(ctx, [UIColor selectedRectTextColor].CGColor);
        CGContextFillRect(ctx, CGRectMake(CGRectGetMaxX(self.stockScrollView.frame) - 4 - textRect.size.width, self.stockScrollView.frame.origin.y + self.stockScrollView.bounds.size.height - kStockLineDayHeight, textRect.size.width + 4, textRect.size.height + 4));
        [dayText drawInRect:CGRectMake(CGRectGetMaxX(self.stockScrollView.frame) - 4 - textRect.size.width + 2, self.stockScrollView.frame.origin.y + self.stockScrollView.bounds.size.height - kStockLineDayHeight + 2, textRect.size.width, textRect.size.height) withAttributes:attribute];
    } else {
        CGContextSetFillColorWithColor(ctx, [UIColor selectedRectBgColor].CGColor);
        CGContextFillRect(ctx, CGRectMake(x-textRect.size.width/2.f, self.stockScrollView.frame.origin.y + self.stockScrollView.bounds.size.height - kStockLineDayHeight, textRect.size.width + 4, textRect.size.height + 4));
        [dayText drawInRect:CGRectMake(x-textRect.size.width/2.f + 2, self.stockScrollView.frame.origin.y + self.stockScrollView.bounds.size.height - kStockLineDayHeight + 2, textRect.size.width, textRect.size.height) withAttributes:attribute];
    }
    
    //绘制选中价格
    NSString *priceText = [NSString stringWithFormat:@"%.2f",self.selectedModel.closePrice];
    CGRect priceRect = [self rectOfNSString:priceText attribute:attribute];
    CGContextSetFillColorWithColor(ctx, [UIColor selectedRectBgColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(kStockScrollViewLeftGap, self.stockScrollView.frame.origin.y + self.selectedPosition.closePoint.y - priceRect.size.height/2.f - 2, priceRect.size.width + 4, priceRect.size.height + 4));
    [priceText drawInRect:CGRectMake(kStockScrollViewLeftGap, self.stockScrollView.frame.origin.y + self.selectedPosition.closePoint.y - priceRect.size.height/2.f, priceRect.size.width, priceRect.size.height) withAttributes:attribute];
}

- (CGRect)rectOfNSString:(NSString *)string attribute:(NSDictionary *)attribute {
    CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, 0)
                                       options:NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading
                                    attributes:attribute
                                       context:nil];
    return rect;
}

@end
