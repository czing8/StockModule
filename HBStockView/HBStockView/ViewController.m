//
//  ViewController.m
//  HBStockView
//
//  Created by Vols on 2017/2/25.
//  Copyright © 2017年 vols. All rights reserved.
//

#import "ViewController.h"
#import "StockRequest.h"
#import "VTimeLineGroup.h"
#import "VStockView.h"
#import "Masonry.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *stockStatusView;

@property (nonatomic, strong) NSMutableDictionary * stockDataSource;
@property (nonatomic, strong) VStockView * stockView;

@property (nonatomic, strong) VTimeLineGroup * timeGroup;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureViews];
    
    [self fetchData];
}


- (void)configureViews {
    self.view.backgroundColor = [UIColor greenColor];
    self.title = @"华天科技(002185)";
    
    
    _stockView = [[VStockView alloc] init];
    [self.view addSubview:self.stockView];
    _stockView.backgroundColor = [UIColor purpleColor];
    [_stockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_stockStatusView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(300);
    }];
    
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchData)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    [StockRequest get5DayStockDataSuccess:^(NSArray *resultArray) {
        
    }];
    
    [StockRequest getWeekStockDataSuccess:^(VLineGroup *response) {
        
    }];
    
    [StockRequest getMonthStockDataSuccess:^(VLineGroup *response) {
        
    }];
}

- (void)fetchData {
    
    [self.stockView reloadData];
    
//    [StockRequest getDayStockDataSuccess:^(VLineGroup *response) {
//        NSLog(@"count:%lu", (unsigned long)response.lineModels.count);
//        [self.stockDataSource setObject:response forKey:@"daySource"];
//    }];
//    
//    
//    [StockRequest getTimeStockDataSuccess:^(VTimeLineGroup *response) {
//        _timeGroup = response;
//        
//        [self.stockDataSource setObject:_timeGroup forKey:@"minutes"];
//        [self.stockView reloadWithDataSource:_stockDataSource];
//    }];
    
}

#pragma mark - Properties
- (NSMutableDictionary *)stockDataSource{
    if (_stockDataSource == nil) {
        _stockDataSource = [[NSMutableDictionary alloc] init];
    }
    return _stockDataSource;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
