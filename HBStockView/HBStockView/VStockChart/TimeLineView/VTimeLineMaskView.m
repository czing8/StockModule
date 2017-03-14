//
//  VTimeLineMaskView.m
//  HBStockView
//
//  Created by Vols on 2017/3/2.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VTimeLineMaskView.h"
#import "VStockConstant.h"
#import "VStockChartConfig.h"
#import "UIColor+StockTheme.h"

@implementation VTimeLineMaskView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self drawDashLine];
}

/**
 绘制长按的背景线
 */
- (void)drawDashLine {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat lengths[] = {3,3};
    CGContextSetLineDash(context, 0, lengths, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor selectedLineColor].CGColor);
    CGContextSetLineWidth(context, 1.5);
    
    CGFloat x = self.stockScrollView.frame.origin.x + self.selectedPoint.x - self.stockScrollView.contentOffset.x;
    
    //绘制横线
    CGContextMoveToPoint(context, self.stockScrollView.frame.origin.x, self.stockScrollView.frame.origin.y + self.selectedPoint.y);
    CGContextAddLineToPoint(context, self.stockScrollView.frame.origin.x + self.stockScrollView.frame.size.width, self.stockScrollView.frame.origin.y + self.selectedPoint.y);
    
    //绘制竖线
    CGContextMoveToPoint(context, x, self.stockScrollView.frame.origin.y);
    CGContextAddLineToPoint(context, x, self.stockScrollView.frame.origin.y + self.stockScrollView.bounds.size.height - kStockLineDayHeight/2.f);
    CGContextStrokePath(context);
    
    //绘制交叉圆点
    CGContextSetStrokeColorWithColor(context, [UIColor selectedPointColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor stockMainBgColor].CGColor);
    CGContextSetLineWidth(context, 1.5);
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextAddArc(context, x, self.stockScrollView.frame.origin.y + self.selectedPoint.y, kStockPointRadius, 0, 2 * M_PI, 0);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    //绘制选中日期
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:9],NSForegroundColorAttributeName:[UIColor selectedRectTextColor]};
    NSString *dayText = [NSString stringWithFormat:@"%f", self.selectedModel.volume];
    CGRect textRect = [self rectOfNSString:dayText attribute:attribute];
    
    if (x + textRect.size.width/2.f + 2 > CGRectGetMaxX(self.stockScrollView.frame)) {
        CGContextSetFillColorWithColor(context, [UIColor selectedRectBgColor].CGColor);
        CGContextFillRect(context, CGRectMake(CGRectGetMaxX(self.stockScrollView.frame) - 4 - textRect.size.width, self.stockScrollView.frame.origin.y + self.stockScrollView.bounds.size.height - kStockLineDayHeight, textRect.size.width + 4, textRect.size.height + 4));
        [dayText drawInRect:CGRectMake(CGRectGetMaxX(self.stockScrollView.frame) - 4 - textRect.size.width + 2, self.stockScrollView.frame.origin.y + self.stockScrollView.bounds.size.height - kStockLineDayHeight + 2, textRect.size.width, textRect.size.height) withAttributes:attribute];
    } else {
        CGContextSetFillColorWithColor(context, [UIColor selectedRectBgColor].CGColor);
        CGContextFillRect(context, CGRectMake(x-textRect.size.width/2.f, self.stockScrollView.frame.origin.y + self.stockScrollView.bounds.size.height - kStockLineDayHeight, textRect.size.width + 4, textRect.size.height + 4));
        [dayText drawInRect:CGRectMake(x-textRect.size.width/2.f + 2, self.stockScrollView.frame.origin.y + self.stockScrollView.bounds.size.height - kStockLineDayHeight + 2, textRect.size.width, textRect.size.height) withAttributes:attribute];
    }
    
    // 绘制选中价格
    NSString *priceText = [NSString stringWithFormat:@"%.2f",[self.selectedModel.price floatValue]];
    CGRect priceRect = [self rectOfNSString:priceText attribute:attribute];
    CGContextSetFillColorWithColor(context, [UIColor selectedRectBgColor].CGColor);
    CGContextFillRect(context, CGRectMake(VStockScrollViewLeftGap - priceRect.size.width - 4, self.stockScrollView.frame.origin.y + self.selectedPoint.y - priceRect.size.height/2.f - 2, priceRect.size.width + 4, priceRect.size.height + 4));
    [priceText drawInRect:CGRectMake(VStockScrollViewLeftGap - priceRect.size.width - 4 + 2, self.stockScrollView.frame.origin.y + self.selectedPoint.y - priceRect.size.height/2.f, priceRect.size.width, priceRect.size.height) withAttributes:attribute];
    
    //绘制选中增幅
    NSString *text2 = [NSString stringWithFormat:@"%.2f%%",([self.selectedModel.price floatValue] - self.selectedModel.preClosePrice)*100/self.selectedModel.preClosePrice];
    CGSize textSize2 = [self rectOfNSString:text2 attribute:attribute].size;
    CGContextSetFillColorWithColor(context, [UIColor selectedRectBgColor].CGColor);
    CGContextFillRect(context, CGRectMake(CGRectGetMaxX(self.stockScrollView.frame) - textSize2.width - 4, self.stockScrollView.frame.origin.y + self.selectedPoint.y - priceRect.size.height/2.f - 2, textSize2.width + 4, textSize2.height + 4));
    
    CGPoint rightDrawPoint = CGPointMake(CGRectGetMaxX(self.stockScrollView.frame) - textSize2.width - 2 , self.stockScrollView.frame.origin.y + self.selectedPoint.y - priceRect.size.height/2.f);
    [text2 drawAtPoint:rightDrawPoint withAttributes:attribute];
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
