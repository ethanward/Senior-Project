#import <UIKit/UIKit.h>
@class ChatObject;

@interface ChatViewController : UIViewController
@property (nonatomic, strong) ChatObject *chat;
@property (nonatomic, weak) IBOutlet UITextView *textView;
-(IBAction)disconnect:(id)sender;
@end
