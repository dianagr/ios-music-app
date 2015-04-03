//
//  WVProgressOverlayView.m
//  Waver
//
//  Created by Diana Gren on 4/3/15.
//  Copyright (c) 2015 Diana Gren. All rights reserved.
//

#import "WVProgressOverlayView.h"

@interface WVProgressOverlayView ()
@property (weak, nonatomic) IBOutlet UIButton *togglePlayButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@end

@implementation WVProgressOverlayView

- (IBAction)didTapTogglePlayButton:(UIButton *)sender  {
  id<WVProgressOverlayViewDelegate> delegate = self.delegate;
  [delegate progressOverlayViewDidTogglePlay:self];
}

- (void)setPlaying:(BOOL)playing {
  NSString *title = playing ? @"Stop" : @"Play";
  [self.togglePlayButton setTitle:title forState:UIControlStateNormal];
}

- (void)setProgress:(CGFloat)progress {
  [self.progressView setProgress:progress animated:YES];
}

@end
