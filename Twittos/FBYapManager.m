//
//  FBYapManager.m
//  Twittos
//
//  Created by François Blanc on 15/03/2016.
//  Copyright © 2016 François Blanc. All rights reserved.
//

#import "FBYapManager.h"
#import "YapDatabase.h"

#import "FBTweet.h"
#import "FBUser.h"
#import "FBTweetLink.h"
#import "FBTweetImage.h"

#define TWEETSCOLLECTION @"tweetsCollection"
#define USERSCOLLECTION @"usersCollection"
#define TWEETLINKSCOLLECTION @"tweetLinksCollection"

@interface FBYapManager ()

@property (strong, nonatomic) YapDatabase *yapDatabase;
@property (strong, nonatomic) YapDatabaseConnection *connection;

@end

@implementation FBYapManager

+(instancetype)sharedYapManager
{
    static dispatch_once_t token;
    static FBYapManager *sharedYapManager;
    dispatch_once(&token, ^{
        sharedYapManager = [[FBYapManager alloc] init];
    });
    return sharedYapManager;
}

+ (NSString *)databaseFilePath
{
    NSString *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    return [docs stringByAppendingPathComponent:@"yap.sqlite"];
}

-(instancetype) init
{
    self = [super init];
    if(self)
    {
        self.yapDatabase = [[YapDatabase alloc] initWithPath:[[self class] databaseFilePath]];
        self.connection = [self.yapDatabase newConnection];
    }
    return self;
}

-(void)addTweetInDatabase:(FBTweet *)tweet
{
    if(!tweet)
    {
        return;
    }
    
    if(tweet.retweetUser)
    {
        [self addUserInDatabase:(tweet.retweetUser)];
    }
    
    [self addUserInDatabase:(tweet.tweetUser)];
    
    if(tweet.tweetLinks.count)
    {
        [self addtweetLinksInDatabase:tweet.tweetLinks forTweetID:tweet.tweetID];
    }
    
    if(tweet.retweetedStatus)
    {
        [self.connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            if(![transaction hasObjectForKey:tweet.retweetedStatus.tweetID
                               inCollection:TWEETSCOLLECTION])
            {
                [self addTweetInDatabase:tweet.retweetedStatus
                         withTransaction:transaction];
            }
        }];
    }
    
    [self.connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        if(![transaction hasObjectForKey:tweet.tweetID
                            inCollection:TWEETSCOLLECTION])
        {
            [transaction setObject:tweet
                            forKey:tweet.tweetID
                      inCollection:TWEETSCOLLECTION];
        }
    }];
}

-(void)addTweetInDatabase:(FBTweet *)tweet
          withTransaction:(YapDatabaseReadWriteTransaction *)transaction
{
    if(!tweet)
    {
        return;
    }
    
    if(tweet.retweetUser)
    {
        [self addUserInDatabase:(tweet.retweetUser)
                withTransaction:transaction];
    }
    
    [self addUserInDatabase:(tweet.tweetUser)
            withTransaction:transaction];
    
    if(tweet.tweetLinks.count)
    {
        [self addtweetLinksInDatabase:tweet.tweetLinks
                           forTweetID:tweet.tweetID
                      withTransaction:transaction];
    }
    
    if(tweet.retweetedStatus)
    {
        if([transaction hasObjectForKey:tweet.retweetedStatus.tweetID
                           inCollection:TWEETSCOLLECTION])
        {
            [self addTweetInDatabase:tweet.retweetedStatus
                     withTransaction:transaction];
        }
    }
    
    if(![transaction hasObjectForKey:tweet.tweetID
                        inCollection:TWEETSCOLLECTION])
    {
        [transaction setObject:tweet
                        forKey:tweet.tweetID
                  inCollection:TWEETSCOLLECTION];
    }
}

-(void)addTweetsInDatabase:(NSArray *)tweets
{
    for (FBTweet *tweet in tweets)
    {
        [self addTweetInDatabase:tweet];
    }
}

