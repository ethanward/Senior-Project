#import "ChatViewController.h"
#import "Backendless.h"
#import "ChatObject.h"
@interface ChatViewController ()<ChatProtocol, UITextFieldDelegate>
{
}


@end

@implementation ChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)disconnect:(id)sender
{
    [_chat cancelConnection];
    _chat.delegate = _chat.returned;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getMessage:(NSString *)message fromUser:(NSString *)user
{
    _textView.text = [_textView.text stringByAppendingFormat:@"%@: %@\n", user, message];
}

-(void)getConnectionRequest:(NSString *)userId message:(NSString *)message
{
    if ([message isEqualToString:@"finish"]) {
        _chat.delegate = _chat.returned;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_chat publish:textField.text];
    _textView.text = [_textView.text stringByAppendingFormat:@"%@: %@\n", backendless.userService.currentUser.email, textField.text];
    textField.text = @"";
    return YES;
}

@end
