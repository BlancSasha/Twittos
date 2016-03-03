//
//  FBTweetManager.h
//  Twittos
//
//  Created by François Blanc on 08/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;
@class FBUser;

@interface FBTweetManager : NSObject

- (void) fetchTweetswithBlock:(void(^)(NSArray *,NSError *))block;

- (void) authenticationWithBlock:(void(^)(NSError *))authentBlock;

- (void) downloadImageWithURL:(NSString *)imageURL withBlock:(void(^)(UIImage *,NSString *,NSError *))imageBlock;

-(void)getUserInfoFor:(NSString *)userID withBlock:(void(^)(FBUser *,NSError *))block;

+ (instancetype)sharedManager;

@end
