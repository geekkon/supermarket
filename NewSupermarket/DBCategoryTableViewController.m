//
//  DBCategoryTableViewController.m
//  NewSupermarket
//
//  Created by Dim on 08.06.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import "DBCategoryTableViewController.h"
#import "DBItemManager.h"
#import "DBCategory.h"

NS_ENUM(NSUInteger, UIAlertViewButtonType) {
    UIAlertViewButtonTypeCancel,
    UIAlertViewButtonTypeDone
};

static const NSUInteger MAX_LENGTH = 32; // max length of category name for plain UITableViewStyle

@interface DBCategoryTableViewController () <NSFetchedResultsControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) DBCategory *editingCategory;

@end

@implementation DBCategoryTableViewController

#pragma mark - Getters

- (NSManagedObjectContext *)managedObjectContext {
    
    if (!_managedObjectContext) {
        _managedObjectContext = [DBItemManager sharedManager].managedObjectContext;
    }
    
    return _managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    fetchRequest.entity = [NSEntityDescription entityForName:@"DBCategory"
                                      inManagedObjectContext:self.managedObjectContext];
    
    fetchRequest.fetchBatchSize = 20;

    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                   ascending:YES]];
 
    _fetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DBCategory *selectedCategory = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (self.block) {
        self.block(selectedCategory);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    DBCategory *category = [self.fetchedResultsController objectAtIndexPath:indexPath];

    [self renameCategory:category];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return @"Delete category and items";
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    
    DBCategory *category = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = category.name;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        DBCategory *category = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[DBItemManager sharedManager] deleteCategory:category];
    }
}

#pragma mark - <NSFetchedResultsControllerDelegate>

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
      default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView endUpdates];
}

#pragma mark - <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
 
    if (buttonIndex == UIAlertViewButtonTypeDone) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if (self.editingCategory) {
            [[DBItemManager sharedManager] renameCategory:self.editingCategory
                                                 withName:textField.text];
        } else {
            [[DBItemManager sharedManager] createCategoryWithName:textField.text];
        }
    } else if (buttonIndex == UIAlertViewButtonTypeCancel) {
        self.editingCategory = nil;
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    
    if (textField.text.length) {
        return YES;
    }
    
    return NO;
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ((textField.text.length + string.length) > MAX_LENGTH) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Private Methods

- (void)showAlertWithTitle:(NSString *)title andText:(NSString *)text {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Done", nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    
    textField.placeholder = @"Name";
    textField.text = text;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    textField.autocorrectionType = UITextAutocorrectionTypeYes;
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    
    [alertView show];
}

- (void)renameCategory:(DBCategory *)category {
    
    self.editingCategory = category;
    
    [self showAlertWithTitle:@"Rename category" andText:category.name];
}


#pragma mark - Actions

- (IBAction)addAction:(UIBarButtonItem *)sender {
    
    [self showAlertWithTitle:@"Create new category" andText:nil];
}

@end
