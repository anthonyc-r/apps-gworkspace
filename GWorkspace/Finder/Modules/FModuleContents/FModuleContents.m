/* FModuleContents.m
 *  
 * Copyright (C) 2004 Free Software Foundation, Inc.
 *
 * Author: Enrico Sersale <enrico@imago.ro>
 * Date: March 2004
 *
 * This file is part of the GNUstep GWorkspace application
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include "FinderModulesProtocol.h"

#define MAXFSIZE 600000

static NSString *nibName = @"FModuleContents";

@interface FModuleContents : NSObject <FinderModulesProtocol>
{  
  IBOutlet id win;
  IBOutlet id controlsBox;
  IBOutlet id label;
  IBOutlet id textField;
  int index;
  BOOL used;

  NSString *contentsStr;
  const char *contentsPtr;
  NSFileManager *fm;
}

@end

@implementation FModuleContents

- (void)dealloc
{
  TEST_RELEASE (controlsBox);
  TEST_RELEASE (contentsStr);
  [super dealloc];
}

- (id)initInterface
{
	self = [super init];

  if (self) {
		if ([NSBundle loadNibNamed: nibName owner: self] == NO) {
      NSLog(@"failed to load %@!", nibName);
      DESTROY (self);
      return self;
    }

    RETAIN (controlsBox);
    RELEASE (win);

    used = NO;
    index = 0;
    
    contentsStr = nil;
    
    [textField setStringValue: @""];

    /* Internationalization */    
    [label setStringValue: NSLocalizedString(@"includes", @"")];
  }
  
	return self;
}

- (id)initWithSearchCriteria:(NSDictionary *)criteria
{
	self = [super init];

  if (self) {
    ASSIGN (contentsStr, [criteria objectForKey: @"what"]);
    contentsPtr = [contentsStr UTF8String];
    fm = [NSFileManager defaultManager];
  }
  
	return self;
}

- (void)setControlsState:(NSDictionary *)info
{
  NSString *str = [info objectForKey: @"what"];
  
  if (str && [str length]) {
    [textField setStringValue: str];
  }
}

- (id)controls
{
  return controlsBox;
}

- (NSString *)moduleName
{
  return NSLocalizedString(@"contents", @"");
}

- (BOOL)used
{
  return used;
}

- (void)setInUse:(BOOL)value
{
  used = value;
}

- (int)index
{
  return index;
}

- (void)setIndex:(int)idx
{
  index = idx;
}

- (NSDictionary *)searchCriteria
{
  NSString *str = [textField stringValue];
  
  if ([str length] != 0) {
    return [NSDictionary dictionaryWithObject: str forKey: @"what"];
  }

  return nil;
}

- (BOOL)checkPath:(NSString *)path 
   withAttributes:(NSDictionary *)attributes
{
  BOOL contains = NO;
  
  if (([attributes fileSize] < MAXFSIZE) 
            && ([attributes fileType] == NSFileTypeRegular)) {
    CREATE_AUTORELEASE_POOL(pool);
    NSData *contents = [NSData dataWithContentsOfFile: path];

    if (contents && [contents length]) {
      const char *bytesStr = (const char *)[contents bytes];
      contains = (strstr(bytesStr, contentsPtr) != NULL);
    }
    
    RELEASE (pool);
  }
  
  return contains;
}

- (int)compareModule:(id <FinderModulesProtocol>)module
{
  int i1 = [self index];
  int i2 = [module index];

  if (i1 < i2) {
    return NSOrderedAscending;
  } else if (i1 > i2) {
    return NSOrderedDescending;
  } 

  return NSOrderedSame;
}

- (BOOL)reliesOnModDate
{
  return YES;
}

- (BOOL)reliesOnDirModDate
{
  return NO;
}

@end

