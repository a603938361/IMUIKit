//
//  TWSessionConfig.m
//  TaiWuWang
//
//  Created by 田黎强 on 2020/2/22.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "TWSessionConfig.h"

@implementation TWSessionConfig

//输入框类型
- (NSArray<NSNumber *> *)inputBarItemTypes{
    return @[
               @(NIMInputBarItemTypeTextAndRecord),
               @(NIMInputBarItemTypeEmoticon),
               @(NIMInputBarItemTypeMore)
            ];
}

- (NSArray<NIMMediaItem *> *)mediaItems{
   return [NIMKit sharedKit].config.defaultMediaItems;
}

//回读已执
- (BOOL)shouldHandleReceipt
{
    return YES;
}

- (BOOL)shouldHandleReceiptForMessage:(NIMMessage *)message{
       NIMMessageType type = message.messageType;
    return type == NIMMessageTypeText ||
      type == NIMMessageTypeAudio ||
      type == NIMMessageTypeImage ||
      type == NIMMessageTypeVideo ||
      type == NIMMessageTypeFile ||
      type == NIMMessageTypeLocation ||
      type == NIMMessageTypeCustom;

}


@end
