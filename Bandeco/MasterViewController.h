//
//  MasterViewController.h
//  Bandeco
//
//  Created by Pedro Góes on 30/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;
@class SecondViewController;

@interface MasterViewController : UITableViewController {
    NSArray *keysDaysOfWeek;
}

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) SecondViewController *secondViewController;
@property (strong, nonatomic) NSMutableArray *daysOfWeek;
@property (strong, nonatomic) NSDictionary *menu;

@end
