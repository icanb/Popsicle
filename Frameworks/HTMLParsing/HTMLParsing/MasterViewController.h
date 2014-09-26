//
//  MasterViewController.h
//  HTMLParsing
//
//  Created by Matt Galloway on 19/05/2012.
//  Copyright (c) 2012 Swipe Stack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
