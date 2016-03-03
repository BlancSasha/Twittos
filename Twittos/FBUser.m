//
//  FBUser.m
//  Twittos
//
//  Created by François Blanc on 21/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import "FBUser.h"
#import "FMResultSet.h"

@implementation FBUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userName":@"name",
             @"userSreenName":@"screen_name",
             @"userLocation":@"location",
             @"userDescription":@"description",
             @"userWebSite":@"url",
             @"userImageURL":@"profile_image_url_https",
             @"userBackgroundImageURL":@"profile_background_image_url_https",
             @"userID":@"id_str",
             @"userFollowersCount":@"followers_count",
             @"userFriendsCount":@"friends_count",
             @"userLikesCount":@"favourites_count",
             };
}

- (instancetype)initWithResultSet:(FMResultSet *)set
{
    self = [super init];
    if (self)
    {
        self.userID = [set stringForColumn:@"userID"];
        self.userFollowersCount = [[set stringForColumn:@"userFollowersCount"] integerValue];
        self.userFriendsCount = [[set stringForColumn:@"userFriendsCount"] integerValue];
        self.userLikesCount = [[set stringForColumn:@"userLikesCount"] integerValue];
        self.userName = [set stringForColumn:@"userName"];
        self.userSreenName = [set stringForColumn:@"userSreenName"];
        self.userLocation = [set stringForColumn:@"userLocation"];
        self.userDescription = [set stringForColumn:@"userDescription"];
        self.userWebSite = [set stringForColumn:@"userWebSite"];
        self.userImageURL = [set stringForColumn:@"userImageURL"];
        self.userBackgroundImageURL = [set stringForColumn:@"userBackgroundImageURL"];
    }
    return self;
}

@end
