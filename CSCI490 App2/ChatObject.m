#import "ChatObject.h"
#import "Backendless.h"

@interface ChatObject()
{
    PublishOptions *publishOptions;
    SubscriptionOptions *subscriptionOptions;
    BESubscription *subscription;
    Responder *responder;
    NSString *connectTouserId;
    BOOL connectionStatus;
}
@end

@implementation ChatObject

-(id)responseHandler:(id)response
{
    
    NSArray *messages = response;
    if (!messages.count)
        return response;
    
    for (id obj in messages) {
        if ([obj isKindOfClass:[Message class]]) {
            Message *message = (Message *)obj;
            
            NSLog(@"ChatObject -> responseHandler: MESSAGE = %@ (= %@?) <%@>\n%@]", message.publisherId, connectTouserId, message.data, message.headers);
            
            NSString *publisher = message.publisherId;
            NSString *request = message.headers[@"request"];
            if (request)
            {
                if ([request isEqualToString:@"finish"]) {
                    connectionStatus = NO;
                    connectTouserId = nil;
                }
                
                if ([(NSObject *)self.delegate respondsToSelector:@selector(getConnectionRequest:message:)]) {
                    [self.delegate getConnectionRequest:publisher message:message.data];
                }
            }
            else
            {
                if ([publisher isEqualToString:connectTouserId])
                {
                    if ([(NSObject *)self.delegate respondsToSelector:@selector(getMessage:fromUser:)]) {
                        [self.delegate getMessage:message.data fromUser:message.headers[@"user"]];
                    }
                }
            }
        }
    }
    
    return response;
}

-(void)errorHandler:(Fault *)fault
{
    if ([(NSObject *)self.delegate respondsToSelector:@selector(getError:)]) {
        [self.delegate getError:fault];
    }
    
    NSLog(@"ChatObject -> errorHandler: FAULT = %@", fault);
}

-(void)publish:(NSString *)message
{
    if (!connectTouserId) {
        [self errorHandler:[Fault fault:@"You have to connect to the user"]];
        return;
    }
    if (!connectionStatus) {
        return;
    }
    publishOptions.headers = @{@"user":backendless.userService.currentUser.email};
    [backendless.messagingService
     publish:connectTouserId
     message:message
     publishOptions:publishOptions
     response:^(MessageStatus *status) {
         NSLog(@"ChatObject -> publish: %@ -> '%@>'", connectTouserId, message);
     }
     error:^(Fault *error) {
         [self errorHandler:error];
     }
     ];
}

-(void)subscribe:(NSString *)channel
{
    
    @try {
        subscriptionOptions = [SubscriptionOptions new];
        
        responder = [[Responder alloc] initWithResponder:self
                                      selResponseHandler:@selector(responseHandler:) selErrorHandler:@selector(errorHandler:)];
        
        subscription = [backendless.messagingService
                        subscribe:channel subscriptionResponder:responder subscriptionOptions:subscriptionOptions];
        
        NSLog(@"ChatObject -> subscribe: SUBSCRIPTION: %@", subscription);
    }
    
    @catch (Fault *fault) {
        NSLog(@"ChatObject -> subscribe: FAULT = %@ <%@>", fault.message, fault.detail);
    }
}

-(void)unsubscribe
{
    [subscription cancel];
}

-(void)setPublisher:(NSString *)publisherId
{
    publishOptions = [PublishOptions new];
    publishOptions.publisherId = publisherId;
}

-(void)connectToUser:(NSString *)userId
{
    
    NSLog(@"ChatObject -> connectToUser: %@", userId);
    
    connectionStatus = NO;
    connectTouserId = userId;
    publishOptions.headers = @{@"request":@"start"};
    [backendless.messagingService
     publish:connectTouserId
     message:[NSString stringWithFormat:@"%@ want to start to chat with You", backendless.userService.currentUser.email]
     publishOptions:publishOptions
     response:^(MessageStatus *status) {
         connectionStatus = YES;
     }
     error:^(Fault *error) {
         [self errorHandler:error];
     }
    ];
}

-(void)dismissUser:(NSString *)userId
{
    
    NSLog(@"ChatObject -> dismissUser: %@", userId);
    
    connectionStatus = NO;
    connectTouserId = userId;
    publishOptions.headers = @{@"request":@"start"};
    [backendless.messagingService
     publish:connectTouserId
     message:@"dismiss"
     publishOptions:publishOptions
     response:^(MessageStatus *status) {
         connectionStatus = YES;
         [self cancelConnection];
     }
     error:^(Fault *error) {
         [self errorHandler:error];
     }
    ];
}

-(void)cancelConnection
{
    if (!connectionStatus)
        return;
    
    NSLog(@"ChatObject -> cancelConnection: %@", connectTouserId);
    
    publishOptions.headers = @{@"request":@"finish"};
    [backendless.messagingService
     publish:connectTouserId message:@"finish"
     publishOptions:publishOptions
     response:^(MessageStatus *status) {
         connectionStatus = NO;
         connectTouserId = nil;
     }
     error:^(Fault *error) {
         [self errorHandler:error];
     }
    ];
}

-(BOOL)connectionStatus
{
    return connectionStatus;
}

@end
