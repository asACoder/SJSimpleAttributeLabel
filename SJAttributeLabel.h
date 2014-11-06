//
//  SJAttributeLabel.h
//  SJAttributeLabel
//
//  Created by fushijian on 14/11/5.
//
//

#import <UIKit/UIKit.h>


typedef enum {
    SJAlignmentLeft = 0,
    SJAlignmentCenter,
    SJAlignmentRight
}SJAlignment;

// 只在以下情况下使用该控件：（在sdk低于7.0使用，7.0及以上使用NSAttributedString）
// 对它的使用有点像NSAttributedString
// NSLineBreakMode 只支持 NSLineBreakByTruncatingTail
/**
 使用：
 对AttributeLabel的所有属性必须在 addSubView: 之前设置（包括 addAttributes: range:）
 
 */

@interface SJAttributeLabel : UIView

static const NSString *kAttributeTextColor = @"kAttributeTextColor";

@interface AttributeLabel : UIView

@property(nonatomic,retain) NSString *text;
@property(nonatomic,assign) CGFloat fontSize;
@property(nonatomic,assign) SJAlignment alignment;
@property(nonatomic,retain) UIColor *textColor;

- (void)addAttributes:(NSDictionary *)attrs range:(NSRange)range;


@end
