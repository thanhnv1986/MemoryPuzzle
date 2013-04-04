//
//  PuzzleView.h
//  MemoryPuzzle
//
//  Created by Nguyen Van Thanh on 4/3/13.
//  Copyright (c) 2013 Nguyen Van Thanh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PuzzleView : UIView
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic) NSInteger value;
- (void)setImage:(UIImage*)image;
- (void)shakeImage;
@end
