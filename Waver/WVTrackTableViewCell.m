//
//  WVTrackTableViewCell.m
//  Waver
//
//  Created by Diana Gren on 4/2/15.
//  Copyright (c) 2015 Diana Gren. All rights reserved.
//

#import "WVTrackTableViewCell.h"

#import "WVImageLoader.h"
#import "WVTrack.h"

@interface WVTrackTableViewCell () <WVImageLoaderDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@property (strong, nonatomic) WVImageLoader *imageLoader;
@end

@implementation WVTrackTableViewCell
@synthesize imageView=_imageView;

- (WVImageLoader *)imageLoader {
  if (!_imageLoader) {
    _imageLoader = [[WVImageLoader alloc] init];
    _imageLoader.delegate = self;
  }
  return _imageLoader;
}

- (void)prepareForReuse {
  self.imageView.image = nil;
}

- (void)setTrack:(NSDictionary *)track {
  self.titleLabel.text = track[[WVTrack titleKey]];
  self.durationLabel.text = [[self class] _durationForMilliseconds:[track[[WVTrack durationKey]] floatValue]];
  if (![track[[WVTrack artworkURLKey]] isKindOfClass:[NSNull class]]) {
    NSURL *imageURL = [NSURL URLWithString:track[[WVTrack artworkURLKey]]];
    [self.imageLoader loadImageWithURL:imageURL];
  }
}

- (void)setImage:(UIImage *)image {
  [UIView transitionWithView:self.imageView
                    duration:0.2f
                     options:UIViewAnimationOptionTransitionCrossDissolve
                  animations:^{
                    self.imageView.image = image;
                  } completion:NULL];
}

#pragma mark Private

+ (NSString *)_durationForMilliseconds:(CGFloat)milliseconds {
  NSInteger seconds = milliseconds / 1000;
  NSInteger minutes = seconds / 60;
  NSInteger hours = minutes / 60;
  
  if (hours > 0) {
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes % 60, seconds % 60];
  }
  return [NSString stringWithFormat:@"%02d:%02d", minutes % 60, seconds % 60];
}

#pragma mark WVImageLoaderDelegate

- (void)imageLoader:(WVImageLoader *)imageLoader didLoadImage:(UIImage *)image {
  self.imageView.image = image;
  [self.imageView setNeedsDisplay];
}

@end
