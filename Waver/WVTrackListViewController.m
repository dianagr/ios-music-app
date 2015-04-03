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
@end

@implementation WVTrackListViewController

- (void)viewWillAppear:(BOOL)animated {
  if (!self.tracks.lastObject) {
    [self _loadTracks];
  }
}

- (void)loadView {
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.tableView.estimatedRowHeight = 70;
  [super loadView];
  
  UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
  UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
  blurView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.progressOverlayView insertSubview:blurView atIndex:0];
  
  NSDictionary *views = NSDictionaryOfVariableBindings(blurView);
  [self.progressOverlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blurView]|" options:0 metrics:nil views:views]];
  [self.progressOverlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blurView]|" options:0 metrics:nil views:views]];
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
      [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
  }];
}

- (void)_updateProgress:(NSTimer *)timer {
  [self.progressOverlayView setProgress:(self.audioPlayer.currentTime / self.audioPlayer.duration)];
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
  return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *track = self.tracks[indexPath.row];
  NSString *streamURL = track[[WVTrack streamURLKey]];
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