-(FBTweet *)getTweetForTweetID:(NSString *)tweetID
{
    if (!tweetID.length)
        return nil;
    
    __block FBTweet *tweet;
    
    [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        tweet = [transaction objectForKey:tweetID inCollection:TWEETSCOLLECTION];
     }];    
    return tweet;
}

-(NSArray *)getAllTweets
{
    NSMutableArray *tweets = [[NSMutableArray alloc] init];
    __block NSArray *tweetIDs;
    
    [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        tweetIDs = [transaction allKeysInCollection:TWEETSCOLLECTION];
    }];
    
    for(NSString *tweetID in tweetIDs)
    {
        FBTweet *tweet = [self getTweetForTweetID:tweetID];
        [tweets insertObject:tweet atIndex:0];
    }
    return tweets;
}

#pragma mark - users

-(void)addUserInDatabase:(FBUser *)user
{
    if(!user)
    {
        return;
    }
    [self.connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        if(![transaction hasObjectForKey:user.userID inCollection:USERSCOLLECTION])
        {
            [transaction setObject:user
                            forKey:user.userID
                      inCollection:USERSCOLLECTION];
        }
    }];
}

-(void)addUserInDatabase:(FBUser *)user
         withTransaction:(YapDatabaseReadWriteTransaction *)transaction
{
    if(!user)
    {
        return;
    }
    
    if(![transaction hasObjectForKey:user.userID inCollection:USERSCOLLECTION])
    {
        [transaction setObject:user
                        forKey:user.userID
                  inCollection:USERSCOLLECTION];
    }
}

-(FBUser *)getUserForUserID:(NSString *)userID
{
    if (!userID.length)
        return nil;
    
    __block FBUser *user;
    
    [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        user = [transaction objectForKey:userID inCollection:USERSCOLLECTION];

    }];
    return user;
}

#pragma mark - tweetLinks

-(void)addtweetLinksInDatabase:(NSArray <FBTweetLink *> *)tweetLinks
                    forTweetID:(NSString *)tweetID
{
    if(!tweetID)
    {
        return;
    }
    int i = 0;
    
    for (FBTweetLink *tweetLink in tweetLinks)
    {
        if(!tweetLink.userID)
            return;
        
        NSString *tweetLinkID = [tweetID stringByAppendingString:[@(i) stringValue]];
        
        [self.connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            if(![transaction hasObjectForKey:tweetLinkID inCollection:TWEETLINKSCOLLECTION])
            {
                [transaction setObject:tweetLink forKey:tweetLinkID inCollection:TWEETLINKSCOLLECTION];
            }
        }];
        i = i+1;
    }
}

-(void)addtweetLinksInDatabase:(NSArray <FBTweetLink *> *)tweetLinks
                    forTweetID:(NSString *)tweetID
               withTransaction:(YapDatabaseReadWriteTransaction *)transaction
{
    if(!tweetID)
    {
        return;
    }
    int i = 0;
    
    for (FBTweetLink *tweetLink in tweetLinks)
    {
        if(!tweetLink.userID)
            return;
        
        NSString *tweetLinkID = [tweetID stringByAppendingString:[@(i) stringValue]];
        
        if(![transaction hasObjectForKey:tweetLinkID inCollection:TWEETLINKSCOLLECTION])
        {
            [transaction setObject:tweetLink forKey:tweetLinkID inCollection:TWEETLINKSCOLLECTION];
        }
        i = i+1;
    }
}

-(NSArray <FBTweetLink *> *)getTweetLinksFortweetID:(NSString *)tweetID
                                   andNumberOfLinks:(NSInteger)linksCount;
{
    if(!tweetID.length)
        return nil;
    
    __block NSMutableArray *tweetLinks = [[NSMutableArray alloc] init];
    
    for(int i=0;i<linksCount;i++)
    {
        NSString *tweetLinkID = [tweetID stringByAppendingString:[@(i) stringValue]];
        
        __block FBTweetLink *tweetLink;
        
        [self.connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            tweetLink = [transaction objectForKey:tweetLinkID inCollection:TWEETLINKSCOLLECTION];
            [tweetLinks addObject:tweetLink];
        }];
    }
    return tweetLinks;
}

@end
