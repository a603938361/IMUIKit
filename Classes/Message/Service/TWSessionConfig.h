//
//  TWSessionConfig.h
//  TaiWuWang
//
//  Created by 田黎强 on 2020/2/22.
//  Copyright © 2020 zsf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMSessionConfig;
@interface TWSessionConfig : NSObject<NIMSessionConfig>
@property (nonatomic,strong)    NIMSession *session;

@end

NS_ASSUME_NONNULL_END
