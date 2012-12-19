//
//  Pomelo.m
//  PomeloChat
//
//  Created by Johnny on 12-12-11.
//  Copyright (c) 2012年 netease pomelo team. All rights reserved.
//

#import "Pomelo.h"
#import "SocketIOJSONSerialization.h"

NSString* const PomeloException = @"PomeloException";

@interface Pomelo (Private)
- (NSString *)encodeWithId:(NSInteger)id andRoute:(NSString *)route andBody:(NSString *)body;
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

- (NSString *)encodeWithId:(NSInteger)id andRoute:(NSString *)route andBody:(NSString *)body
{
    if ([route length] > 255) {
        [NSException raise:PomeloException format:@"Pomelo: route length is too long!"];
        return nil;
    }
                  
    NSString *msg = [NSString stringWithFormat:@"%C%C%C%C%C%@%@",
                            (id >> 24) & 0xFF,
                            (id >> 16) & 0xFF,
                            (id >> 8) & 0xFF,
                            id & 0xFF,
                            [route length],
                            route,
                            body];
    
//    NSLog(@"send msg,%d, %d, %@",[route length] + [body length],[msg length],msg);

    return msg;
}

- (void)connectToHost:(NSString *)host onPort:(NSInteger)port
{
    [socketIO connectToHost:host onPort:port];
}
- (void)connectToHost:(NSString *)host onPort:(NSInteger)port withParams:(NSDictionary *)params
{
    [socketIO connectToHost:host onPort:port withParams:params];
}
- (void)disconnect{
    [socketIO disconnect];
}
- (void) socketIODidConnect:(SocketIO *)socket
{
    if ([_delegate respondsToSelector:@selector(PomeloDidConnect:)]) {
        [_delegate PomeloDidConnect:self];
    }
}
- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(PomeloDidDisconnect:)]) {
        [_delegate PomeloDidDisconnect:self];
    }
}

- (void)sendMessageWithReqId:(NSInteger)reqId andRoute:(NSString *)route andMsg:(NSDictionary *)msg
{
    NSString *msgStr = [SocketIOJSONSerialization JSONStringFromObject:msg error:nil];
    [socketIO sendMessage:[self encodeWithId:reqId andRoute:route andBody:msgStr]];
}

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

- (void)socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
    id data = [packet dataAsJSON];
    NSLog(@"receive, %@", data);
    if ([_delegate respondsToSelector:@selector(Pomelo:didReceiveMessage:)]) {
        [_delegate Pomelo:self didReceiveMessage:data];
    }
    
    if ([data isKindOfClass:[NSArray class]]) {
        [self processMessageBatch:data];
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        [self processMessage:data];
    }
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
        NSString *route = [NSString stringWithFormat:@"%@%@", [msg objectForKey:@"route"], @":"];
        SEL sel = NSSelectorFromString(route);
        if ([_delegate respondsToSelector: sel]) {
            [_delegate performSelector:sel withObject:msg];
        }
    }
}

- (void)processMessageBatch:(NSArray *)msgs
{
    for (id msg in msgs) {
        [self processMessage:msg];
    }
}

- (void)dealloc
{
    socketIO = nil;
    _callbacks = nil;
    _delegate = nil;
}
@end
