/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "ContactSelectionViewController.h"

#import "EMSearchBar.h"
#import "EMRemarkImageView.h"
#import "EMSearchDisplayController.h"
#import "RealtimeSearchUtil.h"
#import "UIImageView+AFNetworking.h"
#import "Friend.h"

@interface ContactSelectionViewController ()<UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NSMutableArray *contactsSource;
@property (strong, nonatomic) NSMutableArray *selectedContacts;
@property (strong, nonatomic) NSMutableArray *blockSelectedUsernames;

@property (strong, nonatomic) EMSearchBar *searchBar;
@property (strong, nonatomic) EMSearchDisplayController *searchController;

@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIScrollView *footerScrollView;
@property (strong, nonatomic) UIButton *doneButton;

@end

@implementation ContactSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _contactsSource = [NSMutableArray array];
        _selectedContacts = [NSMutableArray array];
        
        [self setObjectComparisonStringBlock:^NSString *(id object) {
//            EMBuddy *buddy = (EMBuddy *)object;
//            return buddy.username;
            Friend *f = (Friend *)object;
            return f.username;
        }];
        
        [self setComparisonObjectSelector:^NSComparisonResult(id object1, id object2) {
//            EMBuddy *buddy1 = (EMBuddy *)object1;
//            EMBuddy *buddy2 = (EMBuddy *)object2;
//            
//            return [buddy1.username caseInsensitiveCompare: buddy2.username];
            Friend *buddy1 = (Friend *)object1;
            Friend *buddy2 = (Friend *)object2;
            
            return [buddy1.username caseInsensitiveCompare: buddy2.username];
        }];
    }
    return self;
}

- (instancetype)initWithBlockSelectedUsernames:(NSArray *)blockUsernames
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        _blockSelectedUsernames = [NSMutableArray array];
        [_blockSelectedUsernames addObjectsFromArray:blockUsernames];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"选择联系人";
    self.navigationItem.rightBarButtonItem = nil;
//    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
//    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//    [self.navigationItem setLeftBarButtonItem:backItem];
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.footerView];
    self.tableView.editing = YES;
    self.tableView.frame = CGRectMake(0, self.searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.searchBar.frame.size.height - self.footerView.frame.size.height);
    [self searchController];
    
    if ([_blockSelectedUsernames count] > 0) {
        for (NSString *username in _blockSelectedUsernames) {
            NSInteger section = [self sectionForString:username];
            NSMutableArray *tmpArray = [_dataSource objectAtIndex:section];
            if (tmpArray && [tmpArray count] > 0) {
                for (int i = 0; i < [tmpArray count]; i++) {
//                    EMBuddy *buddy = [tmpArray objectAtIndex:i];
//                    if ([buddy.username isEqualToString:username]) {
//                        [self.selectedContacts addObject:buddy];
//                        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
//                        
//                        break;
//                    }
                    Friend *f = [tmpArray objectAtIndex:i];
                    if ([f.username isEqualToString:username]) {
                        [self.selectedContacts addObject:f];
                        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
                        
                        break;
                    }
                }
            }
        }
        
        if ([_selectedContacts count] > 0) {
            [self reloadFooterView];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (UISearchBar *)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[EMSearchBar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"搜索";
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        _searchBar.backgroundColor = [UIColor colorWithRed:0.747 green:0.756 blue:0.751 alpha:1.000];
    }
    
    return _searchBar;
}

- (EMSearchDisplayController *)searchController
{
    if (_searchController == nil) {
        _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        _searchController.editingStyle = UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete;
        _searchController.delegate = self;
        _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        __weak ContactSelectionViewController *weakSelf = self;
        [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            static NSString *CellIdentifier = @"ContactListCell";
            BaseTableViewCell *cell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
//            EMBuddy *buddy = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
//            cell.imageView.image = [UIImage imageNamed:@"chatListCellHead.png"];
//            cell.textLabel.text = buddy.username;
            
            Friend *f = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            [cell.imageView setImageWithURL:[NSURL URLWithString:f.userimage] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
            cell.textLabel.text = f.username;
            
            return cell;
        }];
        
        [_searchController setCanEditRowAtIndexPath:^BOOL(UITableView *tableView, NSIndexPath *indexPath) {
            if ([weakSelf.blockSelectedUsernames count] > 0) {
//                EMBuddy *buddy = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
//                return ![weakSelf isBlockUsername:buddy.username];
                Friend *f = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
                return ![weakSelf isBlockUsername:f.username];
                
            }
            
            return YES;
        }];
        
        [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
            return 50;
        }];
        
        [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
//            EMBuddy *buddy = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
//            if (![weakSelf.selectedContacts containsObject:buddy])
//            {
//                NSInteger section = [weakSelf sectionForString:buddy.username];
//                if (section >= 0) {
//                    NSMutableArray *tmpArray = [weakSelf.dataSource objectAtIndex:section];
//                    NSInteger row = [tmpArray indexOfObject:buddy];
//                    [weakSelf.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
//                }
//                
//                [weakSelf.selectedContacts addObject:buddy];
//                [weakSelf reloadFooterView];
//            }
            Friend *f = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            if (![weakSelf.selectedContacts containsObject:f])
            {
                NSInteger section = [weakSelf sectionForString:f.username];
                if (section >= 0) {
                    NSMutableArray *tmpArray = [weakSelf.dataSource objectAtIndex:section];
                    NSInteger row = [tmpArray indexOfObject:f];
                    [weakSelf.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
                
                [weakSelf.selectedContacts addObject:f];
                [weakSelf reloadFooterView];
            }
                
        }];
        
        [_searchController setDidDeselectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
//            EMBuddy *buddy = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
//            if ([weakSelf.selectedContacts containsObject:buddy]) {
//                NSInteger section = [weakSelf sectionForString:buddy.username];
//                if (section >= 0) {
//                    NSMutableArray *tmpArray = [weakSelf.dataSource objectAtIndex:section];
//                    NSInteger row = [tmpArray indexOfObject:buddy];
//                    [weakSelf.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:NO];
//                }
//                
//                [weakSelf.selectedContacts removeObject:buddy];
//                [weakSelf reloadFooterView];
//            }
            
            Friend *f = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            if ([weakSelf.selectedContacts containsObject:f]) {
                NSInteger section = [weakSelf sectionForString:f.username];
                if (section >= 0) {
                    NSMutableArray *tmpArray = [weakSelf.dataSource objectAtIndex:section];
                    NSInteger row = [tmpArray indexOfObject:f];
                    [weakSelf.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:NO];
                }
                
                [weakSelf.selectedContacts removeObject:f];
                [weakSelf reloadFooterView];
            }
        }];
    }
    
    return _searchController;
}

