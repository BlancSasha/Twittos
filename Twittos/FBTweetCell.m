//
//  FBTweetCell.m
//  Twittos
//
//  Created by François Blanc on 20/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import "FBTweetCell.h"

#import "Masonry.h"

#import "FBTweet.h"
#import "FBTweetLink.h"

@interface FBTweetCell ()

@property (strong, nonatomic) UILabel *tweetLabel;

@end

@implementation FBTweetCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.tweetLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.tweetLabel];
        self.tweetLabel.numberOfLines = 0;
        self.tweetLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.tweetLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@10);
            make.bottom.equalTo(@(-10));
            make.left.equalTo(@10);
            make.right.equalTo(@(-10));
        }];
    }
    return self;
}

-(void) setTweet:(FBTweet *)tweet{
    
    
    NSAttributedString *attrName =
    [[NSAttributedString alloc] initWithString:tweet.name
                                    attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}];
    
    NSAttributedString *attrScreenName =
    [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@" @%@\n", tweet.screenName]
                                    attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],
                                                 NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    NSMutableAttributedString *attrText = [NSMutableAttributedString alloc];
    
    if(tweet.retweetedStatus){
    attrText = [attrText initWithString:tweet.retweetedStatus.text
                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        for (FBTweetLink *tweetLink in tweet.retweetedStatus.tweetLinks)
        {
            NSInteger start = [tweetLink.indices[0] integerValue];
            NSInteger end = [tweetLink.indices[1] integerValue];
            NSInteger length = end - start;
            
            [attrText addAttribute:NSForegroundColorAttributeName
                             value:[UIColor blueColor]
                             range:NSMakeRange(start,length)];
        }
    }else{
    attrText = [attrText initWithString:tweet.text
                             attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        for (FBTweetLink *tweetLink in tweet.tweetLinks)
        {
            NSInteger start = [tweetLink.indices[0] integerValue];
            NSInteger end = [tweetLink.indices[1] integerValue];
            NSInteger length = end - start;
            
            [attrText addAttribute:NSForegroundColorAttributeName
                             value:[UIColor blueColor]
                             range:NSMakeRange(start,length)];
        }
    }
    

    
    NSMutableAttributedString *attrTweet = [[NSMutableAttributedString alloc] init];
    [attrTweet appendAttributedString:attrName];
    [attrTweet appendAttributedString:attrScreenName];
    [attrTweet appendAttributedString:attrText];
 
    [self.tweetLabel setAttributedText:attrTweet];
}


@end
