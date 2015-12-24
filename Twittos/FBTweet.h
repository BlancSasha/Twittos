//
//  FBTweet.h
//  Twittos
//
//  Created by François Blanc on 08/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Mantle.h"

@class FBTweetLink;
@class FBUser;

@interface FBTweet : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *user;
@property (nonatomic) NSInteger retweetCount;
@property (nonatomic) NSInteger likes;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *screenName;
@property (strong, nonatomic) NSArray *coordinates;

@property (strong, nonatomic) NSArray *tweetLinks;

@property (strong, nonatomic) FBTweet *retweetedStatus;
@property (strong, nonatomic) FBUser *tweetUser;
@property (strong, nonatomic) FBUser *retweetUser;

@end
