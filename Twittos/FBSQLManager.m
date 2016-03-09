//
//  FBSQLManager.m
//  Twittos
//
//  Created by François Blanc on 11/02/2016.
//  Copyright © 2016 François Blanc. All rights reserved.
//

#import "FBSQLManager.h"
#import "FBTweet.h"
#import "FBUser.h"
#import "FBTweetLink.h"
#import "FBTweetImage.h"

#import "sqlite3.h"
#import "FMDatabase.h"

@interface FBSQLManager ()

@property (strong, nonatomic) FMDatabase *database;

@end


@implementation FBSQLManager


+(instancetype)sharedSQLManager
{
    static dispatch_once_t token;
    static FBSQLManager *sharedSQLManager;
    dispatch_once(&token, ^{
        sharedSQLManager = [[FBSQLManager alloc] init];
    });
    return sharedSQLManager;
}

+ (NSString *)databaseFilePath
{
    NSString *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    return [docs stringByAppendingPathComponent:@"db.sqlite"];
}

-(instancetype) init
{
    self = [super init];
    if(self)
    {
        self.database = [FMDatabase databaseWithPath:[[self class] databaseFilePath]];
        [self.database open];
        [self createTablesIfNeeded];
    }
    return self;
}

-(void)createTablesIfNeeded
{
    [self.database executeUpdate:@"CREATE TABLE IF NOT EXISTS tweetsTable (\
     tweetID TEXT  PRIMARY KEY DEFAULT NULL, \
     tweetText TEXT DEFAULT NULL, \
     retweetCount INTEGER DEFAULT NULL, \
     likes INTEGER DEFAULT NULL, \
     coordinateLongitude1 DOUBLE DEFAULT NULL, \
     coordinateLatitude1 DOUBLE DEFAULT NULL, \
     coordinateLongitude2 DOUBLE DEFAULT NULL, \
     coordinateLatitude2 DOUBLE DEFAULT NULL, \
     coordinateLongitude3 DOUBLE DEFAULT NULL, \
     coordinateLatitude3 DOUBLE DEFAULT NULL, \
     coordinateLongitude4 DOUBLE DEFAULT NULL, \
     coordinateLatitude4 DOUBLE DEFAULT NULL, \
     date TEXT DEFAULT NULL, \
     numberOfUserMention INTEGER DEFAULT NULL, \
     tweetContentImageURL TEXT DEFAULT NULL, \
     retweetedStatusID INTEGER DAFAULT NULL, \
     tweetUserID INTEGER DEFAULT NULL, \
     retweetUserID INTEGER DEFAULT NULL)"];
    
    [self.database executeUpdate:@"CREATE TABLE IF NOT EXISTS tweetLinksTable (\
     tweetLinkID TEXT PRIMARY KEY DEFAULT NULL, \
     userID TEXT DEFAULT NULL, \
     startIndice INTEGER DEFAULT NULL, \
     endIndice INTEGER DEFAULT NULL)"];
    
    [self.database executeUpdate:@"CREATE TABLE IF NOT EXISTS userTable (\
     userID TEXT  PRIMARY KEY DEFAULT NULL, \
     userFollowersCount INTEGER  DEFAULT NULL, \
     userFriendsCount INTEGER  DEFAULT NULL, \
     userLikesCount INTEGER  DEFAULT NULL, \
     userName TEXT DEFAULT NULL, \
     userSreenName TEXT DEFAULT NULL, \
     userLocation TEXT DEFAULT NULL, \
     userDescription TEXT DEFAULT NULL, \
     userWebSite TEXT DEFAULT NULL, \
     userImageURL TEXT DEFAULT NULL, \
     userBackgroundImageURL TEXT DEFAULT NULL)"];
}

#pragma mark - Tweets

-(BOOL)hasTweetInDatabase:(FBTweet *)tweet
{
    if(!tweet.tweetID)
    {
        return NO;
    }
    
    BOOL itemExists = NO;
    
    FMResultSet *set = [self.database executeQuery:@"SELECT tweetID FROM tweetsTable WHERE tweetID=?"
                                            values:@[tweet.tweetID]
                                             error:NULL];
    if ([set next]) {
        itemExists = YES;
    }
    [set close];
    
    return itemExists;
}

