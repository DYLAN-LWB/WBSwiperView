//
//  WBSwiperView.h
//  WBSwiperView
//
//  Created by aier on 15-3-22.
//  Copyright (c) 2015年 GSD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WBSwiperView : UIView

/**
 初始化轮播图

 @param frame frame
 @return WBSwiperView
 */
- (instancetype)initSwiperViewWithFrame:(CGRect)frame;

/**
 图片url字符串数组
 */
@property (nonatomic, strong) NSArray *imageUrlArray;

/**
 轮播图点击事件
 */
@property (nonatomic, copy) void(^viewPageClick)(NSInteger);


@end
