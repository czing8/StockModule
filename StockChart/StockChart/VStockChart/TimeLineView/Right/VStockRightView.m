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
#import "VDaDanView.h"

#import "StockRequest.h"

#import "Masonry.h"

@interface VStockRightView () <VScrollMenuViewDelegate>

@property (nonatomic, strong) VScrollMenuView   * scrollMenu;      // 顶部选择菜单

@property (nonatomic, strong) VBidPriceView     * bidPriceView;     // 五档图
@property (nonatomic, strong) VTradeDetailView  * tradeDetailView;  // 交易明细
@property (nonatomic, strong) VDaDanView        * daDanView;     // 大单视图


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
    [self addSubview:self.daDanView];

    [_bidPriceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(_scrollMenu.mas_top);
    }];
    
    [_tradeDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(_scrollMenu.mas_top);
    }];

    [_daDanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(_scrollMenu.mas_top);
    }];

    _bidPriceView.backgroundColor = [UIColor clearColor];
    _tradeDetailView.backgroundColor = [UIColor clearColor];
    _daDanView.backgroundColor = [UIColor orangeColor];
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

- (VDaDanView *)daDanView {
    if (_daDanView == nil) {
        _daDanView = [VDaDanView new];
        _daDanView.hidden = YES;
    }
    return _daDanView;
}



- (void)setStockGroup:(VStockGroup *)stockGroup{
    _stockGroup = stockGroup;
    
    [self.bidPriceView reloadWithModel:_stockGroup.bidPriceModel];
//    [self.tradeDetailView reloadWithData:_stockGroup.tradeModels];
//    self.tradeDetailView.stockCode = _stockGroup.stockCode;
}

#pragma mark - ScrollMenuDelegate

- (void)scrollMenu:(VScrollMenuView *)scrollMenu didSelectedIndex:(NSInteger)index {
    _bidPriceView.hidden = YES;
    _tradeDetailView.hidden = YES;
    _daDanView.hidden = YES;

    if (index == 0) {
        _bidPriceView.hidden = NO;
    }
    else if (index == 1) {
        _tradeDetailView.hidden = NO;
        [_tradeDetailView reloadWithStockCode:_stockGroup.stockCode];
    }
    else if (index == 2) {
        _daDanView.hidden = NO;
        [_daDanView reloadWithStockCode:_stockGroup.stockCode];
    }
}


@end
