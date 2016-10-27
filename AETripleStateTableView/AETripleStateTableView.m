//
//  AETripleStateTableView.m
//  TripleStateTableViewDemo
//
//  Created by WangLin on 2016/10/23.
//  Copyright © 2016年 amberease. All rights reserved.
//

#import "AETripleStateTableView.h"
#include <objc/runtime.h>



@interface AETripleStateTableViewDataSourceDispatcher : NSObject<UITableViewDataSource,UITableViewDelegate>{
    NSDictionary<NSString*,NSNumber *>* _tableViewDelegateMethodsImplementedInfo;
}
@property (nonatomic,weak) id<UITableViewDataSource>        dataSource;
@property (nonatomic,weak) id<UITableViewDelegate>          delegate;
@property (nonatomic,assign) AETripleStateTableViewStates   state;
@property (nonatomic,strong) UIView*                        loadingView;
@property (nonatomic,strong) NSString*                      loadingCellIdentifier;
@property (nonatomic,strong) UIView*                        noDataView;
@property (nonatomic,strong) NSString*                      noDataCellIdentifier;

@end



@implementation AETripleStateTableViewDataSourceDispatcher
@synthesize delegate = _delegate;

#pragma mark - Properties
-(id<UITableViewDelegate>)delegate{
    return _delegate;
}

-(void)setDelegate:(id<UITableViewDelegate>)delegate{
    if(_delegate != delegate) {
        _delegate = delegate;
        [self setupTableViewDelegateImplementedMethodsInfo];
    }
}

#pragma mark - UITableView Datasource(Required)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSAssert(self.dataSource, @"Missing dataSource");
    if(self.state == AETripleStateTableViewNomal){
        return [self.dataSource tableView:tableView numberOfRowsInSection:section];
    }
    else if(self.state == AETripleStateTableViewLoading){
        return 1;
    }
    else if(self.state == AETripleStateTableViewNodata){
        return 1;
    }
    else{
        NSLog(@"Unknown state:%lu found in function %s",(unsigned long)self.state,__func__);
    }
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSAssert(self.dataSource, @"Missing dataSource");
    if(self.state == AETripleStateTableViewNomal){
        return [self.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    else if(self.state == AETripleStateTableViewLoading){
        
        
        if(self.loadingView){
            UITableViewCell* cell = nil;
            if([self.loadingView isKindOfClass:[UITableViewCell class]]){
                cell = (UITableViewCell*)self.loadingView;
            }
            else{
                cell = [self buildCellFromView:self.loadingView];
            }
            //Forbid selection when loading
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else if(self.loadingCellIdentifier){
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:self.loadingCellIdentifier];
            //Enforce no selection even if user allows selection in the storeboard by mistake
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else{
            //build default loading view
            return [self buildDefaultLoadingCell];
        }
        
    }
    else if(self.state == AETripleStateTableViewNodata){
        if(self.noDataView){
            if([self.noDataView isKindOfClass:[UITableViewCell class]]){
                return (UITableViewCell*)self.noDataView;
            }
            else{
                return [self buildCellFromView:self.noDataView];
            }
        }
        else if(self.noDataCellIdentifier){
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:self.noDataCellIdentifier];
            return cell;
        }
        else{
            //build default no data view(empty cell)
            return [UITableViewCell new];
        }
    }
    else{
        NSLog(@"Unknown state:%lu found in function %s",(unsigned long)self.state,__func__);
        return [UITableViewCell new];
    }
}

#pragma mark - UITableViewDatasource Optional Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;              // Default is 1 if not implemented
{
    if([self.dataSource respondsToSelector:_cmd]){
        if(self.state == AETripleStateTableViewNomal){
            return [self.dataSource numberOfSectionsInTableView:tableView];
        }
        else if(self.state == AETripleStateTableViewLoading){
            return 1;
        }
        else if(self.state == AETripleStateTableViewNodata){
            return 1;
        }
        else{
            NSLog(@"Unknown state:%lu found in function %s",(unsigned long)self.state,__func__);
        }
    }
    
    return 1;
    
}

/**/
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
{
    if([self.dataSource respondsToSelector:_cmd]){
        return [self.dataSource tableView:tableView titleForHeaderInSection:section];
    }
    return nil;
    
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if([self.dataSource respondsToSelector:_cmd]){
        return [self.dataSource tableView:tableView titleForHeaderInSection:section];
    }
    return nil;
}
//*/

// Editing

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.dataSource respondsToSelector:_cmd]){
        return [self.dataSource tableView:tableView canEditRowAtIndexPath:indexPath];
    }
    else{
        if(self.state == AETripleStateTableViewNomal){
            return YES;
        }
        return NO;
    }
}

// Moving/reordering

// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.dataSource respondsToSelector:_cmd]){
        return [self.dataSource tableView:tableView canMoveRowAtIndexPath:indexPath];
    }
    return NO;
}

