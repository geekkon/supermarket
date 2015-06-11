//
//  DBItemViewController.m
//  NewSupermarket
//
//  Created by Dim on 12.06.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import "DBItemViewController.h"
#import "DBItem.h"
#import "DBItemManager.h"

@interface DBItemViewController ()

@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end

@implementation DBItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Buy item";

    [self updateCountLabel];
    
    [self.item addObserver:self forKeyPath:@"count"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
    
    [self.item addObserver:self forKeyPath:@"name"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
    
    [self.item addObserver:self forKeyPath:@"info"
                   options:NSKeyValueObservingOptionNew
                   context:nil];


}

- (void)dealloc {
    [self.item removeObserver:self forKeyPath:@"count"];
    [self.item removeObserver:self forKeyPath:@"name"];
    [self.item removeObserver:self forKeyPath:@"info"];

    
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
    

    [self updateCountLabel];
    
    //    id value = [change objectForKey:NSKeyValueChangeNewKey];
    
    
}

#pragma mark - Private Methods

- (void)updateCountLabel {
    self.countLabel.text = [NSString stringWithFormat:@"Current count: %@", self.item.count];
}

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
}

#pragma mark - Actions

- (IBAction)orderAction:(UISegmentedControl *)sender {
    
    NSUInteger count = pow(10, sender.selectedSegmentIndex); // 1, 10 and 100
    
    NSString *title = [NSString stringWithFormat:@"Ordered %lu", (unsigned long)count];
    
    [self showSimpleViewOnTopWithTitle:title];
    
    [[DBItemManager sharedManager] addCount:(-count) toItem:self.item];
}

@end
