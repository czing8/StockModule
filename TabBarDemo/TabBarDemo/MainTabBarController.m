//
//  MainTabBarController.m
//  TabBarDemo
//
//  Created by Vols on 15/3/18.
//  Copyright (c) 2015年 Vols. All rights reserved.
//

#import "MainTabBarController.h"

#define TABBARHEIGHT 49
#define kSCREEN_SIZE  [UIScreen mainScreen].bounds.size

@interface MainTabBarController (){
    UIView * _tabBarView;
    UIImageView * _backgroundView;
    UIButton * _lastButton;
    NSArray * normalArr;
    NSArray * selectedArr ;
}

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initImagesArray];
    [self initTabBarView];
}


- (void) initImagesArray{
    normalArr = @[@"navi_1a", @"navi_2a", @"navi_3a", @"navi_4a"];
    selectedArr = @[@"navi_1b", @"navi_2b", @"navi_3b", @"navi_4b"];
}

- (void) initTabBarView {
    _tabBarView = [[UIView alloc] initWithFrame:self.tabBar.bounds];
    _tabBarView.backgroundColor = [UIColor whiteColor];
    [self.tabBar addSubview:_tabBarView];
    
    NSLog(@"%lu", (unsigned long)normalArr.count);
    
    UIButton *tabBarButton;
    CGFloat width = kSCREEN_SIZE.width / normalArr.count;
    for (int i = 0; i < normalArr.count; i++){
        tabBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tabBarButton.showsTouchWhenHighlighted = YES;
        tabBarButton.tag = i+1000;
        tabBarButton.frame = CGRectMake(width * i, 0, width, 55);
        
        [tabBarButton setImage:[UIImage imageNamed:normalArr[i]] forState:UIControlStateNormal];
        [tabBarButton setImage:[UIImage imageNamed:selectedArr[i]] forState:UIControlStateHighlighted];
        [tabBarButton setImage:[UIImage imageNamed:selectedArr[i]] forState:UIControlStateSelected];
        
        [tabBarButton addTarget:self action:@selector(tabBarClick:) forControlEvents:UIControlEventTouchUpInside];
        [_tabBarView addSubview:tabBarButton];
        
        if (0 == i) {
            _lastButton = tabBarButton;
            tabBarButton.selected = YES;
        }
    }
}

- (void)tabBarClick:(UIButton *)button{
    
    self.selectedIndex = button.tag - 1000;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex{
    [super setSelectedIndex:selectedIndex];
    
    _lastButton.selected = NO;
    _lastButton = (UIButton *)[self.view viewWithTag: self.selectedIndex+1000];
    _lastButton.selected = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
