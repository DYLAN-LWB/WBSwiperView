//
//  ViewController.m
//  WBSwiperView
//
//  Created by 李伟宾 on 2018/7/20.
//  Copyright © 2018年 李伟宾. All rights reserved.
//

#import "ViewController.h"
#import "WBSwiperView.h"

@interface ViewController ()
@property (nonatomic, strong) WBSwiperView *swiper;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *imageUrls = @[@"https://apk.beisuapp.beisu100.com//uploads/navimg/origin/2018/06/20180619111332_57399.jpg",
                           @"https://apk.beisuapp.beisu100.com//uploads/navimg/origin/2018/05/20180518085713_81160.jpg",
                           @"https://apk.beisuapp.beisu100.com//uploads/navimg/origin/2018/05/20180517135659_54349.png",
                           @"https://apk.beisuapp.beisu100.com//uploads/navimg/origin/2018/02/20180209140638_10447.png"];
    
    self.swiper = [[WBSwiperView alloc] initSwiperViewWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200)];
    self.swiper.imageUrlArray = imageUrls;
    [self.view addSubview:self.swiper];
    

    self.swiper.viewPageClick = ^(NSInteger index) {
        NSLog(@"点击了第%ld个", index);
    };
}


@end
