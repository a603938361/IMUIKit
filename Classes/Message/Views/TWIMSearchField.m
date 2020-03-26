//
//  TWIMSearchField.m
//  TaiWuWang
//
//  Created by 田黎强 on 2020/3/13.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "TWIMSearchField.h"
#import "UIView+Frame.h"

@implementation TWIMSearchField
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kRGB(246, 246, 246);
        self.font = kFont(14);
        self.textColor = kRGB(51, 51, 51);
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"搜索" attributes:@{NSForegroundColorAttributeName:kRGB(172, 182, 196),NSFontAttributeName:kFont(14)}];
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, self.height)];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 19, 19)];
        imgView.image = [UIImage imageNamed:@"icon_search2"];
        [leftView addSubview:imgView];
        
        self.leftView = leftView;
        self.leftViewMode = UITextFieldViewModeAlways;
        
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
