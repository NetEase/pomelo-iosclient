//
//  Pomelo.m
//  iOS client for Pomelo
//
//  Created by Johnny on 12-12-11.
//  Copyright (c) 2012 netease pomelo team. All rights reserved.
//

#import "Pomelo.h"
#import "PomeloProtocol.h"
#import "SocketIOJSONSerialization.h"
#import "SocketIOPacket.h"

static NSString const *_connectCallback = @"__connectCallback__";
static NSString const *_disconnectCallback = @"__disconnectCallback__";

@interface Pomelo (Private)
- (void)sendMessageWithReqId:(NSInteger)reqId andRoute:(NSString *)route andMsg:(NSDictionary *)msg;
- (void)processMessage:(NSDictionary *)msg;
- (void)processMessageBatch:(NSArray *)msgs;
@end

@implementation Pomelo

- (id)initWithDelegate:(id<PomeloDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _reqId = 0;
        _callbacks = [[NSMutableDictionary alloc] init];
        socketIO = [[SocketIO alloc] initWithDelegate:self];
    }
    return self;
    
}

- (void)connectToHost:(NSString *)host onPort:(NSInteger)port
{
    [socketIO connectToHost:host onPort:port];
}
- (void)connectToHost:(NSString *)host onPort:(NSInteger)port withCallback:(PomeloCallback)callback;
{
    if (callback) {
        [_callbacks setObject:callback forKey:_connectCallback];
    }
    [socketIO connectToHost:host onPort:port];
}
- (void)connectToHost:(NSString *)host onPort:(NSInteger)port withParams:(NSDictionary *)params
{
    [socketIO connectToHost:host onPort:port withParams:params];
}
- (void)disconnect
{
    [socketIO disconnect];
}

- (void)disconnectWithCallback:(PomeloCallback)callback
{
    if (callback) {
        [_callbacks setObject:callback forKey:_disconnectCallback];
    }
    [socketIO disconnect];
}
# pragma mark -
# pragma mark implement SocketIODelegate

- (void) socketIODidConnect:(SocketIO *)socket
{
    PomeloCallback callback = [_callbacks objectForKey:_connectCallback];
    if (callback != nil) {
        callback(self);
        [_callbacks removeObjectForKey:_connectCallback];
    }
    if ([_delegate respondsToSelector:@selector(PomeloDidConnect:)]) {
        [_delegate PomeloDidConnect:self];
    }
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    PomeloCallback callback = [_callbacks objectForKey:_disconnectCallback];
    if (callback != nil) {
        callback(self);
        [_callbacks removeObjectForKey:_disconnectCallback];
    }
    if ([_delegate respondsToSelector:@selector(PomeloDidDisconnect:withError:)]) {
        [_delegate PomeloDidDisconnect:self withError:error];
    }
}

- (void)socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
    id data = [packet dataAsJSON];
    if ([_delegate respondsToSelector:@selector(Pomelo:didReceiveMessage:)]) {
        [_delegate Pomelo:self didReceiveMessage:data];
    }
    
    if ([data isKindOfClass:[NSArray class]]) {
        [self processMessageBatch:data];
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        [self processMessage:data];
    }
}

# pragma mark -
# pragma mark main api

- (void)notifyWithRoute:(NSString *)route andParams:(NSDictionary *)params
{
    [self sendMessageWithReqId:0 andRoute:route andMsg:params];
}

- (void)requestWithRoute:(NSString *)route andParams:(NSDictionary *)params andCallback:(PomeloCallback)callback
{
    if (callback) {
        ++_reqId;
        NSString *key = [NSString stringWithFormat:@"%ld", (long)_reqId];
        [_callbacks setObject:[callback copy] forKey:key];
        [self sendMessageWithReqId:_reqId andRoute:route andMsg:params];
    } else {
        [self notifyWithRoute:route andParams:params];
    }

}

- (void)onRoute:(NSString *)route withCallback:(PomeloCallback)callback
{
    id array = [_callbacks objectForKey:route];
    if (array == nil) {
        array = [NSMutableArray arrayWithCapacity:1];
        [_callbacks setObject:array forKey:route];
    }
    [array addObject:[callback copy]];
}

- (void)offRoute:(NSString *)route
{
    [_callbacks removeObjectForKey:route];
}

# pragma mark -
# pragma mark private methods

- (void)sendMessageWithReqId:(NSInteger)reqId andRoute:(NSString *)route andMsg:(NSDictionary *)msg
{
    NSString *msgStr = [SocketIOJSONSerialization JSONStringFromObject:msg error:nil];
    [socketIO sendMessage:[PomeloProtocol encodeWithId:reqId andRoute:route andBody:msgStr]];
}

- (void)processMessage:(NSDictionary *)msg
{
    id msgId =  [msg objectForKey:@"id"];
    if (msgId && msgId > 0){
        NSString *key = [NSString stringWithFormat:@"%@", msgId];
        PomeloCallback callback = [_callbacks objectForKey:key];
        if (callback != nil) {
            callback([msg objectForKey:@"body"]);
            [_callbacks removeObjectForKey:key];
        }
    } else {
        NSMutableArray *callbacks = [_callbacks objectForKey:[msg objectForKey:@"route"]];
        if (callbacks != nil) {
            for (PomeloCallback cb in callbacks)  {
                cb(msg);
            }
        }
        
    }
}

- (void)processMessageBatch:(NSArray *)msgs
{
    for (id msg in msgs) {
        [self processMessage:msg];
    }
}

# pragma mark -

- (void)dealloc
{
    socketIO = nil;
    _callbacks = nil;
    _delegate = nil;
}
@end
