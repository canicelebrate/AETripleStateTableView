//
//  AETripleStateTableView.h
//  TripleStateTableViewDemo
//
//  Created by WangLin on 2016/10/23.
//  Copyright © 2016年 amberease. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    AETripleStateTableViewLoading,
    AETripleStateTableViewNodata,
    AETripleStateTableViewNomal,
} AETripleStateTableViewStates;

@interface AETripleStateTableView : UITableView
@property (nonatomic,assign) AETripleStateTableViewStates   state;
@property (nonatomic,strong) UIView*                        loadingView UI_APPEARANCE_SELECTOR;
@property (nonatomic,strong) NSString*                      loadingCellIdentifier;
@property (nonatomic,strong) UIView*                        noDataView  UI_APPEARANCE_SELECTOR;
@property (nonatomic,strong) NSString*                      noDataCellIdentifier;
@end
