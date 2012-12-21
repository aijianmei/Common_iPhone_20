//
//  XQueryComponents.m
//  ButtonTest
//
//  Created by  on 12-8-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XQueryComponents.h"

@implementation NSString (XQueryComponents)
- (NSString *)stringByDecodingURLFormat
{
    NSString *result = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

- (NSString *)stringByEncodingURLFormat
{
    NSString *result = [self stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    result = [result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

- (NSMutableDictionary *)dictionaryFromQueryComponents
{
    NSMutableDictionary *queryComponents = [NSMutableDictionary dictionary];
    for(NSString *keyValuePairString in [self componentsSeparatedByString:@"&"])
    {
        NSArray *keyValuePairArray = [keyValuePairString componentsSeparatedByString:@"="];
        if ([keyValuePairArray count] < 2) continue; // Verify that there is at least one key, and at least one value.  Ignore extra = signs
        NSString *key = [[keyValuePairArray objectAtIndex:0] stringByDecodingURLFormat];
        NSString *value = nil;        
        if ([keyValuePairArray count] == 2) 
        {
            value = [[keyValuePairArray objectAtIndex:1] stringByDecodingURLFormat];            
        }
        else
        {
            NSRange range = [keyValuePairString rangeOfString:@"="];
            if (range.location != NSNotFound) {
                NSInteger index = range.location + 1;
                if (index >= 0 && index < [keyValuePairString length]) {
                    value = [keyValuePairString substringFromIndex:range.location+1];    
                }
            }
        }
        if (key.length != 0 &&  value.length != 0) {
            [queryComponents setObject:value forKey:key];            
        }

    }
    return queryComponents;
}
@end

@implementation NSURL (XQueryComponents)
- (NSMutableDictionary *)queryComponents
{
    return [[self query] dictionaryFromQueryComponents];
}
@end

@implementation NSDictionary (XQueryComponents)
- (NSString *)stringFromQueryComponents
{
    NSString *result = nil;
    for(NSString *key in [self allKeys])
    {
        key = [key stringByEncodingURLFormat];
        NSArray *allValues = [self objectForKey:key];
        if([allValues isKindOfClass:[NSArray class]])
            for(NSString *value in allValues)
            {
                value = [[value description] stringByEncodingURLFormat];
                if(!result)
                    result = [NSString stringWithFormat:@"%@=%@",key,value];
                else 
                    result = [result stringByAppendingFormat:@"&%@=%@",key,value];
            }
        else {
            NSString *value = [[allValues description] stringByEncodingURLFormat];
            if(!result)
                result = [NSString stringWithFormat:@"%@=%@",key,value];
            else 
                result = [result stringByAppendingFormat:@"&%@=%@",key,value];
        }
    }
    return result;
}
@end
