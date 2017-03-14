//
//  VTradeDetailView.m
//  HBStockView
//
//  Created by Vols on 2017/3/13.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "VTradeDetailView.h"
#import "VTradeDetailCell.h"
#import "UIColor+StockTheme.h"

#import "Masonry.h"

@interface VTradeDetailView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView       * tableView;
@property (nonatomic, strong) NSMutableArray    * dataSource;

@end

@implementation VTradeDetailView

- (instancetype)init {
    self = [super init];
    if (self) {
//        self.delegate = self;
//        self.separatorStyle = UITableViewCellSeparatorStyleNone;
//        self.bounces = NO;
//        self.showsVerticalScrollIndicator = NO;
        [self configureViews];
    }
    return self;
}

- (void)reloadWithData:(NSArray <VTimeTradeModel *>*)tradeModels{
    _dataSource = [NSMutableArray arrayWithArray:tradeModels];
    
    [self.tableView reloadData];
}

- (void)configureViews {
    [self addSubview:self.tableView];
    self.backgroundColor = [UIColor purpleColor];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
}


#pragma mark - Properties

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor purpleColor];
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[VTradeDetailCell class] forCellReuseIdentifier:kTradeDetailCellIdentifier];
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
    
    VTradeDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:kTradeDetailCellIdentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor colorWithWhite:0.293 alpha:1.000];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.model = _dataSource[indexPath.row];
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView * headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 14)];
    headView.backgroundColor = [UIColor stockMainBgColor];
    
    float width = (self.bounds.size.width-2)/3.0 ;
    NSArray * titles = @[@"时间", @"价格", @"成交量"];
    for (int i = 0; i < 3; i ++) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(2+i*width, 0, width, 14)];
        label.font = [UIFont systemFontOfSize:12];
        label.text = titles[i];
        [headView addSubview:label];
        if (i == 2) {
            label.textAlignment = NSTextAlignmentRight;
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
