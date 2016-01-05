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
#import "FBTweetManager.h"
#import "FBUser.h"
#import "FBImageManager.h"


@interface FBTweetCell () <FBImageManagerDelegate>

@property (strong, nonatomic) UILabel *tweetLabel;
@property (strong, nonatomic) UIImageView *userImageView;

@end

@implementation FBTweetCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [[FBImageManager sharedInstance] addDelegate:self];
        
        self.userImageView = [[UIImageView alloc] init];
        [self.userImageView setBackgroundColor:[UIColor grayColor]];
        [self.contentView addSubview:self.userImageView];
        [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@10);
            make.left.equalTo(@10);
            make.height.equalTo(@24);
            make.width.equalTo(@24);
        }];
        
        self.tweetLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.tweetLabel];
        self.tweetLabel.numberOfLines = 0;
        self.tweetLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.tweetLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@10);
            make.bottom.equalTo(@(-10));
            make.left.equalTo(self.userImageView.mas_right).offset(10);
            make.right.equalTo(@(-10));
        }];
        

        
    }
    return self;
}

-(void)dealloc
{
    [[FBImageManager sharedInstance] removeDelegate:self];
}

-(void) setTweet:(FBTweet *)tweet{
    
    self->_tweet = tweet;
    
    
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
    
    UIImage *image = [[FBImageManager sharedInstance] getImage:FBTweetImageUserForTableview inCacheForTweet:tweet];
    if(image!=nil)
    {
        [self.userImageView setImage:image];
    }
    
    NSMutableAttributedString *attrTweet = [[NSMutableAttributedString alloc] init];
    [attrTweet appendAttributedString:attrName];
    [attrTweet appendAttributedString:attrScreenName];
    [attrTweet appendAttributedString:attrText];
 
    [self.tweetLabel setAttributedText:attrTweet];
}


-(void)didFinishDownloadingImage:(UIImage *)image forURL:(NSString *)URL
{
    if([self.tweet.tweetUser.userImageURL isEqualToString:URL])
    {
        [self.userImageView setImage:image];
    }
}

@end