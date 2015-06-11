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
    DBItemTableViewSectionNameOrder
};

@interface DBItemTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *orderSegmentedControl;

@property (strong, nonatomic) DBCategory *category;
@property (nonatomic) BOOL canTakeOrder;

@end

@implementation DBItemTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction:)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    
    if (!self.item) {
        self.navigationItem.title = @"Create item";
    } else {
        self.canTakeOrder = YES;
        self.navigationItem.title = @"Edit item";
        
        [self.item addObserver:self forKeyPath:@"count"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
        
        self.nameTextField.text = self.item.name;
        self.infoTextView.text = self.item.info;
        self.category = self.item.category;
    }
    
    self.orderSegmentedControl.enabled = self.canTakeOrder;
}

- (void)dealloc {
    [self.item removeObserver:self forKeyPath:@"count"];

    NSLog(@"              ITEM VIEW CONTROLLER IS DEALOCATED");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    NSLog(@"\nobserveValueForKeyPath: %@\nofObject: %@\nchange: %@", keyPath, object, change);
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:DBItemTableViewSectionNameOrder]
                  withRowAnimation:UITableViewRowAnimationNone];
    
//    id value = [change objectForKey:NSKeyValueChangeNewKey];
    
    
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - <UITableViewDataSource>

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if (section == DBItemTableViewSectionNameOrder) {
        return [NSString stringWithFormat:@"Current count: %@", self.item.count];
    }
    
    return nil;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"chooseCategory"]) {
        
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            
            __block UITableViewCell *cell = sender;
            
            [[segue destinationViewController] setBlock:^(DBCategory *category) {
                self.category = category;
                cell.textLabel.text = category.name;
            }];
        }
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
            }];
        });
    }];
    */
    
    
    /*
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alertView show];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
    });
     
     */
    
}

#pragma mark - Actions

- (void)saveAction:(UIBarButtonItem *)sender {
    
    if (!self.item) {
        self.item = [[DBItemManager sharedManager] createItem];
        [self.item addObserver:self forKeyPath:@"count"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
    }
    
    self.item.name = self.nameTextField.text;
    self.item.info = self.infoTextView.text;
    self.item.category = self.category;
    
    [self showSimpleViewOnTopWithTitle:@"Saved"];
    
    self.canTakeOrder = YES;
    self.orderSegmentedControl.enabled = YES;
    
//    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)orderAction:(UISegmentedControl *)sender {
   
    NSUInteger count = pow(10, sender.selectedSegmentIndex) * 10; // 10, 100 and 1000
    
    NSString *title = [NSString stringWithFormat:@"Ordered %lu", (unsigned long)count];
    
    [self showSimpleViewOnTopWithTitle:title];

    [[DBItemManager sharedManager] addCount:count toItem:self.item];
}

@end
