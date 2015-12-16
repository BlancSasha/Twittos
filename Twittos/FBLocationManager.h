//
//  FBLocationManager.h
//  Twittos
//
//  Created by François Blanc on 08/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@protocol FBLocationManagerDelegate <NSObject>

@end


@interface FBLocationManager : NSObject

@property (weak, nonatomic) id<FBLocationManagerDelegate> delegate;

+ (FBLocationManager *) instance;

@end
