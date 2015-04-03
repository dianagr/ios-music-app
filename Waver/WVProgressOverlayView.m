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
@end

@implementation WVProgressOverlayView

- (IBAction)didTapTogglePlayButton:(UIButton *)sender  {
  id<WVProgressOverlayViewDelegate> delegate = self.delegate;
  [delegate progressOverlayViewDidTogglePlay:self];
}

- (void)setPlaying:(BOOL)playing {
  self.togglePlayButton.titleLabel.text = playing ? @"Stop" : @"Play";
}

@end
