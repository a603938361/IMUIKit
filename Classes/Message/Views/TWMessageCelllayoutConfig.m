//
//  TWMessageCelllayoutConfig.m
//  TaiWuWang
//
//  Created by 田黎强 on 2020/2/19.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "TWMessageCelllayoutConfig.h"
#import "TWNewMessageAttachMent.h"
@interface TWMessageCelllayoutConfig ()


@property (nonatomic,strong)   NSArray    *types;



@end

@implementation TWMessageCelllayoutConfig

-(instancetype)init{
    if (self =[super init]) {
        _types = @[
            @"TWNewMessageAttachMent"
        ];
    }
    return self;
}
#pragma mark - NIMCellLayoutConfig


-(CGSize)contentSize:(NIMMessageModel *)model cellWidth:(CGFloat)width{
//    if ([self isSupportedCustomModel:model]) {
//        <#statements#>
//    }
    NIMMessage *message = model.message;
    if ([self isSupportedCustomMessage:model.message]) {
        NIMCustomObject *object = message.messageObject;
        TWNewMessageAttachMent *attachment = object.attachment;
        int Type =[attachment.messageDic[@"type"] intValue];
        if([attachment.messageDic[@"type"] intValue] == 2){
              return CGSizeMake(263, 175);
        }else{
            return CGSizeMake(263, 200);
        }
       
    }
    return [super contentSize:model cellWidth:width];
}

-(NSString *)cellContent:(NIMMessageModel *)model{
    if ([self isSupportedCustomMessage:model.message]) {
          //先判断是否是需要处理的自定义消息
          return @"TWNewMessaheContentView";
    }
       
      return [super cellContent:model];
}

-(BOOL)shouldShowAvatar:(NIMMessageModel *)model{
    return  [super shouldShowAvatar:model];
//    return YES;
}

- (UIEdgeInsets)cellInsets:(NIMMessageModel *)model{
    //填入气泡距cell的边距,选填
    if ([self isSupportedCustomMessage:model.message]) {
       //先判断是否是需要处理的自定义消息
           return [super cellInsets:model];

    }
    //如果不是自己定义的消息，就走内置处理流程
    return [super cellInsets:model];
}
//- (CGPoint)avatarMargin:(NIMMessageModel *)model{
//    return CGPointMake(50, 50);
//}



-(BOOL)isSupportedCustomMessage:(NIMMessage *)message{
    NIMCustomObject *object = message.messageObject;
     return [object isKindOfClass:[NIMCustomObject class]] &&[_types indexOfObject:NSStringFromClass([object.attachment class])] != NSNotFound;
}
@end
