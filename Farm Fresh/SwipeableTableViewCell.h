//
//  SwipeableTableViewCell.h
//  Farm Fresh
//
//  Created by Randall Rumple on 6/11/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SwipeableTableViewCellDelegate <NSObject>
- (void)deleteButtonPressedAtIndex: (NSIndexPath *)indexPath;
- (void)editButtonPressedAtIndex: (NSIndexPath *)indexPath;
- (void)makeInactiveButtonPressedAtIndex: (NSIndexPath *)indexPath;
- (void)reListButtonPressedAtIndex:(NSIndexPath *)indexPath;

@end

@interface SwipeableTableViewCell : UITableViewCell

@property (nonatomic, weak) id <SwipeableTableViewCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic) BOOL isOpen;

- (void)showRelistButton;
- (void)showMakeInactiveButton;
- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate;
- (void)resetConstraintContstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)notifyDelegate;

@end
