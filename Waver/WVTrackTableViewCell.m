//
//  WVTrackTableViewCell.m
//  Waver
//
//  Created by Diana Gren on 4/2/15.
//  Copyright (c) 2015 Diana Gren. All rights reserved.
//

#import "WVTrackTableViewCell.h"

#import "WVTrack.h"
@interface WVTrackTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@end

@implementation WVTrackTableViewCell
@synthesize imageView=_imageView;

- (void)setTrack:(NSDictionary *)track {
  self.titleLabel.text = track[[WVTrack titleKey]];
  self.durationLabel.text = [[self class] _durationForMilliseconds:[track[[WVTrack durationKey]] floatValue]];
}

+ (NSString *)_durationForMilliseconds:(CGFloat)milliseconds {
  NSInteger seconds = milliseconds / 1000;
  NSInteger minutes = seconds / 60;
  NSInteger hours = minutes / 60;
  
  if (hours > 0) {
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes % 60, seconds % 60];
  }
  return [NSString stringWithFormat:@"%02d:%02d", minutes % 60, seconds % 60];
}

@end
