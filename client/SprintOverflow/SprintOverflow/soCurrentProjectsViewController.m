//
//  soCurrentProjectsViewController.m
//  SprintOverflow
//
//  Created by Faisal Memon on 02/10/2012.
//
//

#import "soCurrentProjectsViewController.h"
#import "soModel.h"
#import "soProject.h"
#import "soConstants.h"
#import "soUtil.h"

@interface soCurrentProjectsViewController ()

@end

@implementation soCurrentProjectsViewController

@synthesize orientation=_orientation;

- (void)initController
{
    _model = [soModel sharedInstance];
    _currentProjects = [_model getCurrentProjectsAsSnapshot];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self initController];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initController];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _currentProjects = [_model getCurrentProjectsAsSnapshot];
    [[soModel sharedInstance] setDelegateModelUpdate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[soModel sharedInstance] setDelegateModelUpdate:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithProjectOwnerEmail:(NSString*)project_owner_email WithSecurityToken:(NSString*)security_token
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initController];

        int unifiedIndex = [_model findProjectFromSnapshot:_currentProjects WithProjectOwner:project_owner_email WithSecurityToken:security_token];
        
        NSUInteger sectionOneIndexPosition[2] = {0, unifiedIndex};
        NSIndexPath* rowToSelect = [NSIndexPath indexPathWithIndexes:sectionOneIndexPosition length:2];
        [[self tableView]
         selectRowAtIndexPath:rowToSelect animated:YES scrollPosition:UITableViewScrollPositionNone];
        [[self tableView] scrollToRowAtIndexPath:rowToSelect atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    [self setOrientation:toInterfaceOrientation];
    [[self tableView] reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_currentProjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PerProjectCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    soCurrentProject *project = [_currentProjects objectAtIndex:indexPath.row];
    cell.textLabel.text = [project label];
    cell.detailTextLabel.text = [project detailLabel];
    switch ([project hint]) {
        case soSelectableProject:
        case soDiscoveryInProgress:
        case soDiscoveryFailed:
        default:
            // CONTINUE HERE by adding icons as needed
            break;
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - soModelUpdateProtocol

- (void) modelUpdated
{
    _currentProjects = [_model getCurrentProjectsAsSnapshot];
    [[self tableView] reloadData];
}
@end
