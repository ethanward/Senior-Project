#import <UIKit/UIKit.h>

@interface UsersViewController : UIViewController
@property (nonatomic, weak) IBOutlet UITableView *tableView;
-(IBAction)logout:(id)sender;
@end
