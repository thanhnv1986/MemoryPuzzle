//
//  PuzzleView.m
//  MemoryPuzzle
//
//  Created by Nguyen Van Thanh on 4/3/13.
//  Copyright (c) 2013 Nguyen Van Thanh. All rights reserved.
//

#import "PuzzleView.h"
#import <QuartzCore/QuartzCore.h>
@interface PuzzleView () {
    UIImageView *_backPhoto;
}
@end

@implementation PuzzleView
@synthesize imageView, value;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    imageView.image = [UIImage imageNamed:@"icon.png"];
    imageView.userInteractionEnabled = YES;
    [self addSubview:imageView];
    
    //Make corner
    self.layer.cornerRadius = 15;
    self.layer.masksToBounds = YES;
    return self;
}

- (void)setImage:(UIImage *)image{
    imageView.image = image;

//    //Flip effect
//    [UIView transitionWithView:imageView duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
//    } completion:^(BOOL finished) {
//    }];
}

- (void)shakeImage {
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
    [shake setDuration:0.1];
    [shake setRepeatCount:2];
    [shake setAutoreverses:YES];
    [shake setFromValue:[NSValue valueWithCGPoint:
                         CGPointMake(imageView.center.x - 5, imageView.center.y)]];
    [shake setToValue:[NSValue valueWithCGPoint:
                       CGPointMake(imageView.center.x + 5, imageView.center.y)]];
    [imageView.layer addAnimation:shake forKey:@"position"];
}

/*
   // Only override drawRect: if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   - (void)drawRect:(CGRect)rect
   {
   // Drawing code
   }
 */

@end
