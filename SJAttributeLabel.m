//
//  SJAttributeLabel.m
//  SJAttributeLabel
//
//  Created by fushijian on 14/11/5.
//
//

#import "SJAttributeLabel.h"


@interface SJAttributeLabel()

@property(nonatomic,retain) UIFont *font;
@property(nonatomic,retain) NSMutableArray *arrOfDict;
@property(nonatomic,retain) NSMutableArray *ranges;
@property(nonatomic,assign) UILineBreakMode lineBreakMode;

@end

@implementation SJAttributeLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.alignment = SJAlignmentCenter;
        self.fontSize = 15;
        self.textColor = [UIColor blackColor];
        self.backgroundColor = [UIColor clearColor];
        self.lineBreakMode = UILineBreakModeTailTruncation;
        
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    for (int i = 0; i < self.ranges.count; i++) {
        
        NSRange range = [[self.ranges objectAtIndex:i] rangeValue];
        NSDictionary *dict = [self.arrOfDict objectAtIndex:i];
        [self setAttributes:dict range:range];
    }
}

-(void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    NSString *drawStr = [self.text substringWithRange:range];
    for (NSString *key in attrs.allKeys) {
        
        if ([key isEqualToString:(NSString*)kAttributeTextColor]) {
            
            UIColor *color = [attrs objectForKey:key];
            [color set];
            //            CGPoint startPoint = [self getStartPointWithRange:range];
            //            [drawStr drawAtPoint:startPoint withFont:self.font];
            
            CGRect drawRect = [self getDrawRectWithRange:range];
            [drawStr drawAtPoint:drawRect.origin forWidth:drawRect.size.width withFont:self.font lineBreakMode:self.lineBreakMode];
            
        }
    }
}


-(void)addAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    
    if(self.ranges.count == 0){
        [self.arrOfDict addObject:attrs];
        [self.ranges addObject:[NSValue valueWithRange:range]];
        return;
    }
    
    BOOL finded = NO;
    NSInteger insertIndex = 0;
    for (int i = 0; i < self.ranges.count; i++) {
        
        NSRange tempRange = [[self.ranges objectAtIndex:i] rangeValue];
        NSRange insertRange =  NSIntersectionRange(tempRange,range);
        NSAssert(insertRange.length == 0, @"NSRange不允许重叠");//false触发
        
        if (NSMaxRange(range) <= tempRange.location) {
            
            if (!finded) {
                finded = YES;
                insertIndex = i;
            }
        }
    }
    
    if (finded) {
        [self.ranges insertObject:[NSValue valueWithRange:range] atIndex:insertIndex];
        [self.arrOfDict insertObject:attrs atIndex:insertIndex];
    }else{
        [self.ranges addObject:[NSValue valueWithRange:range]];
        [self.arrOfDict addObject:attrs];
    }
    
}

//获取每段文本绘制区域

-(CGRect)getDrawRectWithRange:(NSRange)range
{
    CGRect drawRect = [self getWholeTextDrawRect];
    
    NSString *beforeDrawStr = [self.text substringToIndex:range.location];
    CGSize beforeDrawSize = [beforeDrawStr sizeWithFont:self.font constrainedToSize:drawRect.size lineBreakMode:self.lineBreakMode];
    
    if (beforeDrawSize.width >= drawRect.size.width) {
        
        return CGRectZero;
    }
    
    NSString *wantDrawStr = [self.text substringWithRange:range];
    CGSize wantDrawsize = [wantDrawStr sizeWithFont:self.font constrainedToSize:drawRect.size lineBreakMode:self.lineBreakMode];
    
    CGPoint startDrawPoint = CGPointMake(drawRect.origin.x + beforeDrawSize.width, drawRect.origin.y);
    CGSize size = wantDrawsize;
    if (beforeDrawSize.width + wantDrawsize.width  + drawRect.origin.x > self.bounds.size.width) {
        
        size = CGSizeMake(drawRect.size.width - beforeDrawSize.width,drawRect.size.height);
    }
    
    return (CGRect){startDrawPoint,size};
    
    
}


