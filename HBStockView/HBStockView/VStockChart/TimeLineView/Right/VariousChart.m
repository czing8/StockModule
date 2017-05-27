//
//  VariouChart.m
//  BZChart
//
//  Created by Vols on 2015/4/11.
//  Copyright © 2015年 vols. All rights reserved.
//

#import "VariousChart.h"

#define kRandomColor  kRGB(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

#define kMargin     20

@implementation VariousChart

- (void)drawPieChart:(NSArray *)keys values:(NSArray *)values {
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self setNeedsDisplay];
    [self layoutIfNeeded];

    CGPoint yPoint = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat startAngle = 0;
    CGFloat endAngle;
    float r = self.bounds.size.width/2;
    
    //求和
    float sum=0;
    for (NSString *str in values) {
        sum += [str floatValue];
    }
    
    NSArray<UIColor *> * colors = @[kRGB(228, 62, 62), kRGB(55, 185, 130), [UIColor grayColor]];
    
    for (int i=0; i<keys.count; i++) {
        float zhanbi = [values[i] floatValue]/sum;
        
        endAngle = startAngle + zhanbi*2*M_PI;
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:yPoint radius:r startAngle:startAngle endAngle:endAngle clockwise:YES];
        [path addLineToPoint:yPoint];
        [path closePath];
        
        layer.path = path.CGPath;
        layer.fillColor = colors[i].CGColor;
        layer.strokeColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:layer];
        
        
        CGFloat lab_x = yPoint.x + (r/2) * cos((startAngle + (endAngle - startAngle)/2)) - 30/2;
        CGFloat lab_y = yPoint.y + (r/2) * sin((startAngle + (endAngle - startAngle)/2)) - 20/2;
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(lab_x, lab_y, 36, 20)];
//        lab.text = keys[i];
        lab.text = [NSString stringWithFormat:@"%.0f%%",zhanbi*100];
        lab.textColor = [UIColor whiteColor];
        lab.font = [UIFont boldSystemFontOfSize:12];
        lab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lab];
        
        if (i == 2) {
            lab.hidden = YES;
        }
        startAngle = endAngle;

    }
}


- (void)drawBarChart:(NSArray *)keys values:(NSArray *)values {
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self setNeedsDisplay];
    [self layoutIfNeeded];

    [self drawCoordinates:keys];
    
    //画柱状图
    for (int i=0; i<keys.count; i++) {
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(2*kMargin+1.5*kMargin*i, self.bounds.size.height-kMargin-3*[values[i] floatValue], 0.8*kMargin, 3*[values[i] floatValue])];
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = path.CGPath;
        layer.fillColor = kRandomColor.CGColor;
        layer.strokeColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:layer];
    }
    
    //给x轴加标注
    for (int i=0; i<keys.count; i++) {
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(2*kMargin+1.5*kMargin*i, self.bounds.size.height-kMargin, 0.8*kMargin, 20)];
        lab.text = keys[i];
        lab.textColor = [UIColor blackColor];
        lab.font = [UIFont boldSystemFontOfSize:12];
        lab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lab];
    }
}


/**
 画折线图
 */
- (void)drawLineChart:(NSArray *)keys values:(NSArray *)values {
    
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self setNeedsDisplay];
    [self layoutIfNeeded];

    [self drawCoordinates:keys];
    
    CGPoint startPoint = CGPointMake(2*kMargin, self.bounds.size.height-kMargin-3*[values[0] floatValue]);
    CGPoint endPoint;
    
    for (int i=0; i<keys.count; i++) {
        
        endPoint = CGPointMake(2*kMargin+1.5*kMargin*i, self.bounds.size.height-kMargin-3*[values[i] floatValue]);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:startPoint];
        [path addArcWithCenter:endPoint radius:1.5 startAngle:0 endAngle:2*M_PI clockwise:YES];
        [path addLineToPoint:endPoint];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = path.CGPath;
        layer.strokeColor = [UIColor redColor].CGColor;
        layer.lineWidth = 1.0;
        [self.layer addSublayer:layer];
        
        
        //        CAShapeLayer *layer1 = [CAShapeLayer layer];
        //        layer1.frame = CGRectMake(endPoint.x, endPoint.y, 5, 5);
        //        layer1.backgroundColor = [UIColor blackColor].CGColor;
        //        [self.layer addSublayer:layer1];
        
        //绘制虚线
        [self drawDashLine:endPoint];
        
        
        startPoint = endPoint;
    }
    
    //给x轴加标注
    for (int i=0; i<keys.count; i++) {
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(2*kMargin+1.5*kMargin*i-0.4*kMargin, self.bounds.size.height-kMargin, 0.8*kMargin, 20)];
        lab.text = keys[i];
        lab.textColor = [UIColor blackColor];
        lab.font = [UIFont boldSystemFontOfSize:12];
        lab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lab];
    }

}


