//
//  TWLookMoreSomeOneMessageController.h
//  TaiWuWang
//
//  Created by 田黎强 on 2020/3/16.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "TWBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWLookMoreSomeOneMessageController : TWBaseViewController
@property(nonatomic,strong)NSMutableArray *chatDataArr;//聊天记录
@property(nonatomic,copy)NSString *searchStr;
@property(nonatomic,strong)NIMSession *session;
@end

NS_ASSUME_NONNULL_END
