//
//  FBTweetImage.h
//  Twittos
//
//  Created by François Blanc on 05/01/2016.
//  Copyright © 2016 François Blanc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Mantle.h"

@interface FBTweetImage : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSString *tweetImageContentURL;
@property (nonatomic) NSInteger width;
@property (nonatomic) NSInteger height;

@end