#pragma mark - helper

// 画坐标轴
- (void)drawCoordinates:(NSArray *)keys{
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //坐标轴原点
    CGPoint rPoint = CGPointMake(kMargin, self.bounds.size.height-kMargin);
    
    //画y轴
    [path moveToPoint:rPoint];
    [path addLineToPoint:CGPointMake(kMargin, kMargin)];
    
    //画y轴的箭头
    [path moveToPoint:CGPointMake(kMargin, kMargin)];
    [path addLineToPoint:CGPointMake(kMargin-5, kMargin+5)];
    [path moveToPoint:CGPointMake(kMargin, kMargin)];
    [path addLineToPoint:CGPointMake(kMargin+5, kMargin+5)];
    
    //画x轴
    [path moveToPoint:rPoint];
    [path addLineToPoint:CGPointMake(self.bounds.size.width-kMargin, self.bounds.size.height-kMargin)];
    
    //画x轴的箭头
    [path moveToPoint:CGPointMake(self.bounds.size.width-kMargin, self.bounds.size.height-kMargin)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width-kMargin-5, self.bounds.size.height-kMargin-5)];
    [path moveToPoint:CGPointMake(self.bounds.size.width-kMargin, self.bounds.size.height-kMargin)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width-kMargin-5, self.bounds.size.height-kMargin+5)];
    
    
    //画x轴上的标度
    for (int i = 0; i<keys.count; i++) {
        [path moveToPoint:CGPointMake(2*kMargin+2*kMargin*i, self.bounds.size.height-kMargin)];
        [path addLineToPoint:CGPointMake(2*kMargin+2*kMargin*i, self.bounds.size.height-kMargin-3)];
    }
    
    //画y轴上的标度
    for (int i=0; i<10; i++) {
        [path moveToPoint:CGPointMake(kMargin, self.bounds.size.height-2*kMargin-kMargin*i)];
        [path addLineToPoint:CGPointMake(kMargin+3, self.bounds.size.height-2*kMargin-kMargin*i)];
    }
    
    layer.path = path.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor blackColor].CGColor;
    layer.lineWidth = 2.0;
    [self.layer addSublayer:layer];
    
    //给y轴加标注
    for (int i=0; i<11; i++) {
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(kMargin-25, self.bounds.size.height-kMargin-kMargin*i-10, 25, 20)];
        lab.text = [NSString stringWithFormat:@"%d", 10*i];
        lab.textColor = [UIColor blackColor];
        lab.font = [UIFont boldSystemFontOfSize:12];
        lab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lab];
    }
}

//绘制虚线
- (void)drawDashLine:(CGPoint)point{
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    [shapeLayer setStrokeColor:[UIColor blackColor].CGColor];
    
    [shapeLayer setLineWidth:1];
    [shapeLayer setLineJoin:kCALineJoinRound];
    
    //设置虚线的线宽及间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:2], [NSNumber numberWithInt:3], nil]];
    
    //创建虚线绘制路径
    CGMutablePathRef path = CGPathCreateMutable();
    
    //设置y轴方向的虚线
    CGPathMoveToPoint(path, NULL, point.x, point.y);
    CGPathAddLineToPoint(path, NULL, point.x, self.bounds.size.height-kMargin);
    
    //设置x轴方向的虚线
    CGPathMoveToPoint(path, NULL, point.x, point.y);
    CGPathAddLineToPoint(path, NULL, kMargin, point.y);
    
    //设置虚线绘制路径
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    [self.layer addSublayer:shapeLayer];
}



@end
