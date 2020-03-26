//
//  TWSearchImMessageCell.h
//  TaiWuOffice
//
//  Created by 田黎强 on 2020/3/12.
//  Copyright © 2020 zsf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIMAvatarImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWSearchImMessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NIMAvatarImageView *headImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
-(void)dataForCell:(NIMSession *)session searchDic:(NSDictionary *)messagesDic searchStr:(NSString *)searchStr;
-(void)dataForCell:(NIMSession *)session message:(NIMMessage *)message searchStr:(NSString *)searchStr;
@end

NS_ASSUME_NONNULL_END
