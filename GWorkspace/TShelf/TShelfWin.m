 /*  -*-objc-*-
 *  TShelfWin.m: Implementation of the TShelfWin Class 
 *  of the GNUstep GWorkspace application
 *
 *  Copyright (c) 2003 Enrico Sersale <enrico@imago.ro>
 *  
 *  Author: Enrico Sersale
 *  Date: August 2003
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include "TShelfWin.h"
#include "TShelfView.h"
#include "TShelfViewItem.h"
#include "TShelfIconsView.h"
#include "Dialogs/Dialogs.h"
#include "GNUstep.h"

#define SHELF_HEIGHT 112

@implementation TShelfWin

- (void)dealloc
{
  RELEASE (tView);
  
  [super dealloc];
}

- (id)init
{
  float sizew = [[NSScreen mainScreen] frame].size.width; 

  self = [super initWithContentRect: NSMakeRect(0, 0, sizew, SHELF_HEIGHT)
                          styleMask: NSBorderlessWindowMask 
                            backing: NSBackingStoreBuffered 
                              defer: NO];

  if (self) {
    NSUserDefaults *defaults;
    NSDictionary *tshelfDict;
    NSArray *tabsArr;    
		TShelfViewItem *item;
    TShelfIconsView *view;
    int i;
    
		[self setReleasedWhenClosed: NO];
        
    tView = [[TShelfView alloc] initWithFrame: [[self contentView] frame]];
    [self setContentView: tView];		
    
    defaults = [NSUserDefaults standardUserDefaults];	
    
    tshelfDict = [defaults objectForKey: @"tabbedshelf"];
    if (tshelfDict == nil) {
      tshelfDict = [NSDictionary dictionary];
    }
        
    tabsArr = [tshelfDict objectForKey: @"tabs"];
    
    if (tabsArr) {
      for (i = 0; i < [tabsArr count]; i++) {
        NSDictionary *dict = [tabsArr objectAtIndex: i];
        NSString *label = [[dict allKeys] objectAtIndex: 0];
        NSArray *iconsDicts = [dict objectForKey: label];
    
        item = [TShelfViewItem new];
        [item setLabel: label];
        view = [[TShelfIconsView alloc] initWithIconsDicts: iconsDicts];
        [view setFrame: NSMakeRect(0, 0, sizew, 80)];    
        [item setView: view];
        RELEASE (view);
        
        if ([label isEqual: @"last"]) {
          [tView setLastTabItem: item];
        } else {
          [tView addTabItem: item];
        }
        
        RELEASE (item);
      }
      
    } else {
      item = [TShelfViewItem new];
      [item setLabel: @"last"];
      view = [[TShelfIconsView alloc] initWithIconsDicts: nil];
      [view setFrame: NSMakeRect(0, 0, sizew, 80)];
      [item setView: view];
      RELEASE (view);
      [tView setLastTabItem: item];
      RELEASE (item);
      [self saveDefaults];
    }
  }
  
  return self;
}

- (void)activate
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
  NSDictionary *tshelfDict = [defaults objectForKey: @"tabbedshelf"];

  [self makeKeyAndOrderFront: nil];
  
  if (tshelfDict) {
    [tView setHiddenTabs: [[tshelfDict objectForKey: @"hiddentabs"] boolValue]];
  }
}

- (void)deactivate
{
  [self orderOut: nil];
}

- (void)addTab
{
  FileOpsDialog *dialog;
  NSString *tabName;
  NSArray *items;
  TShelfViewItem *item;
  TShelfIconsView *view;
  BOOL duplicate;
  int result;
  int index;
  int i;
    
  if ([self isVisible] == NO) {
    return;
  }

	dialog = [[FileOpsDialog alloc] initWithTitle: NSLocalizedString(@"Add Tab", @"") editText: @""];
  AUTORELEASE (dialog);
	[dialog center];
  [dialog makeKeyWindow];
  [dialog orderFrontRegardless];

  result = [dialog runModal];
	if(result != NSAlertDefaultReturn) {
    return;
  }  

  tabName = [dialog getEditFieldText];

  if ([tabName length] == 0) {
		NSString *msg = NSLocalizedString(@"No name supplied!", @"");
		NSString *buttstr = NSLocalizedString(@"Continue", @"");		
    NSRunAlertPanel(nil, msg, buttstr, nil, nil);  
    return;
  }

  items = [tView items];

  duplicate = NO;
  for (i = 0; i < [items count]; i++) {
    item = [items objectAtIndex: i];

    if ([[item label] isEqual: tabName]) {
      duplicate = YES;
      break;
    }
  }

  if (duplicate) {
		NSString *msg = NSLocalizedString(@"Duplicate tab name!", @"");
		NSString *buttstr = NSLocalizedString(@"Continue", @"");		
    NSRunAlertPanel(nil, msg, buttstr, nil, nil);  
    return;
  }
  
  item = [tView selectedTabItem];
  index = [tView indexOfItem: item];
  
  item = [TShelfViewItem new];
  [item setLabel: tabName];
  view = [[TShelfIconsView alloc] initWithIconsDicts: nil];
  [view setFrame: NSMakeRect(0, 0, [[NSScreen mainScreen] frame].size.width, 80)];
  [item setView: view];
  RELEASE (view);
  [tView insertTabItem: item atIndex: (index + 1)];
  [tView selectTabItem: item];  
  RELEASE (item);
  
  [self saveDefaults];
}

- (void)removeTab
{
  NSArray *items;
  TShelfViewItem *item;
	NSString *title, *msg, *buttstr;
  int index;
  int result;
    
  if ([self isVisible] == NO) {
    return;
  }

  items = [tView items];
  item = [tView selectedTabItem];
  index = [tView indexOfItem: item];
  
  if (([items count] == 1) || (item == [tView lastTabItem])) {
		msg = NSLocalizedString(@"You can't remove the last tab!", @"");
		buttstr = NSLocalizedString(@"Continue", @"");		
    NSRunAlertPanel(nil, msg, buttstr, nil, nil);  
    return;
  }

	title = NSLocalizedString(@"Remove Tab", @"");
	msg = NSLocalizedString(@"Are you sure that you want to remove the selected tab?", @"");
	buttstr = NSLocalizedString(@"Continue", @"");
  result = NSRunAlertPanel(title, msg, 
                  NSLocalizedString(@"OK", @""), buttstr, NULL);
  if(result != NSAlertDefaultReturn) {
    return;
  }

  if ([tView removeTabItem: item] == NO) {
		msg = NSLocalizedString(@"You can't remove this tab!", @"");
		buttstr = NSLocalizedString(@"Continue", @"");		
    NSRunAlertPanel(nil, msg, buttstr, nil, nil);  
    return;
  }
  
  [tView selectTabItem: [tView lastTabItem]];  
  
  [self saveDefaults];
}

- (void)renameTab
{
  FileOpsDialog *dialog;
  NSString *oldName;
  NSString *tabName;
  NSArray *items;
  TShelfViewItem *item;
  BOOL duplicate;
  int result;
  int index;
  int i;
    
  if ([self isVisible] == NO) {
    return;
  }

  items = [tView items];
  item = [tView selectedTabItem];
  oldName = [item label];
  index = [tView indexOfItem: item];

  if (item == [tView lastTabItem]) {
		NSString *msg = NSLocalizedString(@"You can't rename this tab!", @"");
		NSString *buttstr = NSLocalizedString(@"Continue", @"");		
    NSRunAlertPanel(nil, msg, buttstr, nil, nil);  
    return;
  }

	dialog = [[FileOpsDialog alloc] initWithTitle: NSLocalizedString(@"Rename Tab", @"") 
                                       editText: oldName];
  AUTORELEASE (dialog);
	[dialog center];
  [dialog makeKeyWindow];
  [dialog orderFrontRegardless];

  result = [dialog runModal];
	if(result != NSAlertDefaultReturn) {
    return;
  }  

  tabName = [dialog getEditFieldText];

  if ([tabName length] == 0) {
		NSString *msg = NSLocalizedString(@"No name supplied!", @"");
		NSString *buttstr = NSLocalizedString(@"Continue", @"");		
    NSRunAlertPanel(nil, msg, buttstr, nil, nil);  
    return;
  }

  duplicate = NO;
  for (i = 0; i < [items count]; i++) {
    TShelfViewItem *itm = [items objectAtIndex: i];

    if ([[itm label] isEqual: tabName]) {
      duplicate = YES;
      break;
    }
  }

  if (duplicate) {
		NSString *msg = NSLocalizedString(@"Duplicate tab name!", @"");
		NSString *buttstr = NSLocalizedString(@"Continue", @"");		
    NSRunAlertPanel(nil, msg, buttstr, nil, nil);  
    return;
  }
    
  [item setLabel: tabName];
  [tView selectTabItemAtIndex: index];  
  
  [self saveDefaults];
}

- (void)updateIcons
{

}

- (void)saveDefaults
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
  NSMutableDictionary *tshelfDict = [NSMutableDictionary dictionary];
  NSArray *items = [tView items];
  NSMutableArray *tabsArr = [NSMutableArray array];
  int i;

  [tshelfDict setObject: [NSNumber numberWithBool: [tView hiddenTabs]] 
                 forKey: @"hiddentabs"];

  for (i = 0; i < [items count]; i++) {
    TShelfViewItem *item = [items objectAtIndex: i];
    NSString *label = [item label];
    TShelfIconsView *iview = (TShelfIconsView *)[item view];
    NSArray *iconsDicts = [iview iconsDicts];
    NSDictionary *tdict = [NSDictionary dictionaryWithObject: iconsDicts 
                                                      forKey: label];
    [tabsArr addObject: tdict];
  }

  [tshelfDict setObject: tabsArr forKey: @"tabs"];

  [defaults setObject: tshelfDict forKey: @"tabbedshelf"];
  [defaults synchronize];
}

@end
