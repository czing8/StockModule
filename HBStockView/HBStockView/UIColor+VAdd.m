//
//  UIColor+Extends.m
//
//
//  Created by Vols on 16/3/11.
//  Copyright © 2016年 Vols. All rights reserved.
//

#import "UIColor+VAdd.h"


@implementation UIColor (VAdd)

static inline NSUInteger hexStrToInt(NSString *str) {
    uint32_t result = 0;
    sscanf([str UTF8String], "%X", &result);
    return result;
}

static BOOL hexStrToRGBA(NSString *str,
                         CGFloat *r, CGFloat *g, CGFloat *b, CGFloat *a) {
    str = [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([str hasPrefix:@"#"]) {
        str = [str substringFromIndex:1];
    } else if ([str hasPrefix:@"0X"]) {
        str = [str substringFromIndex:2];
    }
    
    NSUInteger length = [str length];
    //         RGB            RGBA          RRGGBB        RRGGBBAA
    if (length != 3 && length != 4 && length != 6 && length != 8) {
        return NO;
    }
    
    //RGB,RGBA,RRGGBB,RRGGBBAA
    if (length < 5) {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 1)]) / 255.0f;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(1, 1)]) / 255.0f;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(2, 1)]) / 255.0f;
        if (length == 4)  *a = hexStrToInt([str substringWithRange:NSMakeRange(3, 1)]) / 255.0f;
        else *a = 1;
    } else {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 2)]) / 255.0f;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(2, 2)]) / 255.0f;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(4, 2)]) / 255.0f;
        if (length == 8) *a = hexStrToInt([str substringWithRange:NSMakeRange(6, 2)]) / 255.0f;
        else *a = 1;
    }
    return YES;
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    CGFloat r, g, b, a;
    if (hexStrToRGBA(hexString, &r, &g, &b, &a)) {
        return [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
    return nil;
}

/* 第二种方法
+ (UIColor *)colorWithHexString:(NSString *)hexString {
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned hexValue;
    if (![scanner scanHexInt:&hexValue]) return nil;
    return [UIColor colorWithHex:hexValue];
}
*/


+ (UIColor *)colorWithHex:(int)hexValue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0
                           alpha:alpha];
}


+ (UIColor *)colorWithHex:(int)hexValue {
    return [UIColor colorWithHex:hexValue alpha:1.0];
}


+ (UIColor *)randomColor {
    
    CGFloat hue = ( arc4random() % 256 / 256.0 );
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    //指定HSB，参数是：色调（hue），饱和的（saturation），亮度（brightness）
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

/* 第二种方法
+ (UIColor *)randomColor {
    return [UIColor colorWithRed:(arc4random()%256)/256.f
                           green:(arc4random()%256)/256.f
                            blue:(arc4random()%256)/256.f
                           alpha:1.0f];
}
*/

@end


@implementation UIColor (FlatColors)

#pragma mark - Red
+ (UIColor *)flatRedColor {
    return kRGBHex(0xE74C3C);
}

+ (UIColor *)flatDarkRedColor {
    return kRGBHex(0xC0392B);
}

#pragma mark - Green
+ (UIColor *)flatGreenColor {
    return kRGBHex(0x2ECC71);
}

+ (UIColor *)flatDarkGreenColor {
    return kRGBHex(0x27AE60);
}


#pragma mark - Blue
+ (UIColor *)flatBlueColor {
    return kRGBHex(0x3498DB);
}

+ (UIColor *)flatDarkBlueColor {
    return kRGBHex(0x2980B9);
}


#pragma mark - Teal
+ (UIColor *)flatTealColor {
    return kRGBHex(0x1ABC9C);
}

+ (UIColor *)flatDarkTealColor {
    return kRGBHex(0x16A085);
}

#pragma mark - Purple
+ (UIColor *)flatPurpleColor {
    return kRGBHex(0x9B59B6);
}

+ (UIColor *)flatDarkPurpleColor {
    return kRGBHex(0x8E44AD);
}


#pragma mark - Yellow
+ (UIColor *)flatYellowColor {
    return kRGBHex(0xF1C40F);
}

+ (UIColor *)flatDarkYellowColor {
    return kRGBHex(0xF39C12);
}


#pragma mark - Orange
+ (UIColor *)flatOrangeColor {
    return kRGBHex(0xE67E22);
}

+ (UIColor *)flatDarkOrangeColor {
    return kRGBHex(0xD35400);
}


#pragma mark - Gray
+ (UIColor *)flatGrayColor {
    return kRGBHex(0x95A5A6);
}

+ (UIColor *)flatDarkGrayColor {
    return kRGBHex(0x7F8C8D);
}


#pragma mark - White
+ (UIColor *)flatWhiteColor {
    return kRGBHex(0xECF0F1);
}

+ (UIColor *)flatDarkWhiteColor {
    return kRGBHex(0xBDC3C7);
}


#pragma mark - Black
+ (UIColor *)flatBlackColor {
    return kRGBHex(0x34495E);
}

+ (UIColor *)flatDarkBlackColor {
    return kRGBHex(0x2C3E50);
}

@end

