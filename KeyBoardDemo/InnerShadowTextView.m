//
//  InnerShadowTextView.m
//  lofter
//  @see http://stackoverflow.com/questions/4431292/inner-shadow-effect-on-uiview-layer
//  Created by 金武 占 on 12-4-24.
//  Copyright (c) 2012年 NetEase Inc. All rights reserved.
//

#import "InnerShadowTextView.h"

#define kTagForTableView 1001
#define MAXLENGTH 500//最多输入的字数

#define MINHEIGHT 32//输入框只有一行内容时的高度
#define MAXHEIGHT 86//允许输入框显示的最大高度

@implementation InnerShadowTextView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setPlaceholder:@"我想说"];
    [self setPlaceholderColor:[UIColor lightGrayColor]];
}

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
        [self setPlaceholder:@"我想说"];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
    }
    return self;
}


- (void)textChanged:(NSNotification *)notification {
    if([self.text length] > MAXLENGTH) {//limit the text length
        self.text = [self.text substringToIndex:MAXLENGTH];
    }
    [super textChanged:notification];
    CGRect textFrame = self.frame;
    CGRect superFrame = self.superview.frame;
    CGFloat lastHeight = textFrame.size.height;
    BOOL isEmpty = [self.text isEqualToString:@""];
    CGFloat newHeight = isEmpty ? MINHEIGHT : self.contentSize.height - 2;

    if(lastHeight == newHeight) return;
    if(newHeight > MAXHEIGHT) {
        newHeight = MAXHEIGHT;
        self.scrollEnabled = YES;
    } else {
        self.scrollEnabled = NO;
    }
    CGFloat delta = newHeight - lastHeight;
    
    if(delta == 0) return;
    superFrame.size.height += delta;
    superFrame.origin.y -= delta;
    textFrame.size.height += delta;
    [UIView animateWithDuration:0.1 animations:^{
        self.superview.frame = superFrame;
        self.frame = textFrame;
    }];
    
    
    UITableView *tableView = (UITableView *)[self.superview.superview viewWithTag:kTagForTableView];
    CGRect tableFrame = tableView.frame;
    tableFrame.size.height -= delta;
    tableView.frame = tableFrame;
}

/*****************
 * fixes the issue with single lined uitextview. Solution is from here:http://www.hanspinckaers.com/multi-line-uitextview-similar-to-sms
 ****************/
- (void) setContentInset:(UIEdgeInsets) s {
    UIEdgeInsets insets = s;
    if(s.bottom > 8) insets.bottom = 0;
    insets.top = 0;
    [super setContentInset:insets];
}

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGRect bounds = [self bounds];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat radius = 2;//0.5f * CGRectGetHeight(bounds);
    
    
    // Create the "visible" path, which will be the shape that gets the inner shadow
    // In this case it's just a rounded rect, but could be as complex as your want
    CGMutablePathRef visiblePath = CGPathCreateMutable();
    CGRect innerRect = CGRectInset(bounds, radius, radius);
    CGPathMoveToPoint(visiblePath, NULL, innerRect.origin.x, bounds.origin.y);
    CGPathAddLineToPoint(visiblePath, NULL, innerRect.origin.x + innerRect.size.width, bounds.origin.y);
    CGPathAddArcToPoint(visiblePath, NULL, bounds.origin.x + bounds.size.width, bounds.origin.y, bounds.origin.x + bounds.size.width, innerRect.origin.y, radius);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.origin.x + bounds.size.width, innerRect.origin.y + innerRect.size.height);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height, innerRect.origin.x + innerRect.size.width, bounds.origin.y + bounds.size.height, radius);
    CGPathAddLineToPoint(visiblePath, NULL, innerRect.origin.x, bounds.origin.y + bounds.size.height);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x, bounds.origin.y + bounds.size.height, bounds.origin.x, innerRect.origin.y + innerRect.size.height, radius);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.origin.x, innerRect.origin.y);
    CGPathAddArcToPoint(visiblePath, NULL,  bounds.origin.x, bounds.origin.y, innerRect.origin.x, bounds.origin.y, radius);
    CGPathCloseSubpath(visiblePath);
    
    // Fill this path
    UIColor *aColor = [UIColor whiteColor];
    [aColor setFill];
    CGContextAddPath(context, visiblePath);
    CGContextFillPath(context);
    
    
    // Now create a larger rectangle, which we're going to subtract the visible path from
    // and apply a shadow
    CGMutablePathRef path = CGPathCreateMutable();
    //(when drawing the shadow for a path whichs bounding box is not known pass "CGPathGetPathBoundingBox(visiblePath)" instead of "bounds" in the following line:)
    //-42 cuould just be any offset > 0
    CGPathAddRect(path, NULL, CGRectInset(bounds, -42, -42));
    
    // Add the visible path (so that it gets subtracted for the shadow)
    CGPathAddPath(path, NULL, visiblePath);
    CGPathCloseSubpath(path);
    
    // Add the visible paths as the clipping path to the context
    CGContextAddPath(context, visiblePath); 
    CGContextClip(context);         
    
    
    // Now setup the shadow properties on the context
    aColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(2.0f, 2.0f), 3.0f, [aColor CGColor]);   
    
    // Now fill the rectangle, so the shadow gets drawn
    [aColor setFill];   
    CGContextSaveGState(context);   
    CGContextAddPath(context, path);
    CGContextEOFillPath(context);
    
    // Release the paths
    CGPathRelease(path);    
    CGPathRelease(visiblePath);
    
}

@end