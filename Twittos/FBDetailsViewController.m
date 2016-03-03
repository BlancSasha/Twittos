//
//  FBDetailsViewController.m
//  Twittos
//
//  Created by François Blanc on 26/10/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import "FBDetailsViewController.h"
#import "FBUser.h"
#import "FBTweetManager.h"
#import "FBTweet.h"
#import "FBImageManager.h"

#import "Masonry.h"
#import <MapKit/MapKit.h>


@interface FBDetailsViewController () <MKMapViewDelegate, FBImageManagerDelegate> {
   // CLLocationCoordinate2D tweetLocation;
}

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIImageView *userImageView;
@property (strong, nonatomic) UIImageView *userBackGroundImageView;
@property (strong,nonatomic) UILabel *userDescriptionLabel;
@property (strong,nonatomic) UILabel *websiteLabel;
@property (strong, nonatomic) UILabel *followersLabel;
@property (strong, nonatomic) UILabel *friendsLabel;
@property (strong, nonatomic) MKMapView *mapView;

@property (nonatomic, strong) CLLocation *tweetLocation;
@property (strong, nonatomic) MKPointAnnotation *tweetLocationAnnot;
@property (strong, nonatomic) MKPolygon *tweetRegionAnnot;

@end


@implementation FBDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [[FBImageManager sharedInstance] addDelegate:self];
    
    ////////////////////
    // image view
    ////////////////////
    
    self.userImageView = [[UIImageView alloc] init];
    [self.userImageView setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:self.userImageView];
    
    ////////////////////
    // background image view
    ////////////////////
    
    self.userBackGroundImageView = [[UIImageView alloc] init];
    [self.userBackGroundImageView setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:self.userBackGroundImageView];
    [self.view sendSubviewToBack:self.userBackGroundImageView];
    

    ////////////////////
    // nameLabel
    ////////////////////

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.numberOfLines = 2;
    self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.view addSubview:self.nameLabel];
    
    
    ////////////////////
    // descriptionLabel
    ////////////////////

    self.userDescriptionLabel = [[UILabel alloc] init];
    self.userDescriptionLabel.numberOfLines = 0;
    self.userDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.view addSubview:self.userDescriptionLabel];
 
    ////////////////////
    // webSiteLabel
    ////////////////////
    
    self.websiteLabel = [[UILabel alloc] init];
    self.websiteLabel.numberOfLines = 0;
    self.websiteLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.view addSubview:self.websiteLabel];

    ////////////////////
    // followersLabel
    ////////////////////
    
    self.followersLabel = [[UILabel alloc] init];
    self.followersLabel.numberOfLines = 0;
    self.followersLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.view addSubview:self.followersLabel];

    ////////////////////
    // friendsLabel
    ////////////////////
    
    self.friendsLabel = [[UILabel alloc] init];
    self.friendsLabel.numberOfLines = 0;
    self.friendsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.view addSubview:self.friendsLabel];

    ////////////////////
    // mapView
    ////////////////////
    
    //self.tweetLocation = [[CLLocation alloc] init];
    self.mapView = [[MKMapView alloc] init];
    [self.mapView setDelegate:self];
    [self updateMapAnnotationsFromArrayOfCoordinates:self.tweet.coordinates];
    [self.view addSubview:self.mapView];
    
    [self updateViewConstraints];
    [self fillviews];
}

-(void)dealloc
{
    [[FBImageManager sharedInstance] removeDelegate:self];
}

- (void)fillviews
{
    ////////////////////
    // image view
    ////////////////////
    
    UIImage *userImage = [[FBImageManager sharedInstance] getImage:FBTweetImageUser
                                                   inCacheForTweet:self.tweet
                                                            orUser:self.userDetails];
    if(userImage)
    {
        [self.userImageView setImage:userImage];
    }
 
    ////////////////////
    // background image view
    ////////////////////
    
    UIImage *backgroundImage = [[FBImageManager sharedInstance] getImage:FBTweetBackgroundImageUser
                                                         inCacheForTweet:self.tweet
                                                                  orUser:self.userDetails];
    
    if(backgroundImage)
    {
        [self.userBackGroundImageView setImage:backgroundImage];
    }
    

    ////////////////////
    // nameLabel
    ////////////////////
    
    NSAttributedString *attrName =
    [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"%@\n",self.userDetails.userName]
                                    attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16]}];
    
    NSAttributedString *attrScreenName =
    [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"@%@",self.userDetails.userSreenName]
                                    attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],
                                                 NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    
    NSMutableAttributedString *attrNameAndScreenName = [[NSMutableAttributedString alloc] init];
    [attrNameAndScreenName appendAttributedString:attrName];
    [attrNameAndScreenName appendAttributedString:attrScreenName];
    
    [self.nameLabel setAttributedText:attrNameAndScreenName];

    ////////////////////
    // descriptionLabel
    ////////////////////
    
    NSAttributedString *attrDescriptionLabel =
    [[NSAttributedString alloc] initWithString:self.userDetails.userDescription
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    [self.userDescriptionLabel setAttributedText:attrDescriptionLabel];

    ////////////////////
    // webSiteLabel
    ////////////////////
    
    NSAttributedString *attrWebsiteURL =
    [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"%@",self.userDetails.userWebSite]
                                    attributes:@{NSForegroundColorAttributeName:[UIColor blueColor],
                                                 NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    NSAttributedString *attrMyWebsite =
    [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"My Website : "]
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    
    NSMutableAttributedString *attrMyWebsiteFull = [[NSMutableAttributedString alloc] init];
    [attrMyWebsiteFull appendAttributedString:attrMyWebsite];
    [attrMyWebsiteFull appendAttributedString:attrWebsiteURL];
    
    [self.websiteLabel setAttributedText:attrMyWebsiteFull];

    ////////////////////
    // followersLabel
    ////////////////////
    
    NSAttributedString *attrFollowers =
    [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"%i",self.userDetails.userFollowersCount]
                                    attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12]}];
    NSAttributedString *attrFollowersCount =
    [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@" followers"]
                                    attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],
                                                 NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    
    NSMutableAttributedString *attrFollowersFull = [[NSMutableAttributedString alloc] init];
    [attrFollowersFull appendAttributedString:attrFollowers];
    [attrFollowersFull appendAttributedString:attrFollowersCount];
    
    [self.followersLabel setAttributedText:attrFollowersFull];

    ////////////////////
    // FriendsLabel
    ////////////////////
    
    NSAttributedString *attrFriends =
    [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"%i",self.userDetails.userFriendsCount]
                                    attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12]}];
    NSAttributedString *attrFriendsCount =
    [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@" following"]
                                    attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],
                                                 NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    
    NSMutableAttributedString *attrFriendsFull = [[NSMutableAttributedString alloc] init];
    [attrFriendsFull appendAttributedString:attrFriends];
    [attrFriendsFull appendAttributedString:attrFriendsCount];
    
    [self.friendsLabel setAttributedText:attrFriendsFull];

}

