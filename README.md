#Pomelo iOS client

The iOS client library for [Pomelo](https://github.com/NetEase/pomelo)

A [demo](https://github.com/NetEase/pomelo-ioschat) exists for this library.

##Dependencies
* [socket.IO-objc](https://github.com/pkyeck/socket.IO-objc) (v0.3.0): A [Socket.IO](http://socket.io/) client for Objective-C, based on [SocketRocket](https://github.com/square/SocketRocket)
* [SocketRocket](https://github.com/square/SocketRocket): Objective-C WebSocket Client.

##Installation
1. make sure you have installed the dependencies
2. then just add the `Pomelo.h`, `Pomelo.m`, `PomeloProtocol.h`, `pomeloProtocol.m` files to your project.

##Usage

**Pomelo API**

```objective-c
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
```

connect to the pomelo server
```objective-c
Pomelo *pomelo = [[Pomelo alloc] initWithDelegate:self];
[pomelo connectToHost:@"localhost" onPort:3000];
```
request
```objective-c
PomeloCallback cb = ^(id argsData) {
    // do something with response
};
[pomelo requestWithRoute:@"gate.gateHandler.queryEntry" andParams:data andCallback:cb];
```
notify
```objective-c
[pomelo notifyWithRoute:@"chat.chatHandler.send" andParams:data];
```
bind event
```objective-c
[pomelo onRoute:@"onChat" withCallback:^(NSDictionary *data){
    // do something...
}];
```
unbind event
```objective-c
[pomelo offRoute:@"onChat"];
```

##License
(The MIT License)

Copyright (c) 2012-2013 NetEase, Inc. and other contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
