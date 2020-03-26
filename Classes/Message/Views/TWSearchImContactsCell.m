//
//  TWSearchImContactsCell.m
//  TaiWuOffice
//
//  Created by 田黎强 on 2020/3/12.
//  Copyright © 2020 zsf. All rights reserved.
//

#import "TWSearchImContactsCell.h"

@implementation TWSearchImContactsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)dataForCell:(NIMRecentSession *)recentSession user:(NSMutableDictionary *)userDict searchString:(NSString *)serchStr{
    self.nameLabel.attributedText=[self nameForRecentSession:recentSession user:userDict searchString:serchStr];
    [self.headImageView setAvatarBySession:recentSession.session];
}

- (BOOL)ignoreCase {
    BOOL ret = YES;
    return ret;
}

- (NSMutableAttributedString *)nameForRecentSession:(NIMRecentSession *)recent user:(NSMutableDictionary *)userDict searchString:(NSString *)searchStr {
    if (recent.session.sessionType == NIMSessionTypeP2P) {
        NIMUser *user = userDict[recent.session.sessionId];
        return [self showNameWithUser:user searchString:searchStr];
    } else if (recent.session.sessionType == NIMSessionTypeTeam) {
//        NIMTeam *team = _teamResultDictionary[recent.session.sessionId];
//        return [self showNameWithTeam:team];
        return nil;
    } else {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
}

- (NSMutableAttributedString *)showNameWithUser:(NIMUser *)user searchString:(NSString *)searchStr{
    NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:user.userId option:nil];
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] init];
    
    NSString *src = info.showName;
    NSString *searchText = searchStr;
    if ([self ignoreCase]) {
        src = [src lowercaseString];
        searchText = [searchText lowercaseString];
    }
    NSRange local = [src rangeOfString:searchText];
    if (local.location != NSNotFound) {
        NSMutableAttributedString *show = [[NSMutableAttributedString alloc] initWithString:(info.showName ?: @"null")];
        [show setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:local];
        [ret appendAttributedString:show];
    } else {
        src = user.userId;
        if ([self ignoreCase]) {
            src = [src lowercaseString];
        }
        local = [src rangeOfString:searchText];  //userId
        if (local.location != NSNotFound) {
            NSMutableAttributedString *mainShow = [[NSMutableAttributedString alloc] initWithString:(info.showName ?: @"null")];
            [ret appendAttributedString:mainShow];
            NSMutableAttributedString *show = [self otherShowName:user.userId searchString:searchStr];
            [ret appendAttributedString:show];
        } else {
            src = user.alias;
            if ([self ignoreCase]) {
                src = [src lowercaseString];
            }
            local = [src rangeOfString:searchText]; //nickName
            if (local.location != NSNotFound) {
                NSMutableAttributedString *mainShow = [[NSMutableAttributedString alloc] initWithString:(info.showName ?: @"null")];
                [ret appendAttributedString:mainShow];
                NSMutableAttributedString *show = [self otherShowName:user.alias searchString:searchStr];
                [ret appendAttributedString:show];
            } else {
                src = user.userInfo.nickName;
                if ([self ignoreCase]) {
                    src = [src lowercaseString];
                }
                local = [src rangeOfString:searchText]; //nickName
                if (local.location != NSNotFound) {
                    NSMutableAttributedString *mainShow = [[NSMutableAttributedString alloc] initWithString:(info.showName ?: @"null")];
                    [ret appendAttributedString:mainShow];
                    NSMutableAttributedString *show = [self otherShowName:user.userInfo.nickName searchString:searchStr];
                    [ret appendAttributedString:show];
                }
            }
        }
    }
    return ret;
}

- (NSMutableAttributedString *)otherShowName:(NSString *)string searchString:(NSString *)searchStr {
    NSString *otherShow = [NSString stringWithFormat:@" [%@]", string];
    NSMutableAttributedString *show = [[NSMutableAttributedString alloc] initWithString:otherShow];
    NSString *searchText = searchStr;
    if ([self ignoreCase]) {
        searchText = [searchText lowercaseString];
    }
    NSRange local = [[otherShow lowercaseString] rangeOfString:searchText];
    [show setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:local];
    return show;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
