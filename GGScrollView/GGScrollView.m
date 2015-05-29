//
//  GGScrollView.m
//  GGScrollView
//
//  Created by __无邪_ on 15/5/29.
//  Copyright (c) 2015年 __无邪_. All rights reserved.
//

#import "GGScrollView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+Random.h"

#define kStartTag  1000
#define kDefaultScrollInterval  2



@interface GGScrollView ()<UIScrollViewDelegate>{
    CGFloat width;
    CGFloat height;
    NSArray *urls;
    
    BOOL couldScroll;
}

@property (nonatomic, strong)UIScrollView *scrollView;
@property (nonatomic, strong)UIPageControl *pageControl;

@property (nonatomic, strong)NSTimer *autoScrollTimer;

@end

@implementation GGScrollView


- (instancetype)initWithFrame:(CGRect)frame imageURLs:(NSArray *)imageURLs placeholder:(UIImage *)placeholder{
    self = [super initWithFrame:frame];
    if (self) {
        
        if (imageURLs && imageURLs.count > 0) {
            
            width = frame.size.width;
            height = frame.size.height;
            
            CGRect contentRect = frame;
            contentRect.origin.y = 0;
            
            
            NSMutableArray *newImageURLs = [[NSMutableArray alloc] initWithArray:imageURLs];
            [newImageURLs insertObject:[imageURLs lastObject] atIndex:0];
            [newImageURLs addObject:[imageURLs firstObject]];
            urls = [[NSArray alloc] initWithArray:newImageURLs];
            
            /*
             * ScrollView
             */
            
            self.scrollView = [[UIScrollView alloc] initWithFrame:contentRect];
            [self addSubview:self.scrollView];
            self.scrollView.contentSize = CGSizeMake(newImageURLs.count * width, height);
            self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
            self.scrollView.pagingEnabled = YES;
            self.scrollView.bounces = NO;
            self.scrollView.showsHorizontalScrollIndicator = NO;
            self.scrollView.showsVerticalScrollIndicator = NO;
            self.scrollView.directionalLockEnabled = YES;
            self.scrollView.contentInset = UIEdgeInsetsZero;
            
            self.scrollView.delegate = self;
            
            
            /*
             * PageControl
             */
            
            self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, height - 20, width, 20)];
            [self addSubview:self.pageControl];
            self.pageControl.numberOfPages = imageURLs.count;
            self.pageControl.currentPage = 0;
            self.pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
            self.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.000 alpha:0.500];
            
            /*
             * AutoScrollTimer
             */
            
            couldScroll = NO;
            if (imageURLs.count > 1) {
                couldScroll = YES;
            }
            self.scrollInterval = kDefaultScrollInterval;
            
            
            [self initWithImageURLs:newImageURLs placeholder:placeholder];
            
            [self setCurrentPage:1 animated:NO];
            
            
            if (imageURLs.count == 1) {
                [self.scrollView setScrollEnabled:NO];
            }
            
        }
        
    }
    return self;
}


- (void)initWithImageURLs:(NSArray *)imageURLs placeholder:(UIImage *)placeholder{
   
    
    for (int i = 0; i < imageURLs.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * width, 0, width, height)];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.clipsToBounds = YES;
        imageView.tag = kStartTag + i;
        imageView.userInteractionEnabled = YES;
        //[imageView setImage:placeholder];
        [imageView sd_setImageWithURL:imageURLs[i] placeholderImage:placeholder];
        [imageView setBackgroundColor:[UIColor RandomColor]];
        [self.scrollView addSubview:imageView];
        
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedAtIndex:)];
        [imageView addGestureRecognizer:tapGesture];
        
    }
    
}

#pragma mark - AutoScroll

- (void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;
    
    if (autoScroll) {
        if (!self.autoScrollTimer || !self.autoScrollTimer.isValid) {
            [self createTimer];
        }
    } else {
        [self killTimer];
    }

}

- (void)setScrollInterval:(NSUInteger)scrollInterval{
    _scrollInterval = scrollInterval;
    
    [self killTimer];
    [self createTimer];
}

- (void)handleScrollTimer:(NSTimer *)timer{
    
    if (!couldScroll) {
        [self killTimer];
        return;
    }
    
    NSInteger nextPage = self.pageControl.currentPage + 1;
    if (nextPage > ([self pages] - 2)) {
        nextPage = 1;
    }
    [self setCurrentPage:(nextPage + 1) animated:YES];
    
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView.contentOffset.x >= ([self pages] - 1) * width) {
        [self setCurrentPage:1 animated:NO];
    }else if (scrollView.contentOffset.x <= 0.0){
        [self setCurrentPage:([self pages] - 2) animated:NO];
    }
    
    [self.pageControl setCurrentPage:([self currentPage] - 1)];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self killTimer];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    // when user scrolls manually, stop timer and start timer again to avoid next scroll immediatelly
    [self killTimer];
    [self createTimer];
}


#pragma mark - Action

- (void)clickedAtIndex:(UITapGestureRecognizer *)sender{
    
    if (self.clickedBlock) {
        self.clickedBlock([self currentPage]);
    }
    
}


#pragma mark - Private

/*
 *page:真实页码，从 1 开始
 */
- (void)setCurrentPage:(NSInteger)page animated:(BOOL)animated{
    [self.scrollView setContentOffset:CGPointMake(width * page, 0) animated:animated];
}

- (NSInteger)currentPage{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger currentPage = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    return currentPage;
}

- (NSInteger)pages{
    NSInteger pages = self.scrollView.contentSize.width/width;
    return pages;
}



- (void)killTimer{
    if (self.autoScrollTimer && self.autoScrollTimer.isValid) {
        [self.autoScrollTimer invalidate];
        self.autoScrollTimer = nil;
    }
}
- (void)createTimer{
    self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.scrollInterval target:self selector:@selector(handleScrollTimer:) userInfo:nil repeats:YES];
}


@end
