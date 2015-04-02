//
//  WaverTests.m
//  WaverTests
//
//  Created by Diana Gren on 3/31/15.
//  Copyright (c) 2015 Diana Gren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "WVTrackTableViewCell.h"

@interface WVTrackTableViewCell ()
+ (NSString *)_durationForMilliseconds:(CGFloat)milliseconds;
@end

@interface WVTrackCellTests : XCTestCase

@end

@implementation WVTrackCellTests

- (void)testDurationFormatter {
  XCTAssertEqualObjects([WVTrackTableViewCell _durationForMilliseconds:0], @"00:00");
  XCTAssertEqualObjects([WVTrackTableViewCell _durationForMilliseconds:185000], @"03:05");
  XCTAssertEqualObjects([WVTrackTableViewCell _durationForMilliseconds:3905000], @"01:05:05");
}

@end
