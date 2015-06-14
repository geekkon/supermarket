//
//  DBItemTableViewController.m
//  NewSupermarket
//
//  Created by Dim on 09.06.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import "DBItemTableViewController.h"
#import "DBCategoryTableViewController.h"
#import "DBItem.h"
#import "DBCategory.h"
#import "DBItemManager.h"

NS_ENUM(NSUInteger, DBItemTableViewSectionName) {
    DBItemTableViewSectionNameOrder,
    DBItemTableViewSectionNameCategory,
    DBItemTableViewSectionNameNameInfo
};

NS_ENUM(NSUInteger, DBSaveAlertViewButtonType) {
    DBSaveAlertViewButtonTypeNO,
    DBSaveAlertViewButtonTypeYES
};

@interface DBItemTableViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *orderSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *nameTextView;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;

@property (strong, nonatomic) DBCategory *category;

@end

@implementation DBItemTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.segueFromBuyController) {
        
        self.nameTextView.editable = NO;
        self.infoTextView.editable = NO;
        self.tableView.allowsSelection = NO;
        
    } else {
        
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction:)];
        
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    
    if (!self.item) {
        self.navigationItem.title = @"Create item";
    } else {
        self.navigationItem.title = self.segueFromBuyController ? @"Order item" : @"Edit item";
        
        [self.item addObserver:self forKeyPath:@"count"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
        
        self.nameTextView.text = self.item.name;
        self.infoTextView.text = self.item.info;
        self.category = self.item.category;
        self.categoryNameLabel.text = self.category.name;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.category) {
        // if current category was renamed but not chosen
        self.categoryNameLabel.text = self.category.name;
    }
}

- (void)dealloc {
    
    [self.item removeObserver:self forKeyPath:@"count"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:DBItemTableViewSectionNameOrder]
                  withRowAnimation:UITableViewRowAnimationNone];
    
    UITableViewHeaderFooterView *footerView = [self.tableView footerViewForSection:DBItemTableViewSectionNameOrder];
    
    [self showSimpleViewOnTopWithTitle:@"Current count is changed"];
    [self pullDownView:footerView.contentView];
}

#pragma mark - <UITableViewDataSource>

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if (section == DBItemTableViewSectionNameOrder) {
        return [NSString stringWithFormat:@"Current count: %@", self.item.count ? self.item.count : @"0"];
    }
    
    return nil;
}

#pragma mark - <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == DBSaveAlertViewButtonTypeYES) {
        [self saveAction:nil];
    }
}

#pragma mark - Private Methods

- (void)showSimpleViewOnTopWithTitle:(NSString *)title {
    
    CGFloat height = 64.0;
    CGFloat shadowOffsetY = 3.0;
    CGFloat animateDuraition = 0.3;
    CGFloat presentingDuration = 0.5;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, - (height + shadowOffsetY), CGRectGetWidth(self.view.window.bounds), height)];
    
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0, shadowOffsetY);
    view.layer.shadowOpacity = 0.5;
    
    UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkGrayColor];
    label.text = title;
    
    [view addSubview:label];
    
    [self.view.window addSubview:view];
    
    [UIView animateWithDuration:animateDuraition animations:^{
        CGRect frame = view.frame;
        frame.origin.y = 0.0;
        view.frame = frame;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(presentingDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:animateDuraition animations:^{
                CGRect frame = view.frame;
                frame.origin.y = - (height + shadowOffsetY);
                view.frame = frame;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animateDuraition * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [view removeFromSuperview];
                });
            }];
        });
    }];
    
    /*
    CGFloat height = 40.0;
    CGFloat width  = 120.0;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds) - width / 2.0, CGRectGetMidY(self.view.bounds) - height / 2.0, width, height)];
    
    view.backgroundColor = [UIColor lightGrayColor];
    view.layer.cornerRadius = 20.0;
    
    UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = title;
    
    [view addSubview:label];
    
    view.alpha = 0.0;
    
    [self.view addSubview:view];
    
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = 1.0;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                view.alpha = 0.0;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [view removeFromSuperview];
                });
            }];
        });
    }];
    */
}

