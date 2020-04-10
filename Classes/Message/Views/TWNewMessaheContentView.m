//
//  TWNewMessaheContentView.m
//  TaiWuWang
//
//  Created by 田黎强 on 2020/2/19.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "TWNewMessaheContentView.h"
#import "TWNewMessageAttachMent.h"
#import "UIView+NIM.h"
@interface TWNewMessaheContentView ()
@property(nonatomic,assign)int type;
@end
@implementation TWNewMessaheContentView
-(instancetype)initSessionMessageContentView{
    self = [super initSessionMessageContentView];
    if (self) {
    
        _bgView = [UIView new];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 8.0;
        _bgView.clipsToBounds = YES;
        [_bgView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTouchUpInside:)]];
        [self addSubview:_bgView];
        
        _houseImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _houseImageView.contentMode = UIViewContentModeScaleAspectFill;
        _houseImageView.clipsToBounds = YES;
        [_bgView  addSubview:_houseImageView];
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        [_bgView addSubview:_titleLabel];
        
        _subTitileLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _subTitileLabel.textColor = kRGB(153,153,153);
        _subTitileLabel.font = [UIFont systemFontOfSize:12];
        [_bgView addSubview:_subTitileLabel];
        
        _priceLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _priceLabel.font = [UIFont systemFontOfSize:14];
        _priceLabel.textColor = kRGB(247, 44, 44);
        _priceLabel.textAlignment = NSTextAlignmentRight;
        [_bgView addSubview:_priceLabel];
        
       
    }
    return self;
}

//赋值
-(void)refresh:(NIMMessageModel *)data{
    [super refresh:data];
    NIMCustomObject *object = (NIMCustomObject*)data.message.messageObject;
    TWNewMessageAttachMent *attachment = (TWNewMessageAttachMent*)object.attachment;
    _type = [attachment.messageDic[@"type"] intValue];
    //这里判断是啥类类型
    
    NSString *imageUrl = attachment.messageDic[@"imageUrl"];
    imageUrl = [imageUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.houseImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"message_house_bj"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
    }];
    //1租2售
    if (_type == 2) {
    
        self.priceLabel.text =  [NSString stringWithFormat:@"%@万",attachment.messageDic[@"price"]];
             self.subTitileLabel.text =attachment.messageDic[@"estateAreaName"];

               self.subTitileLabel.textColor = kRGB(51, 51, 51);
               self.subTitileLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.text = @"";

    }else{
        self.priceLabel.text = [NSString stringWithFormat:@"%@元",attachment.messageDic[@"price"]];
              self.titleLabel.text = attachment.messageDic[@"estateAreaName"];

              self.subTitileLabel.text = [NSString stringWithFormat:@"%@室%@厅%@卫 | %@m²",attachment.messageDic[@"roomNum"],attachment.messageDic[@"hallNum"],attachment.messageDic[@"toiletNum"],attachment.messageDic[@"propertySquare"]];
              self.subTitileLabel.textColor = kRGB(153, 153, 153);
              self.subTitileLabel.font = [UIFont systemFontOfSize:12];
    }
    
    
    [_houseImageView sizeToFit];
    [_priceLabel sizeToFit];
    [_titleLabel sizeToFit];
    [_subTitileLabel sizeToFit];
    [self layoutSubviews];
}

-(void)layoutSubviews{
    [super layoutSubviews];
//    [self.houseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.equalTo(self);
//        make.height.equalTo(@148);
//    }];

    _bgView.frame =CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.houseImageView.frame= CGRectMake(0, 0, self.frame.size.width, 148);

    //1租2售
    if (_type== 2) {
        self.subTitileLabel.nim_top = self.houseImageView.nim_bottom+12;
        self.subTitileLabel.nim_left = 25;
        self.subTitileLabel.nim_size = CGSizeMake(_bgView.nim_width-25-23-5-self.priceLabel.nim_width, 20);
        
        self.priceLabel.nim_right = _bgView.nim_right -23;
        self.priceLabel.nim_top = self.subTitileLabel.nim_top;
        self.priceLabel.nim_size = CGSizeMake(self.priceLabel.nim_size.width, 20);
        
    }else{
       self.titleLabel.nim_top =self.houseImageView.nim_bottom+12;
        self.titleLabel.nim_left = 25;
        self.subTitileLabel.nim_size = CGSizeMake(_bgView.nim_width-25-23, 20);
        
        
        self.subTitileLabel.nim_top = self.titleLabel.nim_bottom+4;
        self.subTitileLabel.nim_left = 25;
        self.subTitileLabel.nim_size = CGSizeMake(_bgView.nim_width-25-23-5-self.priceLabel.nim_width, 20);
              
        self.priceLabel.nim_right = _bgView.nim_right -23;
        self.priceLabel.nim_top = self.subTitileLabel.nim_top;
        self.priceLabel.nim_size = CGSizeMake(self.priceLabel.nim_size.width, 20);

    }
    
}


- (void)onTouchUpInside:(id)sender
{
    NIMKitEvent *event = [[NIMKitEvent alloc] init];
    event.eventName = NIMKitEventNameTapContent;
    event.messageModel = self.model;
    [self.delegate onCatchEvent:event];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
