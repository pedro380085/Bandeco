//
//  SecondViewController.h
//  Bandeco
//
//  Created by Pedro Góes on 30/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface SecondViewController : UITableViewController {
    BOOL lastDayOfTheWeek;
    NSArray *keysTime;
    NSMutableArray *typeOfMeal;
}

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (assign, nonatomic) BOOL lastDayOfTheWeek;
@property (assign, nonatomic) NSDictionary *infoMenu;

@end