- (void)updateMapAnnotationsFromArrayOfCoordinates:(NSArray *)coordinates
{
    NSArray *myCoordinates = coordinates[0];
    CLLocationCoordinate2D *polygonCoordinates = calloc((myCoordinates.count),sizeof(CLLocationCoordinate2D));
    double latitude = 0;
    double longitude = 0;
    int i = 0;
    for (NSArray *pointCoordinate in myCoordinates)
    {
        latitude = latitude + [pointCoordinate[1] doubleValue]/myCoordinates.count;
        longitude = longitude + [pointCoordinate[0] doubleValue]/myCoordinates.count;
        
        CLLocationCoordinate2D pointOfPolygon;
        pointOfPolygon.latitude = [pointCoordinate[1] doubleValue];
        pointOfPolygon.longitude = [pointCoordinate[0] doubleValue];
        
        polygonCoordinates[i] = pointOfPolygon;
        i++;
    }
    
    CLLocationCoordinate2D pointLocation;
    pointLocation.latitude = latitude;
    pointLocation.longitude = longitude;

    // remove previous annotations
    [self.mapView removeAnnotation:self.tweetLocationAnnot];
    [self.mapView removeAnnotation:self.tweetRegionAnnot];
    self.tweetLocationAnnot = nil;
    self.tweetRegionAnnot = nil;
    
    // create new annotations
    if (myCoordinates.count >1)
    {
        self.tweetRegionAnnot = [MKPolygon polygonWithCoordinates:polygonCoordinates
                                                            count:myCoordinates.count];
        [self.mapView addOverlay:self.tweetRegionAnnot];
    }
    
    self.tweetLocationAnnot = [[MKPointAnnotation alloc] init];
    [self.tweetLocationAnnot setCoordinate:pointLocation];
    [self.mapView addAnnotation:self.tweetLocationAnnot];

    
    // recenter and zoom map
    [self.mapView setCenterCoordinate:pointLocation];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(pointLocation, 20000, 20000);
    [self.mapView setRegion:region animated:YES];
}


- (void)updateViewConstraints
{
    [super updateViewConstraints];
    // Contrainte de l'avatar de l'utilisateur
    [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom).offset(10);
        make.left.equalTo(@10);
        make.height.equalTo(@50);
        make.width.equalTo(@50);
    }];

    [self.userBackGroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom).offset(10);
        make.left.equalTo(@10);
        make.height.equalTo(@50);
        make.right.equalTo(@(-10));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userImageView.mas_bottom).offset(10);
        make.left.equalTo(self.userImageView.mas_left);
        make.right.equalTo(@(-10));
    }];
    
    [self.userDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(10);
        make.left.equalTo(self.userImageView.mas_left);
        make.right.equalTo(@(-10));
    }];

    [self.websiteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userDescriptionLabel.mas_bottom).offset(10);
        make.left.equalTo(self.userImageView.mas_left);
        make.right.equalTo(@(-10));
    }];

    [self.followersLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.websiteLabel.mas_bottom).offset(10);
        make.left.equalTo(self.userImageView.mas_left);
        make.right.equalTo(self.view.mas_centerX);
    }];
    
    [self.friendsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.websiteLabel.mas_bottom).offset(10);
        make.left.equalTo(self.view.mas_centerX);
        make.right.equalTo(@(-10));
    }];

    ////////////////////
    // mapView
    ////////////////////
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.followersLabel.mas_bottom).offset(10);
        make.bottom.equalTo(@(-10));
        make.left.equalTo(@10);
        make.right.equalTo(@(-10));
    }];
}

- (void)setTweet:(FBTweet *)tweet
{
    self->_tweet = tweet; // pourquoi je suis obligé de faire comme ça?
    if(tweet.retweetUser){
        self.userDetails = tweet.retweetUser;
    }else{
        self.userDetails = tweet.tweetUser;
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolygon class]])
    {
        MKPolygon *polygon = (MKPolygon *)overlay;
        MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:polygon];
        [polygonView setLineWidth:3];
        [polygonView setFillColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
        [polygonView setStrokeColor:[UIColor blackColor]];
        return polygonView;
    }
    return nil;
}

-(void)didFinishDownloadingImage:(UIImage *)image forURL:(NSString *)URL
{
    if([self.userDetails.userImageURL isEqualToString:URL])
    {
        [self.userImageView setImage:image];
    }else if ([self.userDetails.userBackgroundImageURL isEqualToString:URL])
    {
        [self.userBackGroundImageView setImage:image];
    }
}

@end
