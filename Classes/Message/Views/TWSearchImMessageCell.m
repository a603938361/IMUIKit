//
//  TWSearchImMessageCell.m
//  TaiWuOffice
//
//  Created by 田黎强 on 2020/3/12.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "TWSearchImMessageCell.h"
#import "NIMKitUtil.h"

@implementation TWSearchImMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)dataForCell:(NIMSession *)session searchDic:(NSDictionary *)messagesDic searchStr:(NSString *)searchStr{
    [self.headImageView setAvatarBySession:session];
    self.nameLabel.text = [self nameForSession:session];
    NSArray *messageArr = messagesDic[session];
    if (messageArr.count > 1) {
        self.timeLabel.hidden = YES;
        self.messageLabel.text = [NSString stringWithFormat:@"%ld条相关聊天记录",messageArr.count];
    }else{
        self.timeLabel.hidden = NO;
        NIMMessage *message = messageArr[0];
        self.messageLabel.attributedText = [self showMessage:message.text searchString:searchStr];
        self.timeLabel.text =  [NIMKitUtil showTime:message.timestamp showDetail:NO];
        
    }
}

-(void)dataForCell:(NIMSession *)session message:(NIMMessage *)message searchStr:(NSString *)searchStr{
    [self.headImageView setAvatarBySession:session];
    self.nameLabel.text = [self nameForSession:session];
    self.messageLabel.attributedText = [self showMessage:message.text searchString:searchStr];
    self.timeLabel.text =  [NIMKitUtil showTime:message.timestamp showDetail:NO];

    
}


- (NSString *)nameForSession:(NIMSession *)session {
    if (session.sessionType == NIMSessionTypeP2P) {
        return [NIMKitUtil showNick:session.sessionId inSession:session];
    } else if (session.sessionType == NIMSessionTypeTeam) {
        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:session.sessionId];
        return team.teamName;
    } else if (session.sessionType == NIMSessionTypeSuperTeam) {
        NIMTeam *superTeam = [[NIMSDK sharedSDK].superTeamManager teamById:session.sessionId];
        return superTeam.teamName;
    } else {
        NSAssert(NO, @"");
        return nil;
    }
}

- (NSMutableAttributedString *)showMessage:(NSString *)message searchString:(NSString *)searchStr{
    
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] init];

    NSString *src = message;
    NSString *searchText = searchStr;
//    if ([self ignoreCase]) {
//        src = [src lowercaseString];
//        searchText = [searchText lowercaseString];
//    }
    NSRange local = [src rangeOfString:searchText];
    if (local.location != NSNotFound) {
        NSMutableAttributedString *show = [[NSMutableAttributedString alloc] initWithString:(message ?: @"null")];
        [show setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:local];
        [ret appendAttributedString:show];
    }
    return ret;
}
//
//- (BOOL)ignoreCase {
//    BOOL ret = YES;
//    return ret;
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
