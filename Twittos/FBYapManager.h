//
//  FBYapManager.h
//  Twittos
//
//  Created by François Blanc on 15/03/2016.
//  Copyright © 2016 François Blanc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class FBTweet;
@class FBUser;
@class FBTweetLink;

@interface FBYapManager : NSObject

#pragma mark - tweet

-(void)addTweetInDatabase:(FBTweet *)tweet;
-(void)addTweetsInDatabase:(NSArray *)tweets;
-(FBTweet *)getTweetForTweetID:(NSString *)tweetID;
//-(BOOL)hasTweetInDatabase:(FBTweet *)tweet;
-(NSArray *)getAllTweets;


#pragma mark - user

-(FBUser *)getUserForUserID:(NSString *)userID;
-(void)addUserInDatabase:(FBUser *)user;
//-(BOOL)hasUserInDatabase:(FBUser *)user;

#pragma mark - tweeLinks

-(NSArray <FBTweetLink *> *)getTweetLinksFortweetID:(NSString *)tweetID
                                   andNumberOfLinks:(NSInteger)linksCount;
-(void)addtweetLinksInDatabase:(NSArray <FBTweetLink *> *)tweetLinks
                    forTweetID:(NSString *)tweetID;
/*(BOOL)hastweetLinkInDatabase:(FBTweetLink *)tweetLink
                   forTweetID:(NSString *)tweetID
                andRowInTweet:(NSInteger)row;*/

+(instancetype)sharedYapManager;

@end