- (UIView *)footerView
{
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)];
        _footerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        _footerView.backgroundColor = [UIColor colorWithRed:207 / 255.0 green:210 /255.0 blue:213 / 255.0 alpha:0.7];
        
        _footerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0, _footerView.frame.size.width - 30 - 70, _footerView.frame.size.height - 5)];
        _footerScrollView.backgroundColor = [UIColor clearColor];
        [_footerView addSubview:_footerScrollView];
        
        _doneButton = [[UIButton alloc] initWithFrame:CGRectMake(_footerView.frame.size.width - 80, 8, 70, _footerView.frame.size.height - 16)];
        [_doneButton setBackgroundColor:[UIColor colorWithRed:10 / 255.0 green:82 / 255.0 blue:104 / 255.0 alpha:1.0]];
        [_doneButton setTitle:@"接受" forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_doneButton setTitle:@"确定" forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:_doneButton];
    }
    
    return _footerView;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactListCell";
    BaseTableViewCell *cell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
//    EMBuddy *buddy = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
//    cell.imageView.image = [UIImage imageNamed:@"chatListCellHead.png"];
//    cell.textLabel.text = buddy.username;
    
    
    Friend *f = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:f.userimage] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
    cell.textLabel.text = f.username;
    
    
//    NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
//    NSString *name = [data objectForKey:@"parentname"];
//    NSString *fileid = [data objectForKey:@"fileid"];
//    [cell.imageView setImageWithURL:[NSURL URLWithString:fileid] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
//    cell.textLabel.text = name;
    
    
    
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if ([_blockSelectedUsernames count] > 0) {
//        EMBuddy *buddy = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//        return ![self isBlockUsername:buddy.username];
        
        Friend *f = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        return ![self isBlockUsername:f.username];
    }
    
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (![self.selectedContacts containsObject:object])
    {
        [self.selectedContacts addObject:object];
        
        [self reloadFooterView];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Friend *f = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([self.selectedContacts containsObject:f]) {
        [self.selectedContacts removeObject:f];
        
        [self reloadFooterView];
    }
    
    
//    EMBuddy *buddy = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    if ([self.selectedContacts containsObject:buddy]) {
//        [self.selectedContacts removeObject:buddy];
//        
//        [self reloadFooterView];
//    }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    [self.searchBar setCancelButtonTitle:@"确定"];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.contactsSource searchText:searchText collationStringSelector:@selector(username) resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.searchController.resultsSource removeAllObjects];
                [self.searchController.resultsSource addObjectsFromArray:results];
                [self.searchController.searchResultsTableView reloadData];
                
                for (Friend *f in results) {
                    if ([self.selectedContacts containsObject:f])
                    {
                        NSInteger row = [results indexOfObject:f];
                        [self.searchController.searchResultsTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                    }
                }
                
                
                
//                for (EMBuddy *buddy in results) {
//                    if ([self.selectedContacts containsObject:buddy])
//                    {
//                        NSInteger row = [results indexOfObject:buddy];
//                        [self.searchController.searchResultsTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
//                    }
//                }
            });
        }
    }];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    tableView.editing = YES;
}

