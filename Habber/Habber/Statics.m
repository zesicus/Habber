//
//  Statics.m
//  Habber
//
//  Created by Sunny on 12/16/15.
//  Copyright © 2015 Nine. All rights reserved.
//

#import "Statics.h"

@implementation Statics

+ (NSString *)getCurrentTime {
    NSDate *nowUTC = [NSDate date];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];

    return [dateFormatter stringFromDate:nowUTC];
}

@end
