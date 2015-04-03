//
//  WVTrackListViewController.m
//  Waver
//
//  Created by Diana Gren on 4/2/15.
//  Copyright (c) 2015 Diana Gren. All rights reserved.
//

#import "WVTrackListViewController.h"
#import "WVTrackTableViewCell.h"
#import "WVTrack.h"
#import "WVProgressOverlayView.h"

#import <SCUI.h>
#import <AVFoundation/AVFoundation.h>

@interface WVTrackListViewController () <AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource, WVProgressOverlayViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet WVProgressOverlayView *progressOverlayView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressOverlayViewBottomConstraint;

@property (copy, nonatomic) NSArray *tracks;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSTimer *progressUpdateTimer;
@property (strong, nonatomic) NSDictionary *currentTrack;
@end

@implementation WVTrackListViewController

- (void)viewWillAppear:(BOOL)animated {
  if (!self.tracks.lastObject) {
    [self _loadTracks];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.edgesForExtendedLayout = UIRectEdgeNone;
  self.progressOverlayView.delegate = self;
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
  [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
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

- (void)_updateProgress:(NSTimer *)timer {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSInteger index = [self.tracks indexOfObject:self.currentTrack];
    if (index != NSNotFound) {
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
      [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
  });
}

#pragma mark WVProgressOverlayViewDelegate

- (void)progressOverlayViewDidTogglePlay:(WVProgressOverlayView *)overlayView {
  if ([self.audioPlayer isPlaying]) {
    [self.audioPlayer pause];
  } else {
    [self.audioPlayer play];
  }
  [self.progressOverlayView setPlaying:[self.audioPlayer isPlaying]];
}

# pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  WVTrackTableViewCell *cell = (WVTrackTableViewCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WVTrackTableViewCell class]) forIndexPath:indexPath];
  NSDictionary *track = self.tracks[indexPath.row];
  [cell setTrack: track];
  if ([self.currentTrack isEqualToDictionary:track]) {
    [cell setProgress:(self.audioPlayer.currentTime / self.audioPlayer.duration)];
  } else {
    [cell setProgress:0];
  }
  return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  self.currentTrack = self.tracks[indexPath.row];
  NSString *streamURL = self.currentTrack[[WVTrack streamURLKey]];
  [self.audioPlayer stop];
  self.audioPlayer = nil;
  [self.progressUpdateTimer invalidate];
  SCAccount *account = [SCSoundCloud account];
  [SCRequest performMethod:SCRequestMethodGET onResource:[NSURL URLWithString:streamURL] usingParameters:nil withAccount:account sendingProgressHandler:nil responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
    NSError *playerError;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:responseData error:&playerError];
    if (playerError) {
      NSLog(@"Player error: %@", playerError.localizedDescription);
    }
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
    self.progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(_updateProgress:) userInfo:nil repeats:YES];
    [self.progressOverlayView setPlaying:YES];
  }];
}

@end