-(CGPoint)getStartPointWithRange:(NSRange)range
{
    CGRect drawRect = [self getWholeTextDrawRect];
    NSString *tempStr = nil;
    if (range.location > 0 && range.location != NSNotFound) {
        tempStr = [self.text substringWithRange:NSMakeRange(0, range.location)];
        CGSize size = [tempStr sizeWithFont:self.font constrainedToSize:self.frame.size lineBreakMode:self.lineBreakMode];
        return CGPointMake(CGRectGetMinX(drawRect) + size.width, CGRectGetMinY(drawRect));
        
    }else{
        return CGPointMake(CGRectGetMinX(drawRect), CGRectGetMinY(drawRect));
    }
}

-(CGRect) getWholeTextDrawRect
{
    CGSize constrainedSize = [[UIScreen mainScreen] bounds].size;
    CGSize drawSize = [self.text sizeWithFont:self.font constrainedToSize:constrainedSize lineBreakMode:self.lineBreakMode];
    CGPoint center = {CGRectGetWidth(self.frame) / 2,CGRectGetHeight(self.frame)/2};
    CGRect rect = CGRectZero;
    
    
    if (drawSize.width >CGRectGetWidth(self.frame)) {
        
        CGFloat startY = center.y - drawSize.height / 2;
        rect = (CGRect){0,startY,self.frame.size.width,drawSize.height};
        return rect;
    }
    
    if (self.alignment == SJAlignmentLeft) {
        
        CGFloat startY = center.y - drawSize.height / 2;
        rect = (CGRect){0,startY,drawSize};
        
    }else if(self.alignment == SJAlignmentCenter){
        
        CGFloat startX = center.x - drawSize.width / 2;
        CGFloat startY = center.y - drawSize.height / 2;
        rect = (CGRect){startX,startY,drawSize};
        
    }else if(self.alignment == SJAlignmentRight){
        
        CGFloat startX = CGRectGetWidth(self.frame) - drawSize.width;
        CGFloat startY = center.y - drawSize.height / 2;
        rect = (CGRect){startX,startY,drawSize};
    }
    
    return rect;
}


-(void)willMoveToSuperview:(UIView *)newSuperview
{
    
    if (newSuperview) {
        
        if (self.ranges.count == 0) {
            
            NSRange range = NSMakeRange(0, self.text.length);
            NSDictionary *dict = @{kAttributeTextColor:self.textColor};
            
            [self.ranges addObject:[NSValue valueWithRange:range]];
            [self.arrOfDict addObject:dict];
            [self setNeedsDisplay];
            return;
        }
        
        NSMutableArray *newRanges = [[NSMutableArray alloc] init];
        NSMutableArray *newArrOfDict = [[NSMutableArray alloc] init];
        
        NSRange tempRange;
        NSDictionary *tempDict;
        NSInteger location = 0;
        for (int i = 0; i < self.ranges.count; i++) {
            
            tempRange = [[self.ranges objectAtIndex:i] rangeValue];
            tempDict = [self.arrOfDict objectAtIndex:i];
            
            if (location < tempRange.location) {
                NSRange range = NSMakeRange(location, tempRange.location - location);
                [newRanges addObject:[NSValue valueWithRange:range]];
                NSDictionary *dict = @{kAttributeTextColor:self.textColor};
                [newArrOfDict addObject:dict];
                
            }
            [newRanges addObject:[NSValue valueWithRange:tempRange]];
            [newArrOfDict addObject:tempDict];
            location = NSMaxRange(tempRange);
            
        }
        
        if (location != self.text.length) {
            NSRange range = NSMakeRange(location, self.text.length - location);
            [newRanges addObject:[NSValue valueWithRange:range]];
            NSDictionary *dict = @{kAttributeTextColor:self.textColor};
            [newArrOfDict addObject:dict];
        }
        
        self.ranges = newRanges;
        self.arrOfDict = newArrOfDict;
        [self setNeedsDisplay];
        
        
        
    }
    
    
}


#pragma mark -GETTER
-(NSMutableArray *)arrOfDict
{
    if (!_arrOfDict) {
        _arrOfDict = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return _arrOfDict;
}

-(NSMutableArray *)ranges
{
    if (!_ranges) {
        _ranges = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return _ranges;
}


-(void)setFontSize:(CGFloat )fontSize
{
    if (_fontSize != fontSize) {
        
        _fontSize = fontSize;
        self.font = [UIFont systemFontOfSize:_fontSize];
    }
}


@end
