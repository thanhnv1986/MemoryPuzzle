//
//  PuzzleView.m
//  MemoryPuzzle
//
//  Created by Nguyen Van Thanh on 4/3/13.
//  Copyright (c) 2013 Nguyen Van Thanh. All rights reserved.
//

#import "PuzzleView.h"

@implementation PuzzleView
@synthesize imageView,value;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    imageView.image = [UIImage imageNamed:@"icon.png"];
    imageView.userInteractionEnabled = YES;
    [self addSubview:imageView];
    return self;
}
- (void)setImage:(UIImage*)image{
    imageView.image=image;
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
