//
//  MasterViewController.m
//  Bandeco
//
//  Created by Pedro Góes on 30/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "SecondViewController.h"
#import "DownloadController.h"

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize secondViewController = _secondViewController;
@synthesize daysOfWeek = _daysOfWeek;
@synthesize menu = _menu;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Day", @"Day of the week");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
        
        //NSLog(@"%@", [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:[[NSLocale currentLocale] identifier]]);
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self loadData];
    
    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"About", @"About the developer") 
                                                                     style:UIBarButtonItemStyleBordered target:self action:@selector(about)];
    self.navigationItem.leftBarButtonItem = aboutButton;

    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateData)];
    self.navigationItem.rightBarButtonItem = reloadButton;
    
    self.daysOfWeek = [[NSMutableArray alloc] initWithObjects:
                         NSLocalizedString(@"Monday", @"Monday"), 
                         NSLocalizedString(@"Tuesday", @"Tuesday"),
                         NSLocalizedString(@"Wednesday", @"Wednesday"),
                         NSLocalizedString(@"Thursday", @"Thursday"),
                         NSLocalizedString(@"Friday", @"Friday"),
                         NSLocalizedString(@"Saturday", @"Saturday"),
                         nil];   

    
    keysDaysOfWeek = [[NSArray alloc] initWithObjects:@"segunda", @"terca", @"quarta", @"quinta", @"sexta", @"sabado", nil];
    
    [self checkDate];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - IO Methods

- (void)saveData {
   [NSKeyedArchiver archiveRootObject:self.menu toFile:[[NSHomeDirectory() stringByAppendingPathComponent: @"Documents"] stringByAppendingPathComponent:ARQUIVO]];
    

}

- (void)loadData {
    id root = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSHomeDirectory() stringByAppendingPathComponent: @"Documents"] stringByAppendingPathComponent:ARQUIVO]];
    if (root) {
        self.menu = root;
    } else {
        self.menu = nil;
    }
}

#pragma mark - User Methods

- (void)updateData {
    DownloadController * downloadController = [DownloadController sharedDownloadController];
    downloadController.delegate = self;
    [downloadController addURL:CACHE_PADRAO_URL savingAs:CACHE_PADRAO_ARQUIVO];
}

- (void)about {
	
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:NSLocalizedString(@"About", @"About the developer")  
						  message:NSLocalizedString(@"AboutMessage", @"Message relating to the dev")   //@"Este programa calcula os valores de a e b incluindo seus erros (deltas) pelo Método dos Mínimos Quadrados.\n\nDesenvolvedor: Pedro P. M. Góes\n\nVersão atual: 1.2\nRelease: Março/2012\n\nAgora também disponível para Android!"
						  delegate:self 
						  cancelButtonTitle:@"Ok" 
						  otherButtonTitles:nil];
	[alert show];
}

- (void)checkDate {
    if (!self.menu) {
        [self updateData];
        return;
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yyyy"];
    NSDate *dateUpdate = [df dateFromString:[[[self.menu objectForKey:@"restaurante"] objectForKey:@"sabado"] objectForKey:@"data"]];
    dateUpdate = [dateUpdate dateByAddingTimeInterval:60*60*24];
    NSDate  *now = [NSDate date];
    
    // The receiver is later in time than the update's time 
    if ([now compare:dateUpdate] == NSOrderedDescending) {
        [self updateData];
    }
    
    
    
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_daysOfWeek count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [_daysOfWeek objectAtIndex:[indexPath row]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (!self.secondViewController) {
        self.secondViewController = [[SecondViewController alloc] initWithNibName:nil bundle:nil];
    }
    
    if ([indexPath row] == [_daysOfWeek count]-1) {
        self.secondViewController.lastDayOfTheWeek = YES;
    } else {
        self.secondViewController.lastDayOfTheWeek = NO;
    }
    
    self.secondViewController.title = [self.daysOfWeek objectAtIndex:[indexPath row]];
    self.secondViewController.infoMenu = [[self.menu objectForKey:@"restaurante"] objectForKey:[keysDaysOfWeek objectAtIndex:[indexPath row]]];
    
    // Since we're keeping a pointer to it, we need to force the (possible) update
    [self.secondViewController.tableView reloadData];
    
    [self.navigationController pushViewController:self.secondViewController animated:YES];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    if (!self.detailViewController) {
	        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil];
	    }
	    self.detailViewController.detailItem = object;
        [self.navigationController pushViewController:self.detailViewController animated:YES];
    } else {
        self.detailViewController.detailItem = object;
    }
     */
}

@end
