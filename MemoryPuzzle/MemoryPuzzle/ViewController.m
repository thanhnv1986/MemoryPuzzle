//
//  ViewController.m
//  MemoryPuzzle
//
//  Created by Nguyen Van Thanh on 4/3/13.
//  Copyright (c) 2013 Nguyen Van Thanh. All rights reserved.
//

#import "ViewController.h"
#import "PuzzleView.h"
#import "WinnerView.h"
#import <AVFoundation/AVFoundation.h>

#define PUZZLE_WIDTH  60
#define PUZZLE_HEIGHT 60
#define TIME_OUT      60
#define NUMBER_PUZZLE 20
#define NUMBER_ROW    5
#define NUMBER_COLUMN 4
#define NUMBER_IMAGE  5
@interface ViewController ()
{
    NSArray *_arrImageName;
    NSMutableArray *_arrImage;
    NSMutableArray *_arrValue;
    UITapGestureRecognizer *_tapGesture;

    PuzzleView *_firstChose;
    PuzzleView *_secondChose;
    BOOL _isFirstChose;
    BOOL _nextTurn;
    NSTimer *_timer;
    float _timeOut;
    UILabel *_stateLabel;
    UIButton *button;
    int _turnNumber;
    int _comboNumber;
    BOOL _isCombo;
    AVAudioPlayer *_audioPlayer;
    AVAudioPlayer *_backgroundSound;
    WinnerView *_winnerView;
}
@property (weak, nonatomic) IBOutlet UILabel *comboLabel;
@property (weak, nonatomic) IBOutlet UILabel *turnNumberLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *timeProgress;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startGameSound];
    _arrImageName = [[NSArray alloc]initWithObjects:@"Baseball.png", @"Football.png", @"Blocks.png", @"Checkers.png", @"Dinner.png", @"MathGraph.png", nil];


    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Play game" forState:UIControlStateNormal];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [button addTarget:self action:@selector(ReplayGame:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:[UIColor clearColor]];
    button.frame = CGRectMake(38, 260, 244, 44);
    [self.view addSubview:button];
    // Do any additional setup after loading the view, typically from a nib.
    //[self createGame];
}

- (void)HandlerTapGesture:(UITapGestureRecognizer *)tab {
    if (_nextTurn) {
        PuzzleView *currentView = (PuzzleView *)tab.view;
        BOOL checkCard = NO;
        if (_isFirstChose) {
            _firstChose = currentView;
            _isFirstChose = NO;
        } else {
            if (_firstChose.value != currentView.value) {
                _secondChose = currentView;
                _isFirstChose = YES;
                checkCard = YES;
                _nextTurn = NO;
            }
        }
        UIImage *img = [_arrImage objectAtIndex:currentView.value];
        [currentView setImage:img];
        //Flip effect
        [UIView transitionWithView:currentView duration:0.2 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        } completion:^(BOOL finished) {
            if (checkCard) {
                [self checkCard];
            }
        }];
    }
}

- (void)checkCard {
    NSNumber *value1 = [_arrValue objectAtIndex:_firstChose.value];
    NSNumber *value2 = [_arrValue objectAtIndex:_secondChose.value];
    if (value1.intValue == value2.intValue) {
        [self correctSound];
        if(_isCombo){
            _comboNumber ++;
            self.comboLabel.text=[NSString stringWithFormat:@"Combo : %d",_comboNumber];
        }
        _isCombo = YES;
        [UIView animateWithDuration:0.5 animations:^{
            //CGRect g=
            _firstChose.imageView.alpha = 0;
            _secondChose.imageView.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                [_firstChose removeFromSuperview];
                [_secondChose removeFromSuperview];
                _nextTurn = YES;
                [self checkYouWin];
            }
        }];
    } else {
        [self wrongSound];
        _isCombo=NO;
        [_firstChose shakeImage];
        [_secondChose shakeImage];
        [UIView animateWithDuration:0.5 animations:^{
            _firstChose.imageView.alpha = 0.5;
            _secondChose.imageView.alpha = 0.5;
        } completion:^(BOOL finished) {
            if (finished) {
                [_firstChose setImage:[UIImage imageNamed:@"icon.png"]];
                _firstChose.imageView.alpha = 1;
                [_secondChose setImage:[UIImage imageNamed:@"icon.png"]];
                _secondChose.imageView.alpha = 1;
                _nextTurn = YES;
            }
        }];
    }
    _turnNumber++;

    self.turnNumberLabel.text = [NSString stringWithFormat:@"Turn number : %d", _turnNumber];
}

