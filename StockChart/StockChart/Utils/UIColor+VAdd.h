//
//  UIColor+Extends.h
//
//
//  Created by Vols on 16/3/11.
//  Copyright © 2016年 Vols. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define kRGB(r, g, b)       [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]
//#define kRGBA(r,g,b,a)      [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:(a)]

#define kRGBHex(rgbValue)   [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface UIColor (VAdd)

+ (UIColor *)randomColor;

+ (UIColor *)colorWithHex:(int)hexValue;
+ (UIColor *)colorWithHex:(int)hexValue alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHexString:(NSString *)hexStr;

@end



@interface UIColor (FlatColors)

+ (UIColor *)flatRedColor;
+ (UIColor *)flatDarkRedColor;

+ (UIColor *)flatGreenColor;
+ (UIColor *)flatDarkGreenColor;

+ (UIColor *)flatBlueColor;
+ (UIColor *)flatDarkBlueColor;

+ (UIColor *)flatTealColor;
+ (UIColor *)flatDarkTealColor;

+ (UIColor *)flatPurpleColor;
+ (UIColor *)flatDarkPurpleColor;

+ (UIColor *)flatBlackColor;
+ (UIColor *)flatDarkBlackColor;

+ (UIColor *)flatYellowColor;
+ (UIColor *)flatDarkYellowColor;

+ (UIColor *)flatOrangeColor;
+ (UIColor *)flatDarkOrangeColor;

+ (UIColor *)flatWhiteColor;
+ (UIColor *)flatDarkWhiteColor;

+ (UIColor *)flatGrayColor;
+ (UIColor *)flatDarkGrayColor;

@end
