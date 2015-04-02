//
//  WVTrackListViewController.m
//  Waver
//
//  Created by Diana Gren on 4/2/15.
//  Copyright (c) 2015 Diana Gren. All rights reserved.
//

#import "WVTrackListViewController.h"

#import <SCUI.h>
#import <AVFoundation/AVFoundation.h>

@interface WVTrackListViewController () <AVAudioPlayerDelegate>
@property (copy, nonatomic) NSArray *tracks;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@end

@implementation WVTrackListViewController

- (void)viewWillAppear:(BOOL)animated {
  if (!self.tracks.lastObject) {
    [self _loadTracks];
  }
}

- (void)_loadTracks {
  SCAccount *account = [SCSoundCloud account];
  if (!account) {
    return;
  }

  NSURL *resourceURL = [NSURL URLWithString:@"https://api.soundcloud.com/users/kygo/tracks"];
  [SCRequest performMethod:SCRequestMethodGET onResource:resourceURL usingParameters:nil withAccount:account sendingProgressHandler:nil responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
    NSError *jsonError = nil;
    if (error) {
      NSLog(@"Error: %@", error.localizedDescription);
      return;
    }
    NSJSONSerialization *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
    if (jsonError) {
      NSLog(@"JSON error %@", jsonError.localizedDescription);
      return;
    } else if ([jsonResponse isKindOfClass:[NSArray class]]) {
      self.tracks = (NSArray *)jsonResponse;
      [self.tableView reloadData];
    }
  }];
}

# pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell" forIndexPath:indexPath];
  NSDictionary *track = self.tracks[indexPath.row];
  cell.textLabel.text = track[@"title"];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *track = self.tracks[indexPath.row];
  NSString *streamURL = track[@"stream_url"];
  [self.audioPlayer stop];
  self.audioPlayer = nil;
  SCAccount *account = [SCSoundCloud account];
  [SCRequest performMethod:SCRequestMethodGET onResource:[NSURL URLWithString:streamURL] usingParameters:nil withAccount:account sendingProgressHandler:nil responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
    NSError *playerError;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:responseData error:&playerError];
    if (playerError) {
      NSLog(@"Player error: %@", playerError.localizedDescription);
    }
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
  }];
}

@end
