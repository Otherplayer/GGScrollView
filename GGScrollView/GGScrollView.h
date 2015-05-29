//
//  GGScrollView.h
//  GGScrollView
//
//  Created by __无邪_ on 15/5/29.
//  Copyright (c) 2015年 __无邪_. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGScrollView : UIView


- (instancetype)initWithFrame:(CGRect)frame imageURLs:(NSArray *)imageURLs placeholder:(UIImage *)placeholder;

@property (nonatomic, assign) NSUInteger scrollInterval;    // default is 2 seconds
@property (nonatomic, assign) BOOL autoScroll;
@property (nonatomic, strong, setter=didClickedIndexBlock:) void(^clickedBlock)(NSInteger index);


@end
