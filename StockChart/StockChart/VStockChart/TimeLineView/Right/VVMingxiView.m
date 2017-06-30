//
//  VVMingxiView.m
//  HBStockView
//
//  Created by Vols on 2017/3/13.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VVMingxiView.h"
#import "VVMingxiCell.h"
#import "UIColor+StockTheme.h"

#import "Masonry.h"
#import "MJRefresh.h"
#import "StockRequest.h"

@interface VVMingxiView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView       * tableView;
@property (nonatomic, strong) NSMutableArray    * dataSource;
@property (nonatomic, strong) NSString          * stockCode;

@end

@implementation VVMingxiView{
    NSString    * _curIndex;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _curIndex = @"0";
        [self configureViews];
    }
    return self;
}

#pragma mark - public

- (void)reloadWithStockCode:(NSString*)stockCode {
    _stockCode = stockCode;

    [StockRequest getMingxiRequest:_stockCode index:@"0" success:^(NSArray<VTimeTradeModel *> *resultArray, NSString * index) {
        _curIndex = index;
        if (self.dataSource.count > 0) {
            [_dataSource removeAllObjects];
        }
        _dataSource = [NSMutableArray arrayWithArray:[[resultArray reverseObjectEnumerator] allObjects]];
        [self.tableView reloadData];
    }];
}


- (void)reloadWithData:(NSArray <VTimeTradeModel *>*)tradeModels{
//    _curIndex = @"0";
//    _dataSource = [NSMutableArray arrayWithArray:tradeModels];
//    [self.tableView reloadData];
}


//- (void)setStockCode:(NSString *)stockCode {
//    _stockCode = stockCode;
//    
//    [StockRequest getMingxiRequest:_stockCode index:@"0" success:^(NSArray *resultArray, NSString * index) {
//        _curIndex = index;
//        if (self.dataSource.count > 0) {
//            [_dataSource removeAllObjects];
//        }
//        _dataSource = [NSMutableArray arrayWithArray:[[resultArray reverseObjectEnumerator] allObjects]];
//        [self.tableView reloadData];
//    }];
//}


- (void)configureViews {
    [self addSubview:self.tableView];
    self.backgroundColor = [UIColor purpleColor];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    // MJRefresh 刷新设置
    MJRefreshNormalHeader *mjHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [StockRequest getMingxiRequest:_stockCode index:@"0" success:^(NSArray *resultArray, NSString * index) {
            _curIndex = index;
            if (self.dataSource.count > 0) {
                [_dataSource removeAllObjects];
            }
            _dataSource = [NSMutableArray arrayWithArray:[[resultArray reverseObjectEnumerator] allObjects]];
            [self.tableView reloadData];

            [self.tableView.mj_header endRefreshing];
        }];
    }];

    mjHeader.automaticallyChangeAlpha = YES;
    mjHeader.lastUpdatedTimeLabel.hidden = YES;
    mjHeader.stateLabel.hidden = YES;

    MJRefreshBackNormalFooter *mjFooter = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [StockRequest getMingxiRequest:_stockCode index:_curIndex success:^(NSArray *resultArray, NSString * index) {
            _curIndex = index;
            [_dataSource addObjectsFromArray:[[resultArray reverseObjectEnumerator] allObjects]];
            [self.tableView reloadData];
            
            [self.tableView.mj_footer endRefreshing];
        }];

    }];
    mjFooter.stateLabel.hidden = YES;
    
    self.tableView.mj_header = mjHeader;
    self.tableView.mj_footer = mjFooter;
}


#pragma mark - Properties

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor purpleColor];
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[VVMingxiCell class] forCellReuseIdentifier:kMingXiCellIdentifier];
        _tableView.rowHeight = 24;      //预估行高 可以提高性能
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.sectionHeaderHeight = 14;

    }
    return _tableView;
}

#pragma mark - UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VVMingxiCell * cell = [tableView dequeueReusableCellWithIdentifier:kMingXiCellIdentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor colorWithWhite:0.293 alpha:1.000];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.model = _dataSource[indexPath.row];
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView * headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 14)];
    headView.backgroundColor = [UIColor stockMainBgColor];
    
    float width = (self.bounds.size.width-3)/3.0 ;
    NSArray * titles = @[@"时间", @"价格", @"成交量"];
    for (int i = 0; i < 3; i ++) {
        UILabel * label = [[UILabel alloc] init];
        label.frame = CGRectMake(2+i*width, 0, width, 14);
        label.font = [UIFont systemFontOfSize:12];
        label.text = titles[i];
        [headView addSubview:label];
        if (i == 2) {
            label.textAlignment = NSTextAlignmentRight;
            label.frame = CGRectMake(2+i*width, 0, width + 3, 14);
        }
    }
    
    return headView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSelector:@selector(deselect:) withObject:tableView afterDelay:0.2f];
}

- (void)deselect:(UITableView *)tableView {
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}



@end
