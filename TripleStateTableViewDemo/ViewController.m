//
//  ViewController.m
//  TripleStateTableViewDemo
//
//  Created by WangLin on 2016/10/23.
//  Copyright © 2016年 amberease. All rights reserved.
//

#import "ViewController.h"
#import "AETripleStateTableView.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet AETripleStateTableView *tableView;
@property (nonatomic,strong) NSArray* data;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.data = @[@"大象",@"小老鼠",@"豹子",@"狮子",@"老虎",@"小狗",@"小猫",@"土狼"];
    self.tableView.state = AETripleStateTableViewNodata;
    [self.tableView setRefreshControl:[[UIRefreshControl alloc] init]];
    [self.tableView.refreshControl addTarget:self action:@selector(onRefreshed:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.state = AETripleStateTableViewLoading;
    [self loadDataNeedEndRefresh:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"simpleCell"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"simpleCell"];
        cell.textLabel.tag = 1;
    }
    
    UILabel* lblName =  (UILabel*)[cell.contentView viewWithTag:1];
    lblName.text = self.data[indexPath.row];
    
    return cell;
}

#pragma mark - UITableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@",cell);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.tableView.state == AETripleStateTableViewNomal){
        [self performSegueWithIdentifier:@"showDetail" sender:indexPath];
    }
    else if(self.tableView.state == AETripleStateTableViewNodata){
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Prompt" message:@"Pull to refresh data!" preferredStyle:UIAlertControllerStyleAlert];
        
        __weak ViewController* weakSelf = self;
        UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            weakSelf.tableView.state = AETripleStateTableViewLoading;
            [weakSelf loadDataNeedEndRefresh:NO];
        }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


#pragma mark - Help Methods
-(void)loadDataNeedEndRefresh:(BOOL)endRefresh{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (endRefresh) {
            [self.tableView.refreshControl endRefreshing];
        }
        
        srand(time(0));
        int val = rand();
        if(val % 2 == 0){
            self.tableView.state = AETripleStateTableViewNomal;
        }
        else{
            self.tableView.state = AETripleStateTableViewNodata;
        }
    });
}

#pragma mark - Event Handlers
-(void)onRefreshed:(id)sender{
    [self loadDataNeedEndRefresh:YES];
}

@end
