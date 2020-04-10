//
//  TWNewMessageAttachMentDecoder.m
//  TaiWuWang
//
//  Created by 田黎强 on 2020/2/19.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "TWNewMessageAttachMentDecoder.h"
#import "TWNewMessageAttachMent.h"

@implementation TWNewMessageAttachMentDecoder

- (id<NIMCustomAttachment>)decodeAttachment:(NSString *)content{
    //所有的自定义消息都会走这个解码方法，如有多种自定义消息请自行做好类型判断和版本兼容。这里仅演示最简单的情况。
    id<NIMCustomAttachment> attachment;
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            int type = [dict[@"type"] intValue];
            NSDictionary *messageDic = dict[@"data"];
            
            TWNewMessageAttachMent *myAttachment = [[TWNewMessageAttachMent alloc] init];
//            myAttachment.headerImage = headerImage;
//            myAttachment.price = price;
            myAttachment.type =type;
            myAttachment.messageDic =messageDic;
            attachment = myAttachment;
        }
    }
    return attachment;
}
-(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end
