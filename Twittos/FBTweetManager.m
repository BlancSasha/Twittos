//
//  FBTweetManager.m
//  Twittos
//
//  Created by François Blanc on 08/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import "FBTweetManager.h"

#import "FBTweet.h"

#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"

#import "Mantle.h"

#import <UIKit/UIKit.h>

#define CONSUMER_KEY @"VFCRLhL28sUUEKcPgR6WJ6Sib"
#define CONSUMER_SECRET @"lAlkRvL3aZFJjgnzbDxLQPvOADy1ZGAs9ocFTnQSwIYFNKK112"
#define TWEETS_COUNT 20

@interface FBTweetManager ()

@property (nonatomic, strong) NSString *bearerToken;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@property (nonatomic, strong) AFHTTPRequestOperationManager *imageManager;


@end


@implementation FBTweetManager

- (instancetype)init
{
    self = [super init];
    
    if(self){
        self.manager = [AFHTTPRequestOperationManager manager];
        [self.manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        [self.manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        
        self.imageManager = [AFHTTPRequestOperationManager manager];
        [self.imageManager setResponseSerializer:[AFImageResponseSerializer serializer]];
        [self.imageManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    }
    return self;
}

+ (instancetype)sharedManager{
    static dispatch_once_t onceToken;
    static FBTweetManager *sharedTweetManager;
    dispatch_once(&onceToken, ^{
        sharedTweetManager = [[FBTweetManager alloc] init];
    });
    return sharedTweetManager;
}


- (void) fetchTweetswithBlock:(void(^)(NSArray *,NSError *))block
{
    
    NSString *authorizationHeader = [[NSString alloc] initWithFormat:@"%@:%@",CONSUMER_KEY,CONSUMER_SECRET];
    
    NSString *encoded64authorizationHeader = [[authorizationHeader dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];

    [self authenticationWithencoded64authorizationHeader:encoded64authorizationHeader
                                                andBlock:^(NSString *bearerToken, NSError *err) {
        if (err)
        {
            NSLog(@"Error : %@",err);
            block(nil,err);
        }
        else
        {
            //NSDictionary *getHeaders = @{ @"Authorization":[NSString stringWithFormat:@"Bearer %@", self.bearerToken]};
            NSString *getHeader = [[NSString alloc] initWithFormat:@"Bearer %@",self.bearerToken];
            
            NSDictionary *getParameters = @{@"screen_name":@"syan_me",
                                            @"count":@(TWEETS_COUNT),
                                            };
            
            //[[self.manager.requestSerializer HTTPRequestHeaders] setValuesForKeysWithDictionary:getHeaders];
            
            [self.manager.requestSerializer setValue:getHeader forHTTPHeaderField:@"Authorization"];

            
            [self.manager GET:@"https://api.twitter.com/1.1/statuses/user_timeline.json"
                   parameters:getParameters
                      success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                          
                          NSLog(@"JSON : %@",operation.responseString);
                          
                          NSError *err = nil;
                          
                          NSArray *tweets = [MTLJSONAdapter modelsOfClass:[FBTweet class] fromJSONArray:responseObject error:&err];
                          
                          if (err)
                              block(nil,err);
                          else
                              block(tweets,nil);
                          
                      } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                          NSLog(@"Error : %@",error);
                          block(nil,error);
                      }];
        }
    }];
}

- (void) authenticationWithencoded64authorizationHeader:(NSString *)encoded64authorizationHeader
                                               andBlock:(void(^)(NSString *,NSError *))authentBlock{

    NSString *postHeader = [[NSString alloc] initWithFormat:@"Basic %@",encoded64authorizationHeader];
    
    NSDictionary *postParameters = @{@"grant_type":@"client_credentials"};
    
   // [[self.manager.requestSerializer HTTPRequestHeaders] setValuesForKeysWithDictionary:postHeaders];
    
    [self.manager.requestSerializer setValue:postHeader forHTTPHeaderField:@"Authorization"];
    
    [self.manager POST:@"https://api.twitter.com/oauth2/token" parameters:postParameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSLog(@"JSON : %@",responseObject);
        
        
        if ([[responseObject valueForKey:@"token_type"] isEqual:@"bearer"]){
            self.bearerToken = [responseObject valueForKey:@"access_token"];
        }
        authentBlock(self.bearerToken,nil);

        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"Error : %@",error);
        authentBlock (nil,error);
    }];

    
}

- (void) downloadImageWithURL:(NSString *)imageURL withBlock:(void(^)(UIImage *,NSError *))imageBlock{
    [self.imageManager GET:imageURL
                parameters:nil
                   success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject)
    {
        NSLog(@"%@",responseObject);
        imageBlock(responseObject,nil);
                       
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error)
    {
        NSLog(@"%@",error);
        imageBlock(nil,error);
    }];
}

@end
