//
//  WVTrackTableViewCell.m
//  Waver
//
//  Created by Diana Gren on 4/2/15.
//  Copyright (c) 2015 Diana Gren. All rights reserved.
//

#import "WVTrackTableViewCell.h"

@interface WVTrackTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@end

@implementation WVTrackTableViewCell
@synthesize imageView=_imageView;

- (void)setTrack:(NSDictionary *)track {
  self.titleLabel.text = track[@"title"];
  self.durationLabel.text = [[self class] _durationForMilliseconds:[track[@"duration"] floatValue]];
}

+ (NSString *)_durationForMilliseconds:(CGFloat)milliseconds {
  NSInteger seconds = milliseconds / 1000;
  NSInteger minutes = seconds / 60;
  NSInteger hours = minutes / 60;
  if (hours > 0) {
    return [NSString stringWithFormat:@"%d:%d:%d", hours, (minutes >= 0 ?: 0), (seconds >= 0 ?: 0)];
  } else if (minutes > 0) {
    return [NSString stringWithFormat:@"%d:%d", minutes, (seconds >= 0 ?: 0)];
  }
  return [NSString stringWithFormat:@"%d", (seconds >= 0 ?: 0)];
}

@end
