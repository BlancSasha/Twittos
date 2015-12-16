//
//  FBTweetManager.h
//  Twittos
//
//  Created by François Blanc on 08/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBTweetManager : NSObject

- (void) fetchTweetswithBlock:(void(^)(NSArray *,NSError *))block;

- (void) authenticationWithencoded64authorizationHeader:(NSString *)encoded64authorizationHeader
                                               andBlock:(void(^)(NSString *,NSError *))authentBlock;


@end
