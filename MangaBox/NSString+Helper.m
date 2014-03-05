//
//  NSString+Helper.m
//  MangaBox
//
//  Created by Ken Tran on 3/3/14.
//  Copyright (c) 2014 Ken Tran. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)
- (NSString *)stringByStrippingHTML
{
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}
@end