- (void)showAlertViewForSaving {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Item not saved yet"
                                                        message:@"Do you want to save it?"
                                                       delegate:self
                                              cancelButtonTitle:@"NO"
                                              otherButtonTitles:@"YES", nil];
    
    [alertView show];
}

#pragma mark - Animations

- (void)pullDownView:(UIView *)view {
    
    CGFloat offset = 7.0;
    
    __block CGRect frame = view.frame;
    
    [UIView animateWithDuration:0.1
                     animations:^{
                         frame.origin.y += offset;
                         view.frame = frame;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3
                                          animations:^{
                                              frame.origin.y -= offset;
                                              view.frame = frame;
                                          }];
                         
                     }];
}

- (void)shakeView:(UIView *)view {
    
    CGFloat offset = 5.0;
    
    view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -offset, 0.0);
    
    [UIView animateWithDuration:0.07
                     animations:^{
                         [UIView setAnimationRepeatAutoreverses:YES];
                         [UIView setAnimationRepeatCount:2.0];
                         view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, offset, 0.0);
                     } completion:^(BOOL finished) {
                         if (finished) {
                             [UIView animateWithDuration:0.05
                                              animations:^{
                                                  [UIView setAnimationBeginsFromCurrentState:YES];
                                                  view.transform = CGAffineTransformIdentity;
                                              }];
                         }
                     }];
}


- (BOOL)isFieldsFilled {
    
    if (!self.category) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:DBItemTableViewSectionNameCategory];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        [self showSimpleViewOnTopWithTitle:@"Please, choose a category"];
     
        [self shakeView:cell];
        
        return NO;
    }
    
    if (!self.nameTextView.text.length) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:DBItemTableViewSectionNameNameInfo];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        [self showSimpleViewOnTopWithTitle:@"Please, enter a name"];
        
        [self shakeView:cell];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"chooseCategory"]) {
        
        __weak DBItemTableViewController *weakSelf = self;
        
        [[segue destinationViewController] setBlock:^(DBCategory *category) {
            weakSelf.category = category;
            weakSelf.categoryNameLabel.text = category.name;
        }];
    }
}

#pragma mark - Actions

- (void)saveAction:(UIBarButtonItem *)sender {
    
    if (!self.item) {
        
        if (![self isFieldsFilled]) {
            return;
        }
            
        self.item = [[DBItemManager sharedManager] createItem];
        
        [self.item addObserver:self forKeyPath:@"count"
                       options:NSKeyValueObservingOptionNew
                           context:nil];
    }
    
    self.item.name = self.nameTextView.text;
    self.item.info = self.infoTextView.text;
    self.item.category = self.category;
    
    [[DBItemManager sharedManager] save];
    
    [self showSimpleViewOnTopWithTitle:@"Saved"];
}

- (IBAction)orderAction:(UISegmentedControl *)sender {
    
    if (!self.item) {
        [self showAlertViewForSaving];
        return;
    }
    
    NSInteger count = pow(10, sender.selectedSegmentIndex); // 1, 10, 100, 1 000 and 10 000
    
    NSString *title = [NSString stringWithFormat:@"Ordered %ld", (long)count];
    
    [self showSimpleViewOnTopWithTitle:title];
    
    if (self.segueFromBuyController) {
        count *= -1;
    }

    [[DBItemManager sharedManager] addCount:count toItem:self.item];
}

- (IBAction)tapAction:(UITapGestureRecognizer *)sender {
    
    if ([self.nameTextView isFirstResponder]) {
        [self.nameTextView resignFirstResponder];
    } else if ([self.infoTextView isFirstResponder]) {
        [self.infoTextView resignFirstResponder];
    }
}

@end
