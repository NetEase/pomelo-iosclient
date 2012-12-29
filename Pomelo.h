//
//  Pomelo.h
//  iOS client for Pomelo
//
//  Created by Johnny on 12-12-11.
//  Copyright (c) 2012 netease pomelo team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIO.h"

typedef void(^PomeloCallback)(id callback);

@class Pomelo;

@protocol PomeloDelegate <NSObject>
@optional
- (void)PomeloDidConnect:(Pomelo *)pomelo;
- (void)PomeloDidDisconnect:(Pomelo *)pomelo withError:(NSError *)error;
- (void)Pomelo:(Pomelo *)pomelo didReceiveMessage:(NSArray *)message;
@end

@interface Pomelo : NSObject <SocketIODelegate>
{
    
    __unsafe_unretained id<PomeloDelegate> _delegate;
    
    NSMutableDictionary *_callbacks;
    NSInteger _reqId;
    SocketIO *socketIO;
}

- (id)initWithDelegate:(id<PomeloDelegate>)delegate;
- (void)connectToHost:(NSString *)host onPort:(NSInteger)port;
- (void)connectToHost:(NSString *)host onPort:(NSInteger)port withCallback:(PomeloCallback)callback;
- (void)connectToHost:(NSString *)host onPort:(NSInteger)port withParams:(NSDictionary *)params;
- (void)disconnect;
- (void)disconnectWithCallback:(PomeloCallback)callback;

- (void)requestWithRoute:(NSString *)route andParams:(NSDictionary *)params andCallback:(PomeloCallback)callback;
- (void)notifyWithRoute:(NSString *)route andParams:(NSDictionary *)params;
- (void)onRoute:(NSString *)route withCallback:(PomeloCallback)callback;
- (void)offRoute:(NSString *)route;

@end