#pragma mark - private

- (BOOL)isBlockUsername:(NSString *)username
{
    if (username && [username length] > 0) {
        if ([_blockSelectedUsernames count] > 0) {
            for (NSString *tmpName in _blockSelectedUsernames) {
                if ([username isEqualToString:tmpName]) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

- (void)reloadFooterView
{
    [self.footerScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat imageSize = self.footerScrollView.frame.size.height;
    NSInteger count = [self.selectedContacts count];
    self.footerScrollView.contentSize = CGSizeMake(imageSize * count, imageSize);
    for (int i = 0; i < count; i++) {
        
//        EMBuddy *buddy = [self.selectedContacts objectAtIndex:i];
        
        Friend *f = [self.selectedContacts objectAtIndex:i];
        
        
        EMRemarkImageView *remarkView = [[EMRemarkImageView alloc] initWithFrame:CGRectMake(i * imageSize, 0, imageSize, imageSize)];
//        remarkView.image = [UIImage imageNamed:@"chatListCellHead.png"];
        
        if (f.userimage.length > 0) {
            remarkView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:f.userimage]]];
        }else{
            remarkView.image = [UIImage imageNamed:@"chatListCellHead.png"];
        }
        remarkView.remark = f.username;
        [self.footerScrollView addSubview:remarkView];
    }
    
    if ([self.selectedContacts count] == 0) {
        [_doneButton setTitle:@"确定" forState:UIControlStateNormal];
    }
    else{
        [_doneButton setTitle:[NSString stringWithFormat:@"确定(%lu)", (unsigned long)[self.selectedContacts count]] forState:UIControlStateNormal];
    }
}

#pragma mark - public

- (void)loadDataSource
{
    [self showHudInView:self.view hint:@"加载联系人..."];
    [_dataSource removeAllObjects];
    [_contactsSource removeAllObjects];
    
//    NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
//    for (EMBuddy *buddy in buddyList) {
//        if (buddy.followState != eEMBuddyFollowState_NotFollowed) {
//            [self.contactsSource addObject:buddy];
//        }
//    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *friends = [userDefaults objectForKey:@"friendarr"];
    for (int i = 0 ; i < friends.count ; i++) {
        NSDictionary *data = [friends objectAtIndex:i];
        NSString *name = [data objectForKey:@"parentname"];
        NSString *fileid = [data objectForKey:@"fileid"];
        NSString *hxusercode = [data objectForKey:@"hxusercode"];
        
//        EMBuddy *buddy = [EMBuddy buddyWithUsername:hxusercode];
//        buddy.hxusername = name;
//        buddy.userimg = fileid;
        
        Friend *f = [[Friend alloc] init];
        f.usercode = hxusercode;
        f.username = name;
        f.userimage = fileid;
        
        [self.contactsSource addObject:f];
    }
    
    [_dataSource addObjectsFromArray:[self sortRecords:self.contactsSource]];
    
    [self hideHud];
    [self.tableView reloadData];
}

- (void)doneAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(viewController:didFinishSelectedSources:)]) {
        if ([_blockSelectedUsernames count] == 0) {
            [_delegate viewController:self didFinishSelectedSources:self.selectedContacts];
            [self.navigationController popViewControllerAnimated:NO];
        }
        else{
            NSMutableArray *resultArray = [NSMutableArray array];
            for (EMBuddy *buddy in self.selectedContacts) {
                if(![self isBlockUsername:buddy.username])
                {
                    [resultArray addObject:buddy];
                }
            }
            [_delegate viewController:self didFinishSelectedSources:resultArray];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

@end
