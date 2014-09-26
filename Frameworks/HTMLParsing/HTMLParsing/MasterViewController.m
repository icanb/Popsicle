//
//  MasterViewController.m
//  HTMLParsing
//
//  Created by Matt Galloway on 19/05/2012.
//  Copyright (c) 2012 Swipe Stack Ltd. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

#import "TFHpple.h"
#import "Tutorial.h"
#import "Contributor.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
    NSMutableArray *_contributors;
}
@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;

- (void)loadTutorials {
    // 1
    NSURL *tutorialsUrl = [NSURL URLWithString:@"http://www.raywenderlich.com/tutorials"];
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];
    
    // 2
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    
    // 3
    NSString *tutorialsXpathQueryString = @"//div[@class='content-wrapper']/ul/li/a";
    NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
    
    // 4
    NSMutableArray *newTutorials = [[NSMutableArray alloc] initWithCapacity:0];
    for (TFHppleElement *element in tutorialsNodes) {
        // 5
        Tutorial *tutorial = [[Tutorial alloc] init];
        [newTutorials addObject:tutorial];
        
        // 6
        tutorial.title = [[element firstChild] content];
        
        // 7
        tutorial.url = [element objectForKey:@"href"];
    }
    
    // 8
    _objects = newTutorials;
    [self.tableView reloadData];
}

- (void)loadContributors {
    // 1
    NSURL *contributorsUrl = [NSURL URLWithString:@"http://www.raywenderlich.com/about"];
    NSData *contributorsHtmlData = [NSData dataWithContentsOfURL:contributorsUrl];
    
    // 2
    TFHpple *contributorsParser = [TFHpple hppleWithHTMLData:contributorsHtmlData];
    
    // 3
    NSString *contributorsXpathQueryString = @"//ul[@class='team-members']/li";
    NSArray *contributorsNodes = [contributorsParser searchWithXPathQuery:contributorsXpathQueryString];
    
    // 4
    NSMutableArray *newContributors = [[NSMutableArray alloc] initWithCapacity:0];
    for (TFHppleElement *element in contributorsNodes) {
        // 5
        Contributor *contributor = [[Contributor alloc] init];
        [newContributors addObject:contributor];
        
        // 6
        for (TFHppleElement *child in element.children) {
            if ([child.tagName isEqualToString:@"img"]) {
                // 7
                @try {
                    contributor.imageUrl = [@"http://www.raywenderlich.com" stringByAppendingString:[child objectForKey:@"src"]];
                }
                @catch (NSException *e) {}
            } else if ([child.tagName isEqualToString:@"h3"]) {
                // 8
                contributor.name = [[child firstChild] content];
            }
        }
    }
    
    // 9
    _contributors = newContributors;
    [self.tableView reloadData];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
    }
    return self;
}
							
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadTutorials];
    [self loadContributors];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - Table View

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Tutorials";
            break;
        case 1:
            return @"Contributors";
            break;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return _objects.count;
            break;
        case 1:
            return _contributors.count;
            break;
    }
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == 0) {
        Tutorial *thisTutorial = [_objects objectAtIndex:indexPath.row];
        cell.textLabel.text = thisTutorial.title;
        cell.detailTextLabel.text = thisTutorial.url;
    } else if (indexPath.section == 1) {
        Contributor *thisContributor = [_contributors objectAtIndex:indexPath.row];
        cell.textLabel.text = thisContributor.name;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.detailViewController) {
        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    }
    NSDate *object = [_objects objectAtIndex:indexPath.row];
    self.detailViewController.detailItem = object;
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

@end
