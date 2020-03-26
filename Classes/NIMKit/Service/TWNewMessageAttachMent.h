//
//  TWNewMessageAttachMent.h
//  TaiWuWang
//
//  Created by 田黎强 on 2020/2/19.
//  Copyright © 2020 zsf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface TWNewMessageAttachMent : NSObject<NIMCustomAttachment>
@property(nonatomic,assign)int type;
@property(nonatomic,strong)NSDictionary *messageDic;//数据源承接类
@end

NS_ASSUME_NONNULL_END
