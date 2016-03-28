//
//  FBTweetCell.m
//  Twittos
//
//  Created by François Blanc on 20/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import "FBTweetCell.h"

#import "Masonry.h"
#import "QuartzCore/QuartzCore.h"
#import "DateTools.h"

#import "FBTweet.h"
#import "FBTweetLink.h"
#import "FBTweetManager.h"
#import "FBUser.h"
#import "FBImageManager.h"
#import "FBTweetImage.h"


@interface FBTweetCell () <FBImageManagerDelegate>

@property (strong, nonatomic) UILabel *tweetLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UIImageView *userImageView;
@property (strong, nonatomic) UIImageView *tweetMediaView;
@property (strong, nonatomic) UITextView *tweetTextView;

@property (strong, nonatomic) UITapGestureRecognizer *tapOnTweetMediaView;

@property(strong, nonatomic) FBTweetImage *tweetImage;
@property(strong,nonatomic) UIImage *tweetUIImage;

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

        
        self.tweetLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.tweetLabel];
        self.tweetLabel.numberOfLines = 0;
        self.tweetLabel.lineBreakMode = NSLineBreakByWordWrapping;

        self.dateLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.dateLabel];
        self.dateLabel.numberOfLines = 0;
        self.dateLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.tweetMediaView = [[UIImageView alloc] init];
        [self.tweetMediaView setBackgroundColor:[UIColor grayColor]];
        self.tweetMediaView.contentMode = UIViewContentModeScaleAspectFill;
        self.tweetMediaView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.tweetMediaView];
        
        self.tapOnTweetMediaView = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(imageTapped:)];
        [self.tweetMediaView addGestureRecognizer:self.tapOnTweetMediaView];
        [self.tweetMediaView setUserInteractionEnabled:YES];
    
        
        self.tweetTextView = [[UITextView alloc] init];
        [self.tweetTextView setTextContainerInset:UIEdgeInsetsZero];
        [self.tweetTextView setDelegate:self];
        self.tweetTextView.editable = NO;
        self.tweetTextView.scrollEnabled = NO;
        self.tweetTextView.dataDetectorTypes = (UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber);
        [self.contentView addSubview:self.tweetTextView];

    }
    return self;
}

-(void)dealloc
{
    [[FBImageManager sharedInstance] removeDelegate:self];
}

-(void) updateConstraints
{
    [super updateConstraints];
    
    [self.userImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@10);
        make.left.equalTo(@10);
        make.height.equalTo(@24);
        make.width.equalTo(@24);
    }];
    
    self.userImageView.layer.cornerRadius = 3;
    self.userImageView.layer.borderColor = [UIColor orangeColor].CGColor;
    self.userImageView.layer.borderWidth = 1;
    [self.userImageView setClipsToBounds:YES];
    
    for (MASConstraint *constraint in [MASViewConstraint installedConstraintsForView:self.tweetMediaView])
        [constraint uninstall];
    
    for (MASConstraint *constraint in [MASViewConstraint installedConstraintsForView:self.tweetLabel])
        [constraint uninstall];
    
    [self.tweetLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@10);
        if(!self.tweetImage)
        {
            make.bottom.equalTo(@(-10)).priorityLow();
        }
        make.left.equalTo(self.userImageView.mas_right).offset(10);
        make.right.equalTo(@(-10));
    }];
    [self.tweetLabel setHidden:YES];
    
    [self.tweetTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tweetLabel.mas_top);
        make.left.equalTo(self.tweetLabel.mas_left);
        make.right.equalTo(self.tweetLabel.mas_right);
        make.bottom.equalTo(self.tweetLabel.mas_bottom);
    }];
    
    if(self.tweetImage)
    {
        [self.tweetMediaView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tweetLabel.mas_bottom).offset(10);
            make.left.equalTo(@10);
            make.right.equalTo(@(-10));
            make.height.equalTo(self.tweetMediaView.mas_width).multipliedBy(1./2.);
            make.bottom.equalTo(@(-10)).priorityLow();
        }];
        [self.tweetMediaView setBackgroundColor:[UIColor redColor]];
    }
}

