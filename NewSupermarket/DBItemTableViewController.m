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
    
    //id value = [change objectForKey:NSKeyValueChangeNewKey];
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - <UITableViewDataSource>

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if (section == 0) {
        return [NSString stringWithFormat:@"Count: %@", self.item.count];
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

- (void)showViewWithTitle:(NSString *)title {
    
    CGFloat side = 100.0;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds) - side / 2.0, -100.0, side, side)];
    
    view.backgroundColor = [UIColor lightGrayColor];
    view.layer.cornerRadius = 5.0;
    
    UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    
    [view addSubview:label];
    
    [self.view addSubview:view];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect frame = view.frame;
        frame.origin.y = CGRectGetMidY(self.view.bounds) - side / 2.0;
        view.frame = frame;
        
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                view.alpha = 0.0;
            }];
//            [view removeFromSuperview];

        });
    }];
    
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
    
    [self showViewWithTitle:@"Saved"];
    
    self.canTakeOrder = YES;
    self.orderSegmentedControl.enabled = YES;
    
//    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)orderAction:(UISegmentedControl *)sender {
   
    NSUInteger count = pow(10,sender.selectedSegmentIndex);
    
    UITableView *tableView = self.tableView;
    
    [[DBItemManager sharedManager] addCount:count toItem:self.item withBlock:^{
        [tableView reloadData];
    }];
}

@end
