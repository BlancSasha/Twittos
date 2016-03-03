//
//  FBTweet.h
//  Twittos
//
//  Created by François Blanc on 08/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Mantle.h"

@class FBTweetImage;
@class FBTweetLink;
@class FBUser;
@class FMResultSet;

@interface FBTweet : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSString *tweetID;
@property (strong, nonatomic) NSString *text;
@property (nonatomic) NSInteger retweetCount;
@property (nonatomic) NSInteger likes;
@property (strong, nonatomic) NSArray *coordinates;
@property (strong, nonatomic) NSDate *tweetDate;

@property (strong, nonatomic) NSArray <FBTweetLink *> *tweetLinks;
@property (strong, nonatomic) NSArray <FBTweetImage *> *tweetMedias;

@property (strong, nonatomic) FBTweet *retweetedStatus;
@property (strong, nonatomic) FBUser *tweetUser;
@property (strong, nonatomic) FBUser *retweetUser;

- (instancetype)initWithResultSet:(FMResultSet *)set;


@end
