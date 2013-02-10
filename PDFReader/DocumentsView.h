#import <UIKit/UIKit.h>

@interface DocumentsView : UINavigationController <UITableViewDelegate, UITableViewDataSource> {
	UITableViewController *tableViewController;
	NSArray *documents;
	NSDictionary *urlsByName;
}

@property (nonatomic, strong) id delegate;
@end
