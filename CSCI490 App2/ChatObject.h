#import <Foundation/Foundation.h>
#import "Responder.h"
@protocol ChatProtocol
@optional
-(void)getMessage:(NSString *)message fromUser:(NSString *)user;
-(void)getConnectionRequest:(NSString *)userId message:(NSString *)message;
-(void)getError:(Fault *)error;
@end

@interface ChatObject : NSObject<IResponder>
@property (nonatomic, weak) id<ChatProtocol> delegate;
@property (nonatomic, weak) id<ChatProtocol> returned;
-(void)publish:(NSString *)message;
-(void)subscribe:(NSString *)channel;
-(void)unsubscribe;
-(void)setPublisher:(NSString *)publisherId;
-(void)connectToUser:(NSString *)userId;
-(void)dismissUser:(NSString *)userId;
-(void)cancelConnection;
-(BOOL)connectionStatus;
@end
