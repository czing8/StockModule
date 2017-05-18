//
//  VStockRightView.m
//  HBStockView
//
//  Created by Vols on 2017/3/13.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VStockRightView.h"
#import "VScrollMenuView.h"
#import "VBidPriceView.h"
#import "VTradeDetailView.h"
#import "VBigTradeView.h"

#import "StockRequest.h"

#import "Masonry.h"

@interface VStockRightView () <VScrollMenuViewDelegate>

@property (nonatomic, strong) VScrollMenuView   * scrollMenu;      // 顶部选择菜单

@property (nonatomic, strong) VBidPriceView     * bidPriceView;     // 五档图
@property (nonatomic, strong) VTradeDetailView  * tradeDetailView;  // 交易明细
@property (nonatomic, strong) VTradeDetailView  * bigTradeView;     // 大单视图


@end

@implementation VStockRightView

#pragma mark - View Lifecycle

- (void)dealloc {

}

- (instancetype)init {
    if (self = [super init]) {

        [self configureViews];
    }
    return self;
}

- (void)configureViews {
    
    _scrollMenu = [[VScrollMenuView alloc]initWithTitles:@[@"五档", @"明细", @"大单"] layoutStyle:VScrollMenuLayoutStyleInScreen];
    _scrollMenu.titleFont = [UIFont systemFontOfSize:13];
    [self addSubview:_scrollMenu];
    [_scrollMenu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
        make.height.equalTo(@24);
    }];
    _scrollMenu.delegate = self;
    
    [self addSubview:self.bidPriceView];
    [self addSubview:self.tradeDetailView];
    [self addSubview:self.bigTradeView];

    [_bidPriceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(_scrollMenu.mas_top);
    }];
    
    [_tradeDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(_scrollMenu.mas_top);
    }];

    [_bigTradeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(_scrollMenu.mas_top);
    }];

    _bidPriceView.backgroundColor = [UIColor clearColor];
    _tradeDetailView.backgroundColor = [UIColor clearColor];
    _bigTradeView.backgroundColor = [UIColor orangeColor];
}

#pragma mark - Properties

- (VBidPriceView *)bidPriceView {
    if (_bidPriceView == nil) {
        _bidPriceView = [VBidPriceView new];
    }
    return _bidPriceView;
}

- (VTradeDetailView *)tradeDetailView {
    if (_tradeDetailView == nil) {
        _tradeDetailView = [VTradeDetailView new];
        _tradeDetailView.hidden = YES;
    }
    return _tradeDetailView;
}

- (VTradeDetailView *)bigTradeView {
    if (_bigTradeView == nil) {
        _bigTradeView = [VTradeDetailView new];
        _bigTradeView.hidden = YES;
    }
    return _bigTradeView;
}



- (void)setStockGroup:(VStockGroup *)stockGroup{
    _stockGroup = stockGroup;
    
    [self.bidPriceView reloadWithModel:_stockGroup.bidPriceModel];
    [self.tradeDetailView reloadWithData:_stockGroup.tradeModels];
//    [self.bidPriceView reloadWithModel:_stockGroup.bidPriceModel];
    
    [StockRequest getDaDanRequest:_stockGroup.stockCode success:^(NSArray *resultArray) {
        [_bigTradeView reloadWithData:resultArray];
    }];
}

#pragma mark - ScrollMenuDelegate

- (void)scrollMenu:(VScrollMenuView *)scrollMenu didSelectedIndex:(NSInteger)index {
    _bidPriceView.hidden = YES;
    _tradeDetailView.hidden = YES;
    _bigTradeView.hidden = YES;

    if (index == 0) {
        _bidPriceView.hidden = NO;
    }
    else if (index == 1) {
        _tradeDetailView.hidden = NO;
        [_tradeDetailView reloadWithData:_stockGroup.tradeModels];
    }
    else if (index == 2) {
        _bigTradeView.hidden = NO;
        [StockRequest getDaDanRequest:_stockGroup.stockCode success:^(NSArray *resultArray) {
            [_bigTradeView reloadWithData:resultArray];
        }];
    }
}


@end
