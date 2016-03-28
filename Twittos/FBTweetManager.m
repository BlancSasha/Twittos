//
//  FBTweetManager.m
//  Twittos
//
//  Created by François Blanc on 08/12/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import "FBTweetManager.h"
#import "FBTweet.h"
#import "FBUser.h"

#import "AFNetworking.h"

#import "Mantle.h"

#import <UIKit/UIKit.h>

#define CONSUMER_KEY @"VFCRLhL28sUUEKcPgR6WJ6Sib"
#define CONSUMER_SECRET @"lAlkRvL3aZFJjgnzbDxLQPvOADy1ZGAs9ocFTnQSwIYFNKK112"
#define TWEETS_COUNT 20

@interface FBTweetManager ()

@property (nonatomic, strong) NSString *bearerToken;

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) AFHTTPSessionManager *imageManager;

@end


@implementation FBTweetManager

- (instancetype)init
{
    self = [super init];
    
    if(self){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        [self.manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        [self.manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        
        self.imageManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
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
    NSDictionary *getParameters = @{@"screen_name":@"syan_me",
                                    @"count":@(TWEETS_COUNT),
                                    };
    
    [self.manager GET:@"https://api.twitter.com/1.1/statuses/user_timeline.json"
           parameters:getParameters
             progress:nil
              success:^(NSURLSessionTask * _Nonnull task, id  _Nonnull responseObject) {

                  NSError *err = nil;
                  
                  NSArray *tweets = [MTLJSONAdapter modelsOfClass:[FBTweet class] fromJSONArray:responseObject error:&err];
                  
                  if (err)
                      block(nil,err);
                  else
                      block(tweets,nil);
                  
              } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nonnull error) {
                  
                  NSInteger statusCode = ((NSHTTPURLResponse *)task.response).statusCode; //pas authentifié
                  
                  if(statusCode == 400 || statusCode == 401)
                  {
                      [self authenticationWithBlock:^(NSError *error) {
                          if (error)
                          {
                              block(nil, error);
                          }
                          else
                          {
                              [self fetchTweetswithBlock:block];
                          }
                      }];
                  }
                  else
                  {
                      block(nil, error);
                  }
              }];
}

- (void) authenticationWithBlock:(void(^)(NSError *))authentBlock{

    NSString *authorizationHeader = [[NSString alloc] initWithFormat:@"%@:%@",CONSUMER_KEY,CONSUMER_SECRET];
    NSString *encoded64authorizationHeader = [[authorizationHeader dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    NSString *postHeader = [[NSString alloc] initWithFormat:@"Basic %@",encoded64authorizationHeader];
    NSDictionary *postParameters = @{@"grant_type":@"client_credentials"};
    
    [self.manager.requestSerializer setValue:postHeader forHTTPHeaderField:@"Authorization"];
    
    [self.manager POST:@"https://api.twitter.com/oauth2/token"
            parameters:postParameters
             progress :nil
               success:^(NSURLSessionTask * _Nonnull task, id  _Nonnull responseObject) {
        
        //NSLog(@"JSON : %@",responseObject);
        
        
        if ([[responseObject valueForKey:@"token_type"] isEqual:@"bearer"])
        {
            
            NSString *getHeader = [[NSString alloc] initWithFormat:@"Bearer %@",[responseObject valueForKey:@"access_token"]];

            // header d'authentification
            [self.manager.requestSerializer setValue:getHeader forHTTPHeaderField:@"Authorization"];
        }
        authentBlock(nil);

        
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error : %@",error);
        authentBlock (error);
    }];
}

-(void)getUserInfoFor:(NSString *)userID withBlock:(void(^)(FBUser *,NSError *))block
{
    NSDictionary *getParameters = @{@"user_id":userID};
    
    [self.manager GET:@"https://api.twitter.com/1.1/users/show.json"
           parameters:getParameters
             progress:nil
              success:^(NSURLSessionTask * _Nonnull task, id  _Nonnull responseObject) {
                  
                  NSLog(@"JSON : %@",task.response);
                  
                  NSError *err = nil;
                  
                  FBUser *user = [MTLJSONAdapter modelOfClass:[FBUser class] fromJSONDictionary:responseObject error:&err];
                  
                  if (err)
                      block(nil,err);
                  else
                      block(user,nil);
                  
              } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nonnull error) {
                  NSLog(@"Error : %@",error);
                  block(nil,error);
              }];
}

- (void) downloadImageWithURL:(NSString *)imageURL withBlock:(void(^)(UIImage *,NSString *,NSError *))imageBlock{
    [self.imageManager GET:imageURL
                parameters:nil
                  progress:nil
                   success:^(NSURLSessionTask * _Nonnull task, id  _Nonnull responseObject)
    {
        NSLog(@"%@",task.response);
        imageBlock(responseObject,imageURL,nil);
                       
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nonnull error)
    {
        NSLog(@"%@",error);
        imageBlock(nil,nil,error);
    }];
}


@end
