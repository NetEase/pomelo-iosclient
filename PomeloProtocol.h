//
//  PomeloProtocol.h
//  iOS client for Pomelo
//
//  Created by Johnny on 12-12-24.
//  Copyright (c) 2012 netease pomelo team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PomeloProtocol : NSObject
+ (NSString *)encodeWithId:(NSInteger)id andRoute:(NSString *)route andBody:(NSString *)body;
@end