- (void)createGame {
    _isCombo =NO;
    _isFirstChose = YES;
    _timeOut = TIME_OUT;
    self.timeProgress.progress = 1.0;
    _turnNumber = 0;
    _comboNumber = 0;
    _nextTurn = YES;
    _stateLabel.hidden = YES;
    if (_winnerView!=nil) {
        [_winnerView removeFromSuperview];
        _winnerView = nil;
        _backgroundSound.volume = 1;
    }
    //Remove All PuzzleView
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[PuzzleView class]]) {
            [v removeFromSuperview];
        }
    }
    button.hidden = YES;
    _arrImage = [[NSMutableArray alloc]init];
    _arrValue = [[NSMutableArray alloc]init];
    _firstChose = [[PuzzleView alloc]init];
    _secondChose = [[PuzzleView alloc]init];
    //Create state label
    _stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 150, 280, 130)];
    [_stateLabel setTextAlignment:NSTextAlignmentCenter];
    [_stateLabel setBackgroundColor:[UIColor clearColor]];
    [_stateLabel setFont:[UIFont systemFontOfSize:63]];
    _stateLabel.textColor = [UIColor redColor];
    [self.view addSubview:_stateLabel];
    //Load random image
    //Create array value with -1;
    for (int i = 0; i < NUMBER_PUZZLE; i++) {
        [_arrValue addObject:[NSNumber numberWithInt:-1]];
        [_arrImage addObject:[NSNumber numberWithInt:-1]];
    }
    for (int i = 0; i < NUMBER_IMAGE; i++) {
        int index = 0;
        while (YES) {
            int ra = arc4random() % NUMBER_PUZZLE;
            NSNumber *value = [_arrValue objectAtIndex:ra];
            if (value.intValue == -1) {
                _arrValue[ra] = [NSNumber numberWithInt:i];
                _arrImage[ra] = [UIImage imageNamed:[_arrImageName objectAtIndex:i]];
                index++;
                if (index == NUMBER_PUZZLE / NUMBER_IMAGE) {
                    break;
                }
            }
        }
    }    //Load board
    int tabIndex = 0;
    for (int i = 0; i < NUMBER_ROW; i++) {
        for (int y = 0; y < NUMBER_COLUMN; y++) {
            PuzzleView *view = [[PuzzleView alloc]initWithFrame:CGRectMake(y * PUZZLE_WIDTH + (15 * (y + 1)), i * PUZZLE_HEIGHT + (10 * (i + 1)) + 80, PUZZLE_WIDTH, PUZZLE_HEIGHT)];
            [view setBackgroundColor:[UIColor clearColor]];
            _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(HandlerTapGesture:)];
            [view addGestureRecognizer:_tapGesture];
            view.value = tabIndex++;
            [self.view addSubview:view];
        }
    }

    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(GetTimeOut) userInfo:nil repeats:YES];
}

- (void)GetTimeOut {
    _timeOut--;
    self.timeLabel.text = [NSString stringWithFormat:@"00:%02.0f", _timeOut];
    [self.timeProgress setProgress:(_timeOut / TIME_OUT) animated:YES];
    if (_timeOut < 1) {
        [_timer invalidate];
        _timer = nil;
        //You lose
        _nextTurn = NO;
        [self youLose];
    }
}

- (void)checkYouWin {
    BOOL isWin = YES;
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[PuzzleView class]]) {
            isWin = NO;
        }
    }
    if (isWin) {
        _backgroundSound.volume = 0;
        [self winSound];
        [_timer invalidate];
        _timer = nil;
        [button setTitle:@"Replay" forState:UIControlStateNormal];
        //button.titleLabel.frame.size.width = 100;
        button.hidden = NO;

        _stateLabel.text = @"You win";
        _stateLabel.transform = CGAffineTransformScale(_stateLabel.transform, 0.25, 0.25);
        _stateLabel.textColor = [UIColor yellowColor];
        _stateLabel.hidden = NO;
        //[self.view addSubview:_stateLabel];
        [UIView animateWithDuration:1 animations:^{
            //_stateLabel.font =[UIFont systemFontOfSize:63];
            _stateLabel.transform = CGAffineTransformScale(_stateLabel.transform, 5, 5);
        }];
        _winnerView = [[WinnerView alloc]initWithFrame:self.view.frame];
        [self.view addSubview:_winnerView];
    }
}

- (void)youLose {
    [self loseSound];
    //Remove All PuzzleView
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[PuzzleView class]]) {
            [v removeFromSuperview];
        }
    }
    [button setTitle:@"Replay" forState:UIControlStateNormal];
    //button.titleLabel.frame.size.width = 100;
    button.hidden = NO;

    _stateLabel.text = @"You lose";
    _stateLabel.transform = CGAffineTransformScale(_stateLabel.transform, 0.25, 0.25);
    _stateLabel.hidden = NO;
    //[self.view addSubview:_stateLabel];
    [UIView animateWithDuration:1 animations:^{
        //_stateLabel.font =[UIFont systemFontOfSize:63];
        _stateLabel.transform = CGAffineTransformScale(_stateLabel.transform, 5, 5);
    }];
}

- (IBAction)ReplayGame:(id)sender {
    [self createGame];
}

- (void)startGameSound {
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/background.mp3", [[NSBundle mainBundle] resourcePath]]];
    NSError *error;
    _backgroundSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    _backgroundSound.numberOfLoops = -1;
    _backgroundSound.volume = 1;
    [_backgroundSound play];
}

- (void)correctSound {
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/correct.mp3", [[NSBundle mainBundle] resourcePath]]];
    [self playASound:url];
}

- (void)wrongSound {
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/wrong.mp3", [[NSBundle mainBundle] resourcePath]]];
    [self playASound:url];
}

- (void)winSound {
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/win.mp3", [[NSBundle mainBundle] resourcePath]]];
    [self playASound:url];
}

- (void)loseSound {
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/lose.mp3", [[NSBundle mainBundle] resourcePath]]];
    [self playASound:url];
}

- (void)playASound:(NSURL *)url {
    NSError *error;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    _audioPlayer.numberOfLoops = 0;
    _audioPlayer.volume = 1;
    [_audioPlayer play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