// Index

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView __TVOS_PROHIBITED                                                    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
{
    if([self.dataSource respondsToSelector:_cmd]){
        return [self.dataSource sectionIndexTitlesForTableView:tableView];
    }
    else{
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index __TVOS_PROHIBITED  // tell table which section corresponds to section title/index (e.g. "B",1))
{
    if([self.dataSource respondsToSelector:_cmd]){
        return [self.dataSource tableView:tableView sectionForSectionIndexTitle:title atIndex:index];
    }
    return 0;
}

// Data manipulation - insert and delete support

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
// Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.dataSource respondsToSelector:_cmd]){
        [self.dataSource tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

// Data manipulation - reorder / moving support

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    if([self.dataSource respondsToSelector:_cmd]){
        [self.dataSource tableView:tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    }
}


#pragma mark - UITableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.state == AETripleStateTableViewNomal){
        if([self.delegate respondsToSelector:_cmd]){
            return [self.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
        }
    }
    else if(self.state == AETripleStateTableViewNodata || self.state == AETripleStateTableViewLoading){
        return tableView.bounds.size.height;
    }
    
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0){
    if(self.state == AETripleStateTableViewNomal){
        if([self.delegate respondsToSelector:_cmd]){
            return [self.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
        }
    }
    else if(self.state == AETripleStateTableViewNodata || self.state == AETripleStateTableViewLoading){
        return tableView.bounds.size.height;
    }
    return 0.0;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if(self.state == AETripleStateTableViewNomal){
        if([self.delegate respondsToSelector:_cmd]){
            return [self.delegate tableView:tableView viewForHeaderInSection:section];
        }
    }
    else if(self.state == AETripleStateTableViewNodata || self.state == AETripleStateTableViewLoading){
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if(self.state == AETripleStateTableViewNomal){
        if([self.delegate respondsToSelector:_cmd]){
            return [self.delegate tableView:tableView viewForFooterInSection:section];
        }
    }
    else if(self.state == AETripleStateTableViewNodata || self.state == AETripleStateTableViewLoading){
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
    return [[UIView alloc] initWithFrame:CGRectZero];
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.state == AETripleStateTableViewNomal){
        if([self.delegate respondsToSelector:_cmd]){
            return [self.delegate tableView:tableView heightForHeaderInSection:section];
        }
    }
    else if(self.state == AETripleStateTableViewNodata || self.state == AETripleStateTableViewLoading){
        return 0.0f;
    }
    return 0.0f;
}



-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(self.state == AETripleStateTableViewNomal){
        if([self.delegate respondsToSelector:_cmd]){
            return [self.delegate tableView:tableView heightForFooterInSection:section];
        }
    }
    else if(self.state == AETripleStateTableViewNodata || self.state == AETripleStateTableViewLoading){
        return 0.0f;
    }
    return 0.0f;
}

//!!Important NOT TO implement estimatedHeightForHeaderInSection and estimatedHeightForFooterInSection, because if the real table view's delegate doesn't respond to those two methods, we don't know what's the real estimatedHeight for header or footer. If we return 0.0f here, the delegate method heightForHeaderInSection and heightForFooterInSection and subsequent viewForHeaderInSection and viewForFooterInSection will have no chance to be called
/*
 - (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section NS_AVAILABLE_IOS(7_0){
 if(self.state == AETripleStateTableViewNomal){
 if([self.delegate respondsToSelector:_cmd]){
 return [self.delegate tableView:tableView estimatedHeightForHeaderInSection:section];
 }
 }
 else if(self.state == AETripleStateTableViewNodata || self.state == AETripleStateTableViewLoading){
 return 0.0f;
 }
 return 0.0f;
 }
 
 - (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section NS_AVAILABLE_IOS(7_0){
 if(self.state == AETripleStateTableViewNomal){
 if([self.delegate respondsToSelector:_cmd]){
 return [self.delegate tableView:tableView heightForFooterInSection:section];
 }
 }
 else if(self.state == AETripleStateTableViewNodata || self.state == AETripleStateTableViewLoading){
 return 0.0f;
 }
 return 0.0f;
 }
 //*/





#pragma mark - NSInvocation
-(BOOL)respondsToSelector:(SEL)aSelector{
    NSString * strSelector = NSStringFromSelector(aSelector);
    NSLog(@"check responds to selector:%@",strSelector);
    if([super respondsToSelector:aSelector]){
        return YES;
    }
    else{
        
        if([[strSelector substringToIndex:9] isEqualToString:@"tableView"]){
            NSLog(@"tableview delegate found");
        }
        if ([self isSeletorImplementedInTableViewDelegate:aSelector]){
            return YES;
        }
        
        return NO;
    }
}

-(id)forwardingTargetForSelector:(SEL)aSelector{
    //如果UITableViewDelegate的方法在该类没有实现，但是在delegate中确有实现，那就让delegate去处理
    if([self isSeletorImplementedInTableViewDelegate:aSelector]){
        return _delegate;
    }
    return [super forwardingTargetForSelector:aSelector];
}

-(void)setupTableViewDelegateImplementedMethodsInfo{
    
    unsigned int numOfMethods;
    struct objc_method_description * method_description_list;
    
    method_description_list = protocol_copyMethodDescriptionList(@protocol(UITableViewDelegate),
                                                                 NO, YES, &numOfMethods);
    
    _tableViewDelegateMethodsImplementedInfo = [[NSMutableDictionary alloc] initWithCapacity:numOfMethods];
    for (int i=0; i<numOfMethods; i++) {
        SEL aSelector = method_description_list[i].name;
        if([_delegate respondsToSelector:aSelector]){
            [_tableViewDelegateMethodsImplementedInfo setValue:@YES forKey:NSStringFromSelector(aSelector)];
        }
        else{
            [_tableViewDelegateMethodsImplementedInfo setValue:@NO forKey:NSStringFromSelector(aSelector)];
        }
        
    }
    
    free(method_description_list);
}

-(BOOL)isSeletorImplementedInTableViewDelegate:(SEL)aSelector{
    return _tableViewDelegateMethodsImplementedInfo[NSStringFromSelector(aSelector)].boolValue;
}


#pragma mark - Help Methods
-(UITableViewCell*)buildDefaultLoadingCell{
    UITableViewCell* cell = [UITableViewCell new];
    cell.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    UIActivityIndicatorView* loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    [loadingView startAnimating];
    loadingView.color = [UIColor darkGrayColor];
    [cell.contentView addSubview:loadingView];
    
    //Auto Layout Control
    NSDictionary *dict=NSDictionaryOfVariableBindings(loadingView);
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=5)-[loadingView]-(>=5)-|" options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=5)-[loadingView]-(>=5)-|" options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:loadingView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1
                                                                  constant:0]];
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:loadingView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];
    
    
    //Forbid selection when loading
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}


