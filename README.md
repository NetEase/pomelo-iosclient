#Pomelo iOS client

The iOS client libary for [Pomelo](https://github.com/NetEase/pomelo)

##Dependencies
* [socket.IO-objc](https://github.com/pkyeck/socket.IO-objc): A [Socket.IO](http://socket.io/) client for Objective-C, based on [SocketRocket](https://github.com/square/SocketRocket)
* [SocketRocket](https://github.com/square/SocketRocket): Objective-C WebSocket Client.

##Installation
1. make sure you have installed the dependencies
2. then just add the `pomelo.m` and `pomelo.h` files to your project.

##Usage

**Pomelo API**

```objective-c
- (id) initWithDelegate:(id<PomeloDelegate>)delegate;
- (void) connectToHost:(NSString *)host onPort:(NSInteger)port;
- (void) connectToHost:(NSString *)host onPort:(NSInteger)port withParams:(NSDictionary *)params;
- (void) disconnect;
- (void) requestWithRoute:(NSString *)route andParams:(NSDictionary *)params andCallback:(PomeloCallback)callback;
- (void) notifyWithRoute:(NSString *)route andParams:(NSDictionary *)params;
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
bind events
```objective-c
// implement PomeloDelegate
@interface Demo : NSObject <PomeloDelegate>

// `onChat` will be emited when the server side push a message which route is `onChat`
- (void) onChat:(NSDictionary *) data
{
    // do something with data
}
@end
```

##License
(The MIT License)

Copyright (c) 2012 Netease, Inc. and other contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.