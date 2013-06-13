//
//  ViewController.m
//  KeyBoardDemo
//
//  Created by space on 13-6-9.
//  Copyright (c) 2013年 space. All rights reserved.
//

#import "ViewController.h"
#import "InnerShadowTextView.h"

#define UISCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define UISCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define COMMON_INPUT_AREA @"文字输入框@2x"
#define HEIGHT_COMMENT_BAR 50.0


@interface ViewController ()<UITextViewDelegate>
{
    NSString* ipAddress;
    NSString* blogContent;
    NSString* blogTitle;
    UIView* commentView;
    UIView* backView;
    InnerShadowTextView* commentTextView;
    UIView* blackView;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addKeyboardView];
}

//增加键盘上面的view
-(void)addKeyboardView
{
    //总的大view
    backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, UISCREEN_HEIGHT  - 20)];
    
    //背景黑色
    blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, backView.frame.size.height - HEIGHT_COMMENT_BAR)];
    blackView.backgroundColor = [UIColor blackColor];
    blackView.alpha = 0.4;
    blackView.hidden = YES;
    [backView addSubview:blackView];
    
    
    //总的评论view
    commentView = [[UIView alloc] initWithFrame:CGRectMake(0, blackView.frame.size.height, UISCREEN_WIDTH, HEIGHT_COMMENT_BAR)];
    
    UIImage* image = [[UIImage imageNamed:COMMON_INPUT_AREA] stretchableImageWithLeftCapWidth:0 topCapHeight:2];
    
    [commentView setBackgroundColor:[UIColor colorWithPatternImage:image]];
    
    //评论view里面的textView
    commentTextView = [[InnerShadowTextView alloc] initWithFrame:CGRectMake(9, 9, UISCREEN_WIDTH - 18, 32)];
    
    commentTextView.font = [UIFont systemFontOfSize:14];
    
    commentTextView.delegate = self;
    
    commentTextView.placeholder = @"发表评论";
    
    commentTextView.returnKeyType = UIReturnKeySend;
    
    [commentView addSubview:commentTextView];
    
    [backView addSubview:commentView];
    
    //关闭键盘事件
    UITapGestureRecognizer *followedTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyBoard)];
    
    [blackView addGestureRecognizer:followedTap];
    
    
    [self.view addSubview:backView];
    backView.hidden = YES;
    
    //弹出键盘的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeContentViewPoint:) name:UIKeyboardWillShowNotification object:nil];
}
-(void)closeKeyBoard
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appearContentViewPoint:) name:UIKeyboardWillHideNotification object:nil];
    [commentTextView resignFirstResponder];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:UIKeyboardWillHideNotification object:nil];
    
}
//键盘消失的时候
- (void)appearContentViewPoint:(NSNotification *)notification
{
    NSDictionary *keyboardInfo = [notification userInfo];
    
    NSNumber *duration = [keyboardInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [keyboardInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];

    blackView.hidden = YES;
    // 添加移动动画，使视图跟随键盘移动
    [UIView animateWithDuration:duration.doubleValue animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        backView.center = CGPointMake(backView.frame.size.width / 2, backView.frame.size.height / 2);
    }];
    backView.hidden = YES;
    
}

//弹出键盘的时候
- (void)changeContentViewPoint:(NSNotification *)notification
{
    NSDictionary *keyboardInfo = [notification userInfo];
    NSValue *value = [keyboardInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardEndY = value.CGRectValue.origin.y;  // 得到键盘弹出后的键盘视图所在y坐标
    
    NSNumber *duration = [keyboardInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [keyboardInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];

    backView.hidden= NO;
    // 添加移动动画，使视图跟随键盘移动
    [UIView animateWithDuration:duration.doubleValue animations:^{
        
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        
        backView.center = CGPointMake(backView.frame.size.width / 2 , keyBoardEndY - backView.frame.size.height - 20 + backView.frame.size.height / 2);
        
        
    }];
    blackView.hidden = NO;
    
}


#pragma mark - UITextView Delegate Methods

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text

{
    
    if ([text isEqualToString:@"\n"])
    {
        NSLog(@"Send Data");
        return NO;
        
    }
    
    return YES;
    
}

- (IBAction)buttonPressed:(id)sender
{
    commentTextView.text = nil;
    [commentTextView becomeFirstResponder ];
}
@end
