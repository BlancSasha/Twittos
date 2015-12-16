//
//  FBTweet.h
//  Twittos
//
//  Created by François Blanc on 08/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Mantle.h"

@interface FBTweet : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSString *descr;

@end