-(UITableViewCell*)buildCellFromView:(UIView*)view{
    NSParameterAssert(view);
    UITableViewCell* cell =  [UITableViewCell new];
    cell.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:view];
    
    NSDictionary *dict=NSDictionaryOfVariableBindings(view);
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
    
    return cell;
    
}
@end

@interface AETripleStateTableView(){
    AETripleStateTableViewStates _state;
}
@property (nonatomic,strong) AETripleStateTableViewDataSourceDispatcher* dispatcher;

@end

@implementation AETripleStateTableView
@dynamic state,loadingView,loadingCellIdentifier,noDataView,noDataCellIdentifier;

#pragma mark - Constructors
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self setup];
    }
    return self;
}

-(id)init{
    self = [super init];
    if(self){
        [self setup];
    }
    return self;
}

-(void)setup{
    self.dispatcher = [[AETripleStateTableViewDataSourceDispatcher alloc] init];
}

#pragma mark - UITableView Datasource, Delegate customization
-(void)setDataSource:(id<UITableViewDataSource>)dataSource{
    self.dispatcher.dataSource = dataSource;
    super.dataSource = self.dispatcher;
}

-(id<UITableViewDataSource>)dataSource{
    return super.dataSource;
}

-(void)setDelegate:(id<UITableViewDelegate>)delegate{
    self.dispatcher.delegate = delegate;
    super.delegate = self.dispatcher;
}

-(id<UITableViewDelegate>)delegate{
    return super.delegate;
}


#pragma mark - Public Properties
-(void)setState:(AETripleStateTableViewStates)state{
    _state = state;
    self.dispatcher.state = state;
    [self reloadData];
}

-(AETripleStateTableViewStates)state{
    return self.dispatcher.state;;
}

-(void)setLoadingView:(UIView *)loadingView{
    self.dispatcher.loadingView = loadingView;
}

-(UIView*)loadingView{
    return self.dispatcher.loadingView;
}

-(void)setLoadingCellIdentifier:(NSString *)loadingCellIdentifier{
    self.dispatcher.loadingCellIdentifier = loadingCellIdentifier;
}

-(NSString*)loadingCellIdentifier{
    return self.dispatcher.loadingCellIdentifier;
}


-(void)setNoDataView:(UIView *)noDataView{
    self.dispatcher.noDataView = noDataView;
}

-(UIView*)noDataView{
    return self.dispatcher.noDataView;
}

-(void)setNoDataCellIdentifier:(NSString *)noDataCellIdentifier{
    self.dispatcher.noDataCellIdentifier = noDataCellIdentifier;
}

-(NSString*)noDataCellIdentifier{
    return self.dispatcher.noDataCellIdentifier;
}

@end
