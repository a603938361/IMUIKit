//
//  TWNewMessageAttachMent.m
//  TaiWuWang
//
//  Created by 田黎强 on 2020/2/19.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "TWNewMessageAttachMent.h"

@implementation TWNewMessageAttachMent
- (NSString *)encodeAttachment
{
    NSDictionary *dict = @{
        @"data" :_messageDic,
        @"type":@(_type)
                          
        };
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:0
                                                     error:nil];
    NSString *content = nil;
    if (data) {
        content = [[NSString alloc] initWithData:data
                                        encoding:NSUTF8StringEncoding];
    }
    return content;
}
@end
