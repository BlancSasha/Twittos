//
//  FBListViewController.m
//  Twittos
//
//  Created by François Blanc on 26/10/2015.
//  Copyright © 2015 François Blanc. All rights reserved.
//

#import "FBListViewController.h"
#import "FBDetailsViewController.h"

// FBListViewController se conforme à ces deux protocoles car il veut etre appelé par le tableView quand celui ci a besoin d'informations sur ce qu'il doit afficher, et veut informer qu'une interaction utilisateur est arrivée
@interface FBListViewController () <UITableViewDataSource, UITableViewDelegate>
// TableView
@property (atomic,    strong) UITableView *tableView;
// Liste de données
@property (nonatomic, strong) NSArray *tweets;
@end

@implementation FBListViewController

// Appelé quand le VC est **créé**, donc une seule fois par objet de ce type
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"List"];
    
    self.tweets = @[@"Item 1", @"Plop", @"Zou", @"Bi", @"Da"];
    
    // Création du tableView
    self.tableView = [[UITableView alloc] init];
    // dimensionnement à la taille de l'écran
    [self.tableView setFrame:self.view.bounds];
    // Définition du type de cellule que l'on souhaite utiliser. Ici des cellules basiques, que l'on demandera avec l'identifiant "cell"
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    // Lorsque le tableView a besoin de données, il fait appel à moi
    [self.tableView setDataSource:self];
    // Lorsque le tableView veut me fournir des informations (action utilisateur par exemple), il les donne à moi
    [self.tableView setDelegate:self];
    // Ajout du tableView à l'écran
    [self.view addSubview:self.tableView];
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
    NSString *tweet = self.tweets[indexPath.row];
    
    // On demande au tableView une cellule disponible avec l'identifiant "cell"
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    // On met à jour les éléments affichés par la cellule à l'aide de l'objet Tweet que l'on veut représenter
    [cell.textLabel setText:tweet];
    
    // On retourne la cellule au tableView pour qu'il puisse l'afficher
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Récupération du tweet associé à la cellule qui vient d'etre sélectionnée
    NSString *tweet = self.tweets[indexPath.row];
    
    // Création du VC qui va afficher les détails de ce tweet
    FBDetailsViewController *detailViewController = [[FBDetailsViewController alloc] init];
    
    // On dit au VC de détails quel tweet il va afficher
    [detailViewController setTweet:tweet];
    
    // On ajoute le VC de détail sur la pile de navigation, ce qui demande au navigationController de l'afficher à la place du VC actuel
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end