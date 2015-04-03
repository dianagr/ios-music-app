//
//  WVImageLoader.m
//  Waver
//
//  Created by Diana Gren on 4/2/15.
//  Copyright (c) 2015 Diana Gren. All rights reserved.
//

#import "WVImageLoader.h"

@interface WVImageLoader ()
@property (strong, nonatomic) NSCache *imageCache;
@property (strong, nonatomic) NSURLSessionDataTask *task;
@end

@implementation WVImageLoader

- (void)loadImageWithURL:(NSURL *)url {
  UIImage *image = [self.imageCache objectForKey:url];
  if (image) {
    [self _didLoadImage:image];
  } else {
    [self _loadImageFromURL:url];
  }
}

- (void)cancel {
  [self.task cancel];
}

- (NSCache *)imageCache {
  if (!_imageCache) {
    _imageCache = [[NSCache alloc] init];
  }
  return _imageCache;
}

#pragma mark Private

- (void)_loadImageFromURL:(NSURL *)url {
  NSURLSession *session = [NSURLSession sharedSession];
  [self.task cancel];
  self.task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
      NSLog(@"Image loading error: %@", error.localizedDescription);
      return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      UIImage *image = [UIImage imageWithData:data];
      if (image) {
        [self.imageCache setObject:image forKey:response.URL];
        [self _didLoadImage:image];
      }
    });
  }];
  [self.task resume];
}

- (void)_didLoadImage:(UIImage *)image {
  id<WVImageLoaderDelegate> delegate = self.delegate;
  [delegate imageLoader:self didLoadImage:image];
}

@end
