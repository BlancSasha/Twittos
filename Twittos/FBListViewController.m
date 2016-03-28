//
//  FBListViewController.m
//  Twittos
//
//  Created by François Blanc on 26/10/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import "FBListViewController.h"
#import "FBDetailsViewController.h"
#import "FBImageViewer.h"
#import "FBSQLManager.h"
#import "FBYapManager.h"

#import <JGProgressHUD/JGProgressHUD.h>
#import "A2DynamicDelegate.h"

#import "FBTweetCell.h"

// FBListViewController se conforme à ces deux protocoles car il veut etre appelé par le tableView quand celui ci a besoin d'informations sur ce qu'il doit afficher, et veut informer qu'une interaction utilisateur est arrivée
@interface FBListViewController () <UITableViewDataSource, UITableViewDelegate>
// TableView
@property (atomic,    strong) UITableView *tableView;
// Liste de données
@property (nonatomic, strong) NSArray *tweets;

@property (nonatomic, strong) UIBarButtonItem *updateButton;

@end

@implementation FBListViewController

// Appelé quand le VC est **créé**, donc une seule fois par objet de ce type
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"List"];
        
    // Création du tableView
    self.tableView = [[UITableView alloc] init];
    // dimensionnement à la taille de l'écran
    [self.tableView setFrame:self.view.bounds];
    [self.tableView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth)];
    // Définition du type de cellule que l'on souhaite utiliser. Ici des cellules basiques, que l'on demandera avec l'identifiant "cell"
    [self.tableView registerClass:FBTweetCell.class forCellReuseIdentifier:@"cell"];
    // Lorsque le tableView a besoin de données, il fait appel à moi
    [self.tableView setDataSource:self];
    // Lorsque le tableView veut me fournir des informations (action utilisateur par exemple), il les donne à moi
    [self.tableView setDelegate:self];
    // Ajout du tableView à l'écran
    [self.view addSubview:self.tableView];
    
    
    //Création du bouton de mise à jour
    self.updateButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                      target:self
                                                                      action:@selector(loadTweets)];
    self.navigationItem.rightBarButtonItem = self.updateButton;
    //[self.updateButton release]; pas nécessaire?

    [self loadTweets];
    
}

- (void)loadTweets
{
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    [[FBTweetManager sharedManager] fetchTweetswithBlock:^(NSArray *tweets, NSError *error) {
        
        if (error)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Database System"
                                                            message:@"The system seems to be offline. Choose which system of database you would like to use :"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Yapdatabase"
                                                  otherButtonTitles:@"FMDB", nil];
            
            // Get the dynamic delegate
            A2DynamicDelegate *dd = alertView.bk_dynamicDelegate;
            
            // Implement -alertViewShouldEnableFirstOtherButton:
            [dd implementMethod:@selector(alertViewShouldEnableFirstOtherButton:) withBlock:^(UIAlertView *alertView) {
                return YES;
            }];
            
            // Implement -alertView:willDismissWithButtonIndex:
            [dd implementMethod:@selector(alertView:willDismissWithButtonIndex:) withBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
                if(buttonIndex == 0)
                {
                    NSArray *yapTweets = [[FBYapManager sharedYapManager] getAllTweets];
                     NSLog(@"yapTweets :%@",yapTweets.description);
                     [self setTweets:yapTweets];
                }else{
                    NSArray *SQLtweets = [[FBSQLManager sharedSQLManager] getAllTweets];
                     NSLog(@"SQLTweets :%@",SQLtweets.description);
                     [self setTweets:SQLtweets];
                }
            }];
            
            alertView.delegate = dd;
            [alertView show];
            //NSLog(@"Error %@; %@", error, [error localizedDescription]);
        }
        else
        {
            [self setTweets:tweets];
            [[FBSQLManager sharedSQLManager] addTweetsInDatabase:tweets];
            [[FBYapManager sharedYapManager] addTweetsInDatabase:tweets];
        }
        
        [HUD dismiss];
    }];
}

- (void)setTweets:(NSArray *)tweets
{
    self->_tweets = tweets;
    // A chaque fois que la liste de tweets est mise à jour on force le tableView à se mettre à jour pour que les deux restent bien synchronisés
    [self.tableView reloadData];
}

#pragma mark - TableView DataSource & Delegate

// REQUIS
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}

// REQUIS
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Récupération du tweet
    FBTweet *tweet = self.tweets[indexPath.row];
    
    // On demande au tableView une cellule disponible avec l'identifiant "cell"
    FBTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    // On met à jour les éléments affichés par la cellule à l'aide de l'objet Tweet que l'on veut représenter
    [cell setTweet:tweet];
    
    cell.imageTappedBlock = ^(UIImage *image)
    {
        FBImageViewer *imageViewer = [[FBImageViewer alloc] init];
        [imageViewer setImage:image];
        [self.navigationController pushViewController:imageViewer animated:YES];
    };
    
    cell.linkTappedBlockFOrUser = ^(FBUser *user)
    {
        FBDetailsViewController *userDetailsViewController = [[FBDetailsViewController alloc] init];
        [userDetailsViewController setUserDetails:user];
        //FBTweet *fakeTweet = [[FBTweet alloc] init];
        //fakeTweet.tweetUser = user;
        //[userDetailsViewController setTweet:fakeTweet];
        [self.navigationController pushViewController:userDetailsViewController animated:YES];
    };
    
    // On retourne la cellule au tableView pour qu'il puisse l'afficher
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Récupération du tweet associé à la cellule qui vient d'etre sélectionnée
    FBTweet *tweet = self.tweets[indexPath.row]; // Ation
    
    // Création du VC qui va afficher les détails de ce tweet
    FBDetailsViewController *detailViewController = [[FBDetailsViewController alloc] init];
    
    // On dit au VC de détails quel tweet il va afficher
    [detailViewController setTweet:tweet];
    
    // On ajoute le VC de détail sur la pile de navigation, ce qui demande au navigationController de l'afficher à la place du VC actuel
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Récupération du tweet associé à la cellule
    FBTweet *tweet = self.tweets[indexPath.row];
    return [FBTweetCell cellHeightForTweet:tweet andWidth:tableView.bounds.size.width];
    //return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

@end
