//
//  CallViewController.m
//  ChatDemo-UI2.0
//
//  Created by dhcdht on 14-9-24.
//  Copyright (c) 2014年 dhcdht. All rights reserved.
//

#import "CallViewController.h"

static CallViewController *shareController = nil;

@interface CallViewController ()
{
    NSString *_chatter;
    
    CommunicationStatus _status;
    
    UIImageView *_bgImageView;
    UILabel *_statusLabel;
    UIImageView *_headerImageView;
    UILabel *_nameLabel;
    
    UIButton *_silenceButton;
    UILabel *_silenceLabel;
    UIButton *_speakerOutButton;
    UILabel *_outLabel;
    UIButton *_hangupButton;
    UIButton *_answerButton;
}

@property (nonatomic) CommunicationStatus status;

@end

@implementation CallViewController

+ (instancetype)shareController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareController = [[self alloc] initWithNibName:nil bundle:nil];
    });
    
    return shareController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _status = CommunicationStatusNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height)];
    _bgImageView.contentMode = UIViewContentModeScaleToFill;
    _bgImageView.image = [UIImage imageNamed:@"callBg.png"];
    [self.view addSubview:_bgImageView];
    
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    _statusLabel.font = [UIFont systemFontOfSize:15.0];
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.textColor = [UIColor whiteColor];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_statusLabel];
    
    _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 50) / 2, CGRectGetMaxY(_statusLabel.frame) + 20, 50, 50)];
    _headerImageView.image = [UIImage imageNamed:@"chatListCellHead"];
    [self.view addSubview:_headerImageView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerImageView.frame) + 5, self.view.frame.size.width, 20)];
    _nameLabel.font = [UIFont systemFontOfSize:14.0];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_nameLabel];
    
    CGFloat tmpWidth = self.view.frame.size.width / 2;
    _silenceButton = [[UIButton alloc] initWithFrame:CGRectMake((tmpWidth - 40) / 2, self.view.frame.size.height - 230, 40, 40)];
    [_silenceButton setImage:[UIImage imageNamed:@"call_silence"] forState:UIControlStateNormal];
    [_silenceButton setImage:[UIImage imageNamed:@"call_silence_h"] forState:UIControlStateSelected];
    [_silenceButton addTarget:self action:@selector(silenceAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_silenceButton];
    
    _silenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_silenceButton.frame), CGRectGetMaxY(_silenceButton.frame) + 5, 40, 20)];
    _silenceLabel.textColor = [UIColor whiteColor];
    _silenceLabel.font = [UIFont systemFontOfSize:13.0];
    _silenceLabel.textAlignment = NSTextAlignmentCenter;
    _silenceLabel.text = @"静音";
    [self.view addSubview:_silenceLabel];
    
    _speakerOutButton = [[UIButton alloc] initWithFrame:CGRectMake(tmpWidth + (tmpWidth - 40) / 2, self.view.frame.size.height - 230, 40, 40)];
    [_speakerOutButton setImage:[UIImage imageNamed:@"call_out"] forState:UIControlStateNormal];
    [_speakerOutButton setImage:[UIImage imageNamed:@"call_out_h"] forState:UIControlStateSelected];
    [_speakerOutButton addTarget:self action:@selector(speakerOutAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_speakerOutButton];
    
    _outLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_speakerOutButton.frame), CGRectGetMaxY(_speakerOutButton.frame) + 5, 40, 20)];
    _outLabel.textColor = [UIColor whiteColor];
    _outLabel.font = [UIFont systemFontOfSize:13.0];
    _outLabel.textAlignment = NSTextAlignmentCenter;
    _outLabel.text = @"免提";
    [self.view addSubview:_outLabel];
    
    _hangupButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200) / 2, self.view.frame.size.height - 120, 200, 40)];
    [_hangupButton setTitle:@"挂断" forState:UIControlStateNormal];
    [_hangupButton setBackgroundColor:[UIColor colorWithRed:191 / 255.0 green:48 / 255.0 blue:49 / 255.0 alpha:1.0]];;
    [_hangupButton addTarget:self action:@selector(hangupAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_hangupButton];
    
    _answerButton = [[UIButton alloc] initWithFrame:CGRectMake(tmpWidth + (tmpWidth - 100) / 2, self.view.frame.size.height - 120, 100, 40)];
    [_answerButton setTitle:@"接听" forState:UIControlStateNormal];
    [_answerButton setBackgroundColor:[UIColor colorWithRed:191 / 255.0 green:48 / 255.0 blue:49 / 255.0 alpha:1.0]];;
    [_answerButton addTarget:self action:@selector(answerAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (void)setupSubviews
{
    switch (_status) {
        case CommunicationStatusCallOuting:
        {
            _statusLabel.text = @"正在建立连接...";
            _nameLabel.text = _chatter;
            
            [_answerButton removeFromSuperview];
            _hangupButton.frame = CGRectMake((self.view.frame.size.width - 200) / 2, self.view.frame.size.height - 120, 200, 40);
            _silenceButton.hidden = NO;
            _silenceLabel.hidden = NO;
            _speakerOutButton.hidden = NO;
            _outLabel.hidden = NO;
        }
            break;
        case CommunicationStatusCallIning:
        {
            _statusLabel.text = @"等待接听...";
            _nameLabel.text = _chatter;
            
            CGFloat tmpWidth = self.view.frame.size.width / 2;
            _hangupButton.frame = CGRectMake((tmpWidth - 100) / 2, self.view.frame.size.height - 120, 100, 40);
            [self.view addSubview:_answerButton];
            _silenceButton.hidden = YES;
            _silenceLabel.hidden = YES;
            _speakerOutButton.hidden = YES;
            _outLabel.hidden = YES;
        }
            break;
        case CommunicationStatusAnswering:
        {
            _statusLabel.text = @"正在通话";
            _nameLabel.text = _chatter;
            
            [_answerButton removeFromSuperview];
            _hangupButton.frame = CGRectMake((self.view.frame.size.width - 200) / 2, self.view.frame.size.height - 120, 200, 40);
            _silenceButton.hidden = NO;
            _silenceLabel.hidden = NO;
            _speakerOutButton.hidden = NO;
            _outLabel.hidden = NO;
        }
        case CommunicationStatusAnother:
        {
            
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - public

- (void)setupCallOutWithChatter:(NSString *)chatter
{
    if (_status == CommunicationStatusNone) {
        _status = CommunicationStatusCallOuting;
        _chatter = chatter;
        [self setupSubviews];
    }
}

- (void)setupCallInWithChatter:(NSString *)chatter
{
    switch (_status) {
        case CommunicationStatusNone:
        {
            _status = CommunicationStatusCallIning;
            _chatter = chatter;
        }
            break;
        case CommunicationStatusCallOuting:
        {
            
        }
            break;
        case CommunicationStatusCallIning:
        {
            
        }
            break;
        case CommunicationStatusAnswering:
        {
            
        }
        case CommunicationStatusAnother:
        {
            
        }
            break;
            
        default:
            break;
    }
    
    [self setupSubviews];
}

#pragma mark - action

- (void)silenceAction:(id)sender
{
    _silenceButton.selected = !_silenceButton.selected;
}

- (void)speakerOutAction:(id)sender
{
    _speakerOutButton.selected = !_speakerOutButton.selected;
}

- (void)hangupAction:(id)sender
{
    _status = CommunicationStatusNone;
    _chatter = @"";
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)answerAction:(id)sender
{
    _status = CommunicationStatusAnswering;
    [self setupSubviews];
}

@end
