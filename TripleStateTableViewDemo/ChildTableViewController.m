//
//  ChildTableViewController.m
//  TripleStateTableViewDemo
//
//  Created by WangLin on 2016/10/25.
//  Copyright © 2016年 amberease. All rights reserved.
//

#import "ChildTableViewController.h"
#import "AETripleStateTableView.h"

@interface ChildTableViewController ()
@property (nonatomic,strong) NSArray* data;

@end

@implementation ChildTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AETripleStateTableView* tripleStateTableView = (AETripleStateTableView*)self.tableView;
    //override UIAppearance setting
    tripleStateTableView.noDataView = nil;
    
    //set noDataCellIdentifier instead
    tripleStateTableView.noDataCellIdentifier = @"NoDataCell";
    self.data = @[@"明细1",@"明细2",@"明细3",@"明细4",@"明细5",@"明细6",@"明细7",@"明细8",@"明细9"];
    
    //!Important: Set state to loading
    tripleStateTableView.state = AETripleStateTableViewLoading;
    
    
    //setup refresh control for table view
    [self.tableView setRefreshControl:[[UIRefreshControl alloc] init]];
    [self.tableView.refreshControl addTarget:self action:@selector(onRefreshed:) forControlEvents:UIControlEventValueChanged];
    [self loadDataNeedEndRefresh:NO];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell" forIndexPath:indexPath];
    
    UILabel* lblContent = [cell.contentView viewWithTag:1];
    lblContent.text = self.data[indexPath.row];
    
    return cell;
}


#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //If you want to handle the case that the user tapping the no data cell, please check the state of the table view here
    
    
    
    //If the state of the table view is normal, perform the normal logic here
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Help Methods
/*
 *  Perhaps your business code to consume external data here
 */
-(void)loadDataNeedEndRefresh:(BOOL)endRefresh{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (endRefresh) {
            [self.tableView.refreshControl endRefreshing];
        }
        
        srand((unsigned int)time(0));
        int val = rand();
        
        AETripleStateTableView* tripleStateTableView = (AETripleStateTableView*)self.tableView;
        
        if(val % 2 == 0){
            tripleStateTableView.state = AETripleStateTableViewNomal;
        }
        else{
            tripleStateTableView.state = AETripleStateTableViewNodata;
        }
    });
}

#pragma mark - Event Handlers
-(void)onRefreshed:(id)sender{
    [self loadDataNeedEndRefresh:YES];
}

@end
