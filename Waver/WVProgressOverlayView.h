//
//  WVProgressOverlayView.h
//  Waver
//
//  Created by Diana Gren on 4/3/15.
//  Copyright (c) 2015 Diana Gren. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WVProgressOverlayView;
@protocol WVProgressOverlayViewDelegate <NSObject>
- (void)progressOverlayViewDidTogglePlay:(WVProgressOverlayView *)overlayView;
@end

@interface WVProgressOverlayView : UIView

@property (weak, nonatomic) id<WVProgressOverlayViewDelegate> delegate;

- (void)setPlaying:(BOOL)playing;

- (void)setProgress:(CGFloat)progress;

- (void)setTrack:(NSDictionary *)track;

@end
