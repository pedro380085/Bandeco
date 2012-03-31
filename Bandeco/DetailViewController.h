//
//  DetailViewController.h
//  Bandeco
//
//  Created by Pedro Góes on 30/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (assign, nonatomic) NSDictionary *infoMenu;

@end
