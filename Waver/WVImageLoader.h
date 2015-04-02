//
//  WVImageLoader.h
//  Waver
//
//  Created by Diana Gren on 4/2/15.
//  Copyright (c) 2015 Diana Gren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class WVImageLoader;
@protocol WVImageLoaderDelegate <NSObject>
- (void)imageLoader:(WVImageLoader *)imageLoader didLoadImage:(UIImage *)image;
@end

@interface WVImageLoader : NSObject

@property (weak, nonatomic) id<WVImageLoaderDelegate> delegate;

- (void)loadImageWithURL:(NSURL *)url;
- (void)cancel;

@end
