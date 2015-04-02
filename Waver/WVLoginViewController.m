//
//  ViewController.m
//  Waver
//
//  Created by Diana Gren on 3/31/15.
//  Copyright (c) 2015 Diana Gren. All rights reserved.
//

#import "WVLoginViewController.h"
#import "WVTrackListViewController.h"

#import <SCUI.h>

NSString *const kSegueIDLoggedIn = @"LoggedIn";

@implementation WVLoginViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)didTapLoginButton:(UIButton *)sender {
  SCLoginViewControllerCompletionHandler completion = ^(NSError *error) {
    if (SC_CANCELED(error)) {
      NSLog(@"Canceled");
    } else if (error) {
      NSLog(@"Error: %@", error.localizedDescription);
    } else {
      [self performSegueWithIdentifier:kSegueIDLoggedIn sender:self];
    }
  };
  [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
    SCLoginViewController *viewController = [SCLoginViewController loginViewControllerWithPreparedURL:preparedURL completionHandler:completion];
    [self presentViewController:viewController animated:YES completion:nil];
  }];
}

@end
