#import "UsersViewController.h"
#import "Backendless.h"
#import "ChatObject.h"
#import "ChatViewController.h"

@interface UsersViewController ()<UITableViewDataSource, UITableViewDelegate, ChatProtocol, UIAlertViewDelegate>
{
    NSArray *_data;
    ChatObject *_chat;
    NSString *_userId;
}
@end

@implementation UsersViewController

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
    _chat = [ChatObject new];
    _chat.delegate = self;
    
    [_chat subscribe:backendless.userService.currentUser.objectId];
    [_chat setPublisher:backendless.userService.currentUser.objectId];
    BackendlessDataQuery *query = [BackendlessDataQuery query];
    query.whereClause = [NSString stringWithFormat:@"email != '%@'", backendless.userService.currentUser.email];
    query.properties = @[@"email", @"objectId"];
    [backendless.persistenceService find:[BackendlessUser class] dataQuery:query response:^(BackendlessCollection *collection) {
        _data = [NSArray arrayWithArray:collection.data];
        [_tableView reloadData];
        //NSLog(@"UsersViewController -> viewDidLoad: (USERS)\n%@", collection.data);
    } error:^(Fault *error) {
        NSLog(@"UsersViewController -> viewDidLoad: (FAULT) %@", error);
    }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UsersCell" forIndexPath:indexPath];
    BackendlessUser *user = _data[indexPath.row];
    [(UILabel *)[cell viewWithTag:1] setText:user.email];
    return cell;
}

-(void)logout:(id)sender
{
    [_chat unsubscribe];
    [backendless.userService logout:^(id res) {
        [self.navigationController popViewControllerAnimated:YES];
    } error:^(Fault *error) {
        NSLog(@"%@", error.detail);
    }];
}

-(void)getConnectionRequest:(NSString *)userId message:(NSString *)message
{
    if ([message isEqualToString:@"finish"])
        return;

    _userId = userId;
    [[[UIAlertView alloc] initWithTitle:@"Connection" message:message delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil] show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            ChatViewController *chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
            _chat.returned = self;
            _chat.delegate = (id<ChatProtocol>) chatVC;
            chatVC.chat = _chat;
            [_chat connectToUser:_userId];
            [self.navigationController pushViewController:chatVC animated:YES];
        }
            break;
        case 1:
        {
            [_chat dismissUser:_userId];
        }
            
            break;
        default:
            break;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *indexPath = [_tableView indexPathForCell:sender];
    _chat.returned = self;
    _chat.delegate = segue.destinationViewController;
    [(ChatViewController *)segue.destinationViewController setChat:_chat];
    [_chat connectToUser:((BackendlessUser *)_data[indexPath.row]).objectId];
}

@end
