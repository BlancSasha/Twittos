//
//  FBUser.m
//  Twittos
//
//  Created by François Blanc on 21/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import "FBUser.h"

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
             @"userID":@"id",
             @"userFollowersCount":@"followers_count",
             @"userFriendsCount":@"friends_count",
             @"userLikesCount":@"favourites_count",
             };
}

@end
