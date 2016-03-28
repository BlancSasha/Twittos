//
//  FBTweet.m
//  Twittos
//
//  Created by François Blanc on 08/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import "FBTweet.h"
#import "FBTweetLink.h"
#import "FBTweetImage.h"
#import "FMResultSet.h"
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>

@implementation FBTweet

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"tweetID":@"id_str",
             @"text":@"text",
             @"coordinates":@"place.bounding_box.coordinates",
             @"retweetCount":@"retweet_count",
             @"likes":@"favorite_count",
             @"tweetLinks":@"entities.user_mentions",
             @"retweetedStatus":@"retweeted_status",
             @"tweetUser":@"user",
             @"retweetUser":@"retweeted_status.user",
             @"tweetDate":@"created_at",
             @"tweetMedias":@"entities.media",
             };
}

- (instancetype)initWithResultSet:(FMResultSet *)set
{
    self = [super init];
    if (self)
    {
        self.tweetID = [set stringForColumn:@"tweetID"];
        self.text = [set stringForColumn:@"tweetText"];
        self.retweetCount = [[set stringForColumn:@"retweetCount"] integerValue];
        self.likes = [[set stringForColumn:@"likes"] integerValue];
        self.coordinates[0][0][0] = [set stringForColumn:@"coordinateLongitude1"];
        self.coordinates[0][0][1] = [set stringForColumn:@"coordinateLatitude1"];
        self.coordinates[0][1][0] = [set stringForColumn:@"coordinateLongitude2"];
        self.coordinates[0][1][1] = [set stringForColumn:@"coordinateLatitude2"];
        self.coordinates[0][2][0] = [set stringForColumn:@"coordinateLongitude3"];
        self.coordinates[0][2][1] = [set stringForColumn:@"coordinateLatitude3"];
        self.coordinates[0][3][0] = [set stringForColumn:@"coordinateLongitude4"];
        self.coordinates[0][3][1] = [set stringForColumn:@"coordinateLatitude4"];
        self.tweetDate = [[NSDate alloc] initWithTimeIntervalSince1970:[[set stringForColumn:@"date"] doubleValue]];
        self.tweetMedias[0].tweetImageContentURL = [set stringForColumn:@"tweetContentImageURL"];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        self.tweetID = [coder decodeObjectForKey:@"myString"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, text: %@, retweetCount: %i, likes : %i, tweetLinks : %@>",
            self.class, self, self.text, self.retweetCount, self.likes, self.tweetLinks];
}

+(NSValueTransformer *)tweetMediasJSONTransformer
{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[FBTweetImage class]];
}
    
+ (NSValueTransformer *)tweetLinksJSONTransformer
{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[FBTweetLink class]];
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss ZZZ yyyy"; //Wed Dec 23 15:52:46 +0000 2015
    return dateFormatter; 
}

+ (NSValueTransformer *)tweetDateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

@end