-(void) setTweet:(FBTweet *)tweet{
    
    self->_tweet = tweet;
    
    self.tweetImage = self.tweet.tweetMedias[0];
    
    [self.tweetMediaView setHidden:YES];
    
    
    NSAttributedString *attrName =
    [[NSAttributedString alloc] initWithString:tweet.tweetUser.userName
                                    attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}];
    
    NSAttributedString *attrScreenName =
    [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@" @%@\n", tweet.tweetUser.userSreenName]
                                    attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],
                                                 NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    NSAttributedString *attrDateText =
    [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"%@\n", [tweet.tweetDate formattedDateWithStyle:NSDateFormatterFullStyle]]
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
            
            /*[attrText addAttribute:NSForegroundColorAttributeName
                             value:[UIColor blueColor]
                             range:NSMakeRange(start,length)];*/
            NSString *value = [[NSString alloc] initWithFormat:@"userID%@",tweetLink.userID];
            
            [attrText addAttribute:NSLinkAttributeName
                             value:value
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
            
           /* [attrText addAttribute:NSForegroundColorAttributeName
                             value:[UIColor blueColor]
                             range:NSMakeRange(start,length)];*/
            NSString *value = [[NSString alloc] initWithFormat:@"userID%@",tweetLink.userID];
            [attrText addAttribute:NSLinkAttributeName
                             value:value
                             range:NSMakeRange(start,length)];
            
            
        }
    }
    
    UIImage *image = [[FBImageManager sharedInstance] getImage:FBTweetImageUserForTableview inCacheForTweet:tweet orUser:nil];
    if(image!=nil)
    {
        [self.userImageView setImage:image];
    }
    
    
    if(self.tweetImage)
    {
        UIImage *contentImage = [[FBImageManager sharedInstance] getImage:FBTweetImageContent inCacheForTweet:tweet orUser:nil];
        if(contentImage!=nil)
        {
            self.tweetUIImage = contentImage;
            [self.tweetMediaView setImage:contentImage];
            [self.tweetMediaView setBackgroundColor:[UIColor whiteColor]];
        }
    }

    
    NSMutableAttributedString *attrTweet = [[NSMutableAttributedString alloc] init];
    [attrTweet appendAttributedString:attrName];
    [attrTweet appendAttributedString:attrScreenName];
    [attrTweet appendAttributedString:attrDateText];
    [attrTweet appendAttributedString:attrText];
 
    [self.tweetLabel setAttributedText:attrTweet];
    [self.tweetTextView setAttributedText:attrTweet];
    
   if(self.tweetImage)
    {
        [self.tweetMediaView setHidden:NO];
    }
    
    
    [self setNeedsUpdateConstraints];
}

- (void)layoutIfNeeded
{
    [super layoutIfNeeded];
    self.tweetLabel.preferredMaxLayoutWidth = self.tweetLabel.frame.size.width;
}

-(void)imageTapped:(UITapGestureRecognizer *)recognizer
{
    self.imageTappedBlock(self.tweetUIImage);
}


-(void)didFinishDownloadingImage:(UIImage *)image forURL:(NSString *)URL
{
    if([self.tweet.tweetUser.userImageURL isEqualToString:URL])
    {
        [self.userImageView setImage:image];
    }else if([self.tweetImage.tweetImageContentURL isEqualToString:URL])
    {
        [self.tweetMediaView setImage:image];
        self.tweetUIImage = image;
    }
    
    
}

static FBTweetCell *sizingCell;

+ (CGFloat)cellHeightForTweet:(FBTweet *)tweet andWidth:(CGFloat)width
{
    if (!sizingCell)
    {
        sizingCell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sizingCellFBTweet"];
    }
    
    [sizingCell setTweet:tweet];
    [sizingCell setFrame:CGRectMake(0, 0, width, 1000.)];
    [sizingCell setNeedsUpdateConstraints];
    [sizingCell updateConstraintsIfNeeded];
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    [sizingCell.contentView layoutIfNeeded];
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:CGSizeMake(width, 1000.)
                                        withHorizontalFittingPriority:UILayoutPriorityRequired
                                              verticalFittingPriority:UILayoutPriorityFittingSizeLevel];
    //NSLog(@"%@", NSStringFromCGSize(size));
    return size.height + 1;
}

#pragma mark UITextView Delegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
   /* if ([URL.scheme isEqualToString:@"http"] ||[URL.scheme isEqualToString:@"https"])
    {
        // lien web
        // --> ouvrir un nouveau view controller avec une webview dedans
        return YES;
    }*/
    if([[URL.absoluteString substringToIndex:[@"userID" length]] isEqualToString: @"userID"])
    {
        NSString *userID = [URL.absoluteString substringFromIndex:[@"userID" length]];
        NSLog(@"UserID : %@",userID);
        
        [[FBTweetManager sharedManager] getUserInfoFor:userID withBlock:^(FBUser *user, NSError *error) {
            self.linkTappedBlockFOrUser(user);
        }];
        //self.linkTappedBlockFOrUser
        
    return NO;
    }else{
    return YES;
    }
}

@end