-(BOOL)hasTweetInDatabaseWithRetweetedStatusIDEqualTo:(NSString *)tweetID
{
    if(!tweetID.length)
    {
        return NO;
    }
    
    BOOL itemExists = NO;
    
    FMResultSet *set = [self.database executeQuery:@"SELECT retweetedStatusID FROM tweetsTable WHERE retweetedStatusID=?"
                                            values:@[tweetID]
                                             error:NULL];
    if ([set next]) {
        itemExists = YES;
    }
    [set close];
    
    return itemExists;
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
        if(![self hasTweetInDatabase:(tweet.retweetedStatus)])
        {
            [self addTweetInDatabase:tweet.retweetedStatus];
        }
    }
    if(![self hasTweetInDatabase:tweet])
    {
        [self.database executeUpdate:@"INSERT INTO tweetsTable \
         (tweetID, \
         tweetText, \
         retweetCount, \
         likes, \
         coordinateLongitude1, \
         coordinateLatitude1, \
         coordinateLongitude2, \
         coordinateLatitude2, \
         coordinateLongitude3, \
         coordinateLatitude3, \
         coordinateLongitude4, \
         coordinateLatitude4, \
         date, \
         numberOfUserMention, \
         tweetContentImageURL, \
         retweetedStatusID, \
         tweetUserID, \
         retweetUserID) \
         VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
                              values:@[tweet.tweetID,
                                       tweet.text,
                                       @(tweet.retweetCount),
                                       @(tweet.likes),
                                       (tweet.coordinates[0][0][0] ?: [NSNull null]),
                                       (tweet.coordinates[0][0][1] ?: [NSNull null]),
                                       (tweet.coordinates[0][1][0] ?: [NSNull null]),
                                       (tweet.coordinates[0][1][1] ?: [NSNull null]),
                                       (tweet.coordinates[0][2][0] ?: [NSNull null]),
                                       (tweet.coordinates[0][2][1] ?: [NSNull null]),
                                       (tweet.coordinates[0][3][0] ?: [NSNull null]),
                                       (tweet.coordinates[0][3][1] ?: [NSNull null]),
                                       @(tweet.tweetDate.timeIntervalSince1970),
                                       (@(tweet.tweetLinks.count) ?: [NSNull null]),
                                       (tweet.tweetMedias[0].tweetImageContentURL ?: [NSNull null]),
                                       (tweet.retweetedStatus.tweetID ?: [NSNull null]),
                                       tweet.tweetUser.userID,
                                       (tweet.retweetUser.userID ?: [NSNull null])
                                       ]error:NULL];
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
    
    FBTweet *tweet;
    
    FMResultSet *set = [self.database executeQuery:@"SELECT * FROM tweetsTable WHERE tweetID=?"
                                            values:@[tweetID]
                                             error:NULL];
    if ([set next]) {
        tweet = [[FBTweet alloc] initWithResultSet:set];
        tweet.tweetUser = [self getUserForUserID:[set stringForColumn:@"tweetUserID"]];
        if([set stringForColumn:@"retweetUserID"])
        {
            tweet.retweetUser = [self getUserForUserID:[set stringForColumn:@"retweetUserID"]];
        }
        if([set stringForColumn:@"retweetedStatusID"])
            
        {
            FMResultSet *retweetSet = [self.database executeQuery:@"SELECT * FROM tweetsTable WHERE tweetID=?"
                                                    values:@[[set stringForColumn:@"retweetedStatusID"]]
                                                     error:NULL];
            if ([retweetSet next]) {
                tweet.retweetedStatus = [[FBTweet alloc] initWithResultSet:set];
                tweet.retweetedStatus.tweetUser = [self getUserForUserID:[set stringForColumn:@"tweetUserID"]];
            }
                [retweetSet close];
        }
        NSInteger numberOfUserMentions= [[set stringForColumn:@"numberOfUserMention"] integerValue];
        if(numberOfUserMentions)
        {
                tweet.tweetLinks = [self getTweetLinksFortweetID:tweetID
                                                andNumberOfLinks:numberOfUserMentions];
        }
    }
    [set close];

    return tweet;
}

-(NSArray *)getAllTweets
{
    NSMutableArray *tweets = [[NSMutableArray alloc] init];
    
    FMResultSet *set = [self.database executeQuery:@"SELECT tweetID FROM tweetsTable"];
    while([set next])
    {
        if(![self hasTweetInDatabaseWithRetweetedStatusIDEqualTo:[set stringForColumn:@"tweetID"]])
        {
            FBTweet *tweet = [self getTweetForTweetID:[set stringForColumn:@"tweetID"]];
            [tweets insertObject:tweet atIndex:0];
            //[tweets addObject:tweet];
        }
    }
    [set close];
    return tweets;
}

#pragma mark - users

