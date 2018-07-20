//
//  WBSwiperView.m
//  WBSwiperView
//
//  Created by aier on 15-3-22.
//  Copyright (c) 2015年 GSD. All rights reserved.
//

#import "WBSwiperView.h"
#import "SDImageCache.h"
#import "SDWebImageDownloader.h"

NSString *const cellID = @"cellID";

@interface WBSwiperView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *imagesAM;         //存放图片的数组
@property (nonatomic, assign) NSInteger imagesCount;            //无限轮播需处理图片数量
@property (nonatomic, strong) NSTimer *timer;                   //计时器
@property (nonatomic, strong) UIPageControl *pageControl;       //圆点控制器
@property (nonatomic, assign) CGFloat stayTime;                 //自动滚动间隔时间
@property (nonatomic, assign) NSInteger nextIndex;              //下一页序号

@end

@implementation WBSwiperView

- (instancetype)initSwiperViewWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.stayTime = 2.0;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.pagingEnabled = YES;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.scrollEnabled = YES;
        [self addSubview:self.collectionView];
        
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];

        [self setupTimer];
    }
    return self;
}

//图片url数组
- (void)setImageUrlArray:(NSArray *)imageUrlArray {
    _imageUrlArray = imageUrlArray;

    NSMutableArray *tempA = [NSMutableArray arrayWithCapacity:imageUrlArray.count];
    for (int i = 0; i < imageUrlArray.count; i++) {
        UIImage *image = [[UIImage alloc] init];
        [tempA addObject:image];
        [self loadImageAtIndex:i];
    }
    self.imagesAM = tempA;
    //无限轮播:真实图片个数*100
    self.imagesCount = self.imagesAM.count*100;
    [self.collectionView reloadData];
    
    //添加分页控制器
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.frame = CGRectMake(0, self.collectionView.frame.size.height - 15, self.collectionView.frame.size.width, 10);
    self.pageControl.numberOfPages = self.imagesAM.count;
    self.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.userInteractionEnabled = NO;
    [self addSubview:self.pageControl];
}

//加载图片,优先使用缓存
- (void)loadImageAtIndex:(NSInteger)index {

    NSString *urlStr = self.imageUrlArray[index];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlStr];
    if (image) {
        [self.imagesAM setObject:image atIndexedSubscript:index];
    } else {
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:urlStr]
                                                              options:SDWebImageDownloaderLowPriority
                                                             progress:nil
                                                            completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                                                                 if (image) {
                                                                     //修复频繁刷新异步数组越界问题
                                                                     if (index < self.imageUrlArray.count && [self.imageUrlArray[index] isEqualToString:urlStr]) {
                                                                         [self.imagesAM setObject:image atIndexedSubscript:index];

                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                             [self.collectionView reloadData];
                                                                         });
                                                                     }
                                                                 }
                                                             }];
    }
}

//默认滚动到最中间的cell
- (void)layoutSubviews {
    [super layoutSubviews];
    self.nextIndex = self.imagesCount/2;
    
    if (self.collectionView.contentOffset.x == 0 && self.imagesCount) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.nextIndex inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionNone
                                            animated:NO];
    }
}

//添加计时器
- (void)setupTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.stayTime
                                                  target:self
                                                selector:@selector(autoScroll)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

//自动滚动
- (void)autoScroll {
    if (self.imagesCount == 0)
        return;
 
    self.nextIndex++;
    //自动滚动到最高一张时,滚动到中部(不要加动画效果)
    if (self.nextIndex == self.imagesCount) {
        self.nextIndex = self.imagesCount/2;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.nextIndex inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionNone
                                            animated:NO];
    }
    //自动滚动到下一张
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.nextIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imagesCount;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    long itemIndex = indexPath.item % self.imagesAM.count;
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    imageView.image = self.imagesAM[itemIndex];
    [cell addSubview:imageView];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.viewPageClick(indexPath.item % self.imagesAM.count);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int itemIndex = (scrollView.contentOffset.x + self.collectionView.frame.size.width * 0.5) / self.collectionView.frame.size.width;
    if (!self.imagesAM.count) return; // 解决清除timer时偶尔会出现的问题
    self.pageControl.currentPage = itemIndex % self.imagesAM.count;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self setupTimer];
}

#pragma mark -

//解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

//解决当timer释放后 回调scrollViewDidScroll时访问野指针导致崩溃
- (void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

@end
