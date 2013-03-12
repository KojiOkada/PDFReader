//
//  ScanViewController.m
//  PDFReader
//
//  Created by システム管理者 on 13/03/11.
//  Copyright (c) 2013年 Koji Okada. All rights reserved.
//

#import "ScanViewController.h"

@interface ScanViewController ()

@end

@implementation ScanViewController

-(void)dealloc{
    CGPDFDocumentRelease(_pdfDocument);
}
-(void)viewDidLoad{
    [super viewDidLoad];
    _numberOfPage = CGPDFDocumentGetNumberOfPages(_pdfDocument);
    _dataSource = [NSMutableArray array];

}
#pragma mark UserMethod
-(void)loadPage:(int)index{


}
-(void)didEndScan{

}
#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *identifier = @"CellIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
	}
    NSDictionary *dic = [_dataSource objectAtIndex:indexPath.row];
    NSString *str = [NSString stringWithFormat:@"%@　ページ",[dic objectForKey:@"page"]];
    //DebugLog(@"%@",str)
    if([str length]>0){
        cell.textLabel.text = str;
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [_dataSource objectAtIndex:indexPath.row];
    [_delegate openPage:[[dic objectForKey:@"page"]intValue]];
}

#pragma mark UISeachBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *keyword = searchBar.text;
    [self cancelExecutingOperation];
    if([keyword length]==0){
        return;
    }
    
    [_dataSource removeAllObjects];
    queue = [NSOperationQueue mainQueue];
    
    for(int i = 1;i < _numberOfPage -1;i++){
        pdfPage = CGPDFDocumentGetPage(_pdfDocument, i);
        pageScanner *scan = [[pageScanner alloc]initWithPDFDocument:pdfPage pageIndex:i keyword:keyword];
        scan.delegate = self;
        [queue addOperation:scan];
    }
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    
    [self cancelExecutingOperation];
    searchBar.text = @"";
    [_dataSource removeAllObjects];
    [_tableView reloadData];
}
-(void)detectKeyWord:(NSDictionary*)dic{
    [_dataSource addObject:dic];
    [_tableView reloadData];
}

- (void)cancelExecutingOperation
{
    for (NSOperation *ope in [queue operations]) {
        DebugLog(@"Queue Canceled!")
        if ([ope isExecuting] == YES) [ope cancel];
    }
}
@end