-(BOOL)hasUserInDatabase:(FBUser *)user
{
    if(!user.userID)
    {
        return NO;
    }
    
    BOOL itemExists = NO;
    
    FMResultSet *set = [self.database executeQuery:@"SELECT userID FROM userTable WHERE userID=?"
                                            values:@[user.userID]
                                             error:NULL];
    if ([set next]) {
        itemExists = YES;
    }
    [set close];
    
    return itemExists;

}

-(void)addUserInDatabase:(FBUser *)user
{
    if(!user)
    {
        return;
    }
    
    if(![self hasUserInDatabase:user])
    {
        [self.database executeUpdate:@"INSERT INTO userTable \
         (userID, \
         userFollowersCount, \
         userFriendsCount, \
         userLikesCount, \
         userName, \
         userSreenName, \
         userLocation, \
         userDescription, \
         userWebSite, \
         userImageURL, \
         userBackgroundImageURL) \
         VALUES (?,?,?,?,?,?,?,?,?,?,?)"
                              values:@[user.userID,
                                       (@(user.userFollowersCount) ?: [NSNull null]),
                                       (@(user.userFriendsCount) ?: [NSNull null]),
                                       (@(user.userLikesCount) ?: [NSNull null]),
                                       user.userName,
                                       user.userSreenName,
                                       user.userLocation,
                                       user.userDescription,
                                       (user.userWebSite ?: [NSNull null]),
                                       (user.userImageURL ?: [NSNull null]),
                                       user.userBackgroundImageURL
                                       ]error:NULL];
    }
}

-(FBUser *)getUserForUserID:(NSString *)userID
{
    if (!userID.length)
        return nil;
    
    FBUser *user;
    
    FMResultSet *set = [self.database executeQuery:@"SELECT * FROM userTable WHERE userID=?"
                                            values:@[userID]
                                             error:NULL];
    if ([set next]) {
        user = [[FBUser alloc] initWithResultSet:set];
    }
    return user;
}

#pragma mark - tweetLinks

-(BOOL)hastweetLinkInDatabase:(FBTweetLink *)tweetLink
                   forTweetID:(NSString *)tweetID
                andRowInTweet:(NSInteger)row
{
    if(!tweetID)
    {
        return NO;
    }
    
    NSString *tweetLinkID = [tweetID stringByAppendingString:[@(row) stringValue]];
    
    BOOL itemExists = NO;
    
    FMResultSet *set = [self.database executeQuery:@"SELECT tweetLinkID FROM tweetLinksTable WHERE tweetIDAndRowIndex=?"
                                            values:@[tweetLinkID]
                                             error:NULL];
    if ([set next]) {
        itemExists = YES;
    }
    [set close];
    
    return itemExists;
}

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
        if(![self hastweetLinkInDatabase:tweetLink forTweetID:tweetID andRowInTweet:i])
        {
            [self.database executeUpdate:@"INSERT INTO tweetLinksTable \
             (tweetLinkID, \
             userID, \
             startIndice, \
             endIndice) \
             VALUES (?,?,?,?)"
                                  values:@[tweetLinkID,
                                           tweetLink.userID,
                                           (@([tweetLink.indices[0] integerValue]) ?: [NSNull null]),
                                           (@([tweetLink.indices[1] integerValue]) ?: [NSNull null]),
                                           ]error:NULL];
        }
        i = i+1;
    }
}

-(NSArray <FBTweetLink *> *)getTweetLinksFortweetID:(NSString *)tweetID
                                   andNumberOfLinks:(NSInteger)linksCount;
{
    if(!tweetID.length)
        return nil;
    
    NSMutableArray *tweetLinks = [[NSMutableArray alloc] init];
    
    for(int i=0;i<linksCount;i++)
    {
        NSString *tweetLinkID = [tweetID stringByAppendingString:[@(i) stringValue]];

        FBTweetLink *tweetLink;
        
        FMResultSet *set = [self.database executeQuery:@"SELECT * FROM tweetLinksTable WHERE tweetLinkID=?"
                                                values:@[tweetLinkID]
                                                 error:NULL];
        if ([set next]) {
            tweetLink = [[FBTweetLink alloc] initWithResultSet:set];
            [tweetLinks addObject:tweetLink];
        }
        [set close];
    }
    
    return tweetLinks;
}


/*@"CREATE TABLE IF NOT EXISTS tweetLinksTable (\
tweetIDAndRowIndex TEXT PRIMARY KEY DEFAULT NULL, \
userID TEXT DEFAULT NULL, \
startIndice INTEGER DEFAULT NULL, \
endIndice INTEGER DEFAULT NULL)"];*/

@end
