//
//  VStockLineDataModel.h
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

// K线图数据源
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface VLineModel : NSObject

@property (nonatomic, strong) VLineModel  * preDataModel;  // 前一个数据

@property (nonatomic, strong) NSString  * day;          // 日期

@property (nonatomic, assign) CGFloat   openPrice;     // 开盘价
@property (nonatomic, assign) CGFloat   closePrice;    // 收盘价
@property (nonatomic, assign) CGFloat   highestPrice;  // 最高价
@property (nonatomic, assign) CGFloat   lowestPrice;   // 最低价
@property (nonatomic, assign) CGFloat   volume;        //  成交量

@property (nonatomic, assign) CGFloat   ma5;    // MA5 五日均线
@property (nonatomic, assign) CGFloat   ma10;   // MA10
@property (nonatomic, assign) CGFloat   ma20;   // MA20

@property (nonatomic, strong) NSString  * dayDatail;    //  长按时显示的详细日期



/**
 * 是否绘制在View上
 */
@property (nonatomic, assign) BOOL isShowDay;




- (instancetype)initWithDict: (NSDictionary *)dict;

- (void)updateMA:(NSArray *)parentDictArray;


@end
