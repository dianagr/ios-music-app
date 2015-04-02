//
//  WVImageLoader.m
//  Waver
//
//  Created by Diana Gren on 4/2/15.
//  Copyright (c) 2015 Diana Gren. All rights reserved.
//

#import "WVImageLoader.h"

@interface WVImageLoader ()
@property (strong, nonatomic) NSURLSessionDataTask *task;
@end

@implementation WVImageLoader

- (void)loadImageWithURL:(NSURL *)url {
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
        id<WVImageLoaderDelegate> delegate = self.delegate;
        [delegate imageLoader:self didLoadImage:image];
      }
    });
  }];
  [self.task resume];
}

- (void)cancel {
  [self.task cancel];
}

@end
