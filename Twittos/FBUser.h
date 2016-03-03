//
//  FBUser.h
//  Twittos
//
//  Created by François Blanc on 21/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Mantle.h"
@class FMResultSet;


@interface FBUser : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userSreenName;
@property (strong, nonatomic) NSString *userLocation;
@property (strong, nonatomic) NSString *userDescription;
@property (strong, nonatomic) NSString *userWebSite;
@property (strong, nonatomic) NSString *userImageURL;
@property (strong, nonatomic) NSString *userBackgroundImageURL;

@property (strong, nonatomic) NSString *userID;
@property (nonatomic) NSInteger userFollowersCount;
@property (nonatomic) NSInteger userFriendsCount;
@property (nonatomic) NSInteger userLikesCount;

- (instancetype)initWithResultSet:(FMResultSet *)set;


@end
