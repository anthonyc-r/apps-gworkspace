/* LSFolder.h
 *  
 * Copyright (C) 2004 Free Software Foundation, Inc.
 *
 * Author: Enrico Sersale <enrico@imago.ro>
 * Date: October 2004
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

#ifndef LS_FOLDER_H
#define LS_FOLDER_H

#include <Foundation/Foundation.h>
#include "FSNodeRep.h"

@class NSWindow;
@class NSView;
@class ResultsTableView;
@class NSTableColumn;
@class ResultsPathsView;
@class NSImage;
@class ProgrView;

@protocol LSFUpdaterProtocol

+ (void)newUpdater:(NSDictionary *)info;

- (oneway void)setFolderInfo:(NSData *)data;

- (oneway void)updateSearchCriteria:(NSData *)data;

- (oneway void)ddbdInsertTrees;

- (oneway void)setAutoupdate:(unsigned)value;

- (oneway void)fastUpdate;

- (oneway void)terminate;

@end


@interface LSFolder : NSObject 
{
  FSNode *node;

  NSMutableDictionary *lsfinfo;
  
  id finder;
  id gworkspace;
  id editor;
  
  BOOL watcherSuspended;

  NSConnection *conn;
  NSConnection *updaterconn;
  id <LSFUpdaterProtocol> updater;
  BOOL waitingUpdater;
  SEL nextSelector;
  BOOL actionPending;
  BOOL updaterbusy;
  unsigned autoupdate;
  
  NSFileManager *fm;
  NSNotificationCenter *nc;
  
  IBOutlet id win;
  BOOL forceclose;

  IBOutlet id topBox;
  IBOutlet id progBox; 
  ProgrView *progView;
  IBOutlet id elementsLabel;
  NSString *elementsStr;
  IBOutlet id editButt;
  IBOutlet id autoupdatePopUp;
  IBOutlet id updateButt;
  
  IBOutlet id splitView;
  
  IBOutlet id resultsScroll;
  ResultsTableView *resultsView;
  NSTableColumn *nameColumn;
  NSTableColumn *parentColumn;
  NSTableColumn *dateColumn;
  NSTableColumn *sizeColumn;
  NSTableColumn *kindColumn;  
  
  IBOutlet id pathsScroll;
  ResultsPathsView *pathsView;
  int visibleRows;

  NSMutableArray *foundObjects;
  FSNInfoType currentOrder;
}

- (id)initForFinder:(id)fndr
           withNode:(FSNode *)anode
      needsIndexing:(BOOL)index;

- (void)setNode:(FSNode *)anode;

- (FSNode *)node;

- (NSString *)infoPath;

- (NSString *)foundPath;

- (BOOL)watcherSuspended;

- (void)setWatcherSuspended:(BOOL)value;

- (BOOL)isOpen;

- (IBAction)setAutoupdateCycle:(id)sender;

- (IBAction)updateIfNeeded:(id)sender;

- (void)startUpdater;
          
- (void)checkUpdater:(id)sender;

- (void)setUpdater:(id)anObject;

- (void)updaterDidEndAction;

- (void)updaterError:(NSString *)err;

- (void)addFoundPath:(NSString *)path;

- (void)removeFoundPath:(NSString *)path;

- (void)clearFoundPaths;

- (void)endUpdate;

- (void)connectionDidDie:(NSNotification *)notification;

- (void)loadInterface;

- (void)closeWindow;

- (NSDictionary *)getSizes;

- (void)saveSizes;

- (void)updateShownData;

- (void)setCurrentOrder:(FSNInfoType)order;

- (NSArray *)selectedObjects;

- (void)selectObjects:(NSArray *)objects;

- (void)doubleClickOnResultsView:(id)sender;

- (IBAction)openEditor:(id)sender;

- (NSArray *)searchPaths;

- (NSDictionary *)searchCriteria;

- (BOOL)recursive;

- (void)setSearchCriteria:(NSDictionary *)criteria 
                recursive:(BOOL)rec;

- (void)fileSystemDidChange:(NSNotification *)notif;

@end


@interface ProgrView : NSView 
{
  NSMutableArray *images;
  int index;
  float rfsh;
  NSTimer *progTimer;
  BOOL animating;
}

- (id)initWithFrame:(NSRect)frameRect 
    refreshInterval:(float)refresh;

- (void)start;

- (void)stop;

- (void)animate:(id)sender;

@end

#endif // LS_FOLDER_H