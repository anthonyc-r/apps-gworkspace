/*
 *  GWorkspace.h: Principal Class  
 *  of the GNUstep GWorkspace application
 *
 *  Copyright (c) 2001 Enrico Sersale <enrico@imago.ro>
 *  
 *  Author: Enrico Sersale
 *  Date: August 2001
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

#ifndef GWORKSPACE_H
#define GWORKSPACE_H

#include <AppKit/NSApplication.h>
  #ifdef GNUSTEP 
#include "GWProtocol.h"
  #else
#include <GWorkspace/GWProtocol.h>
  #endif

#define NOEDIT 0
#define NOXTERM 1

@class NSString;
@class NSArray;
@class NSMutableArray;
@class NSMutableDictionary;
@class NSNotification;
@class NSTimer;
@class NSFileManager;
@class NSWorkspace;
@class ViewersWindow;
@class InspectorsController;
@class PrefController;
@class FinderController;
@class AppsViewer;
@class Watcher;
@class Fiend;
@class Recycler;
@class History;
@class DesktopWindow;
@class DesktopView;
@class TShelfWin;
@class FileOperation;
@class OpenWithController;
@class RunExternalController;

@interface GWorkspace : NSObject <GWProtocol>
{
	NSString *defEditor, *defXterm, *defXtermArgs;
	int defSortType;
	
  NSMutableArray *operations;
  int oprefnum;
  BOOL showFileOpStatus;

	NSMutableArray *lockedPaths;
  
  InspectorsController *inspController;
	NSArray *selectedPaths;
	
  AppsViewer *appsViewer;
  FinderController *finder;
  PrefController *prefController;
  Fiend *fiend;
  History *history;
	
  ViewersWindow *rootViewer, *currentViewer;	
  NSMutableArray *viewers;
  NSMutableArray *viewersSearchPaths;
	NSMutableArray *viewersTemplates;

  BOOL hideSysFiles;

  BOOL animateChdir;
  BOOL animateLaunck;
  BOOL animateSlideBack;

  BOOL contestualMenu;

  DesktopWindow *desktopWindow;
  
  TShelfWin *tshelfWin;
  NSImage *tshelfBackground;
  
	Recycler *recycler;
	NSString *trashPath;
	  
  OpenWithController *openWithController;
  RunExternalController *runExtController;
  
  NSMutableArray *watchers;
	NSMutableArray *watchTimers;
  NSMutableArray *watchedPaths;  

  NSMutableDictionary *tumbsCache;
  
  NSString *thumbnailDir;
  BOOL usesThumbnails;
  NSMutableDictionary *cachedContents;
  int cachedMax;
	      
  int shelfCellsWidth;
        
  NSFileManager *fm;
  NSWorkspace *ws;
  
  BOOL starting;
}

+ (void)registerForServices;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- (BOOL)applicationShouldTerminate:(NSApplication *)app;

- (NSString *)defEditor;

- (NSString *)defXterm;

- (NSString *)defXtermArgs;

- (History *)historyWindow;

- (id)desktopView;	

- (void)showHideDesktop:(BOOL)active;

- (NSImage *)tshelfBackground;	

- (void)makeTshelfBackground;

- (NSColor *)tshelfBackColor;	

- (id)rootViewer;

- (void)changeDefaultEditor:(NSString *)editor;

- (void)changeDefaultXTerm:(NSString *)xterm arguments:(NSString *)args;
                             
- (void)updateDefaults;
					 
- (void)startXTermOnDirectory:(NSString *)dirPath;

- (int)defaultSortType;

- (void)setDefaultSortType:(int)type;

- (int)shelfCellsWidth; 

- (int)defaultShelfCellsWidth; 

- (void)setShelfCellsWidth:(int)w; 

- (void)createRecycler;

- (void)makeViewersTemplates;

- (void)addViewer:(id)vwr withBundlePath:(NSString *)bpath;

- (void)removeViewerWithBundlePath:(NSString *)bpath;

- (NSMutableArray *)bundlesWithExtension:(NSString *)extension 
											       inDirectory:(NSString *)dirpath;

- (NSArray *)viewersPaths;

- (void)viewerHasClosed:(id)sender;

- (void)setCurrentViewer:(ViewersWindow *)viewer;

- (void)setHideDotFiles:(NSNotification *)notif;

- (void)iconAnimationChanged:(NSNotification *)notif;

- (BOOL)showFileOpStatus;

- (void)setShowFileOpStatus:(BOOL)value;

- (void)fileSystemWillChangeNotification:(NSNotification *)notif;

- (void)fileSystemDidChangeNotification:(NSNotification *)notif;
           
- (void)watcherNotification:(NSNotification *)notification;           
           
- (void)setSelectedPaths:(NSArray *)paths;

- (void)setSelectedPaths:(NSArray *)paths fromDeskTopView:(DesktopView *)view;

- (void)setSelectedPaths:(NSArray *)paths 
         fromDeskTopView:(DesktopView *)view
            animateImage:(NSImage *)image 
         startingAtPoint:(NSPoint)startp;

- (NSArray *)selectedPaths;

- (NSMutableDictionary *)cachedRepresentationForPath:(NSString *)path;

- (void)addCachedRepresentation:(NSDictionary *)contentsDict
                    ofDirectory:(NSString *)path;

- (void)removeCachedRepresentationForPath:(NSString *)path;
                                            
- (void)removeOlderCache;

- (void)clearCache;

- (void)closeInspectors;

- (void)newObjectAtPath:(NSString *)basePath isDirectory:(BOOL)directory;

- (void)duplicateFiles;

- (void)deleteFiles;

- (BOOL)verifyFileAtPath:(NSString *)path;

- (void)removeWatcher:(Watcher *)awatcher;

- (Watcher *)watcherForPath:(NSString *)path;

- (NSTimer *)timerForPath:(NSString *)path;

- (void)watcherTimeOut:(id)sender;

- (void)setUsesThumbnails:(BOOL)value;

- (void)prepareThumbnailsCache;

- (void)thumbnailsDidChange:(NSNotification *)notif;

- (NSImage *)thumbnailForPath:(NSString *)path;

- (id)connectApplication:(NSString *)appName;

- (id)validRequestorForSendType:(NSString *)sendType
                     returnType:(NSString *)returnType;
										 
//
// Menu Operations
//
- (void)closeMainWin:(id)sender;

- (void)showInfo:(id)sender;

- (void)showPreferences:(id)sender;

- (void)showViewer:(id)sender;

- (void)showHistory:(id)sender;

- (void)showInspector:(id)sender;

- (void)showAttributesInspector:(id)sender;

- (void)showContentsInspector:(id)sender;

- (void)showToolsInspector:(id)sender;

- (void)showPermissionsInspector:(id)sender;

- (void)showApps:(id)sender;

- (void)showFileOps:(id)sender;

- (void)showFinder:(id)sender;

- (void)showFiend:(id)sender;

- (void)hideFiend:(id)sender;

- (void)addFiendLayer:(id)sender;

- (void)removeFiendLayer:(id)sender;

- (void)renameFiendLayer:(id)sender;

- (void)showTShelf:(id)sender;

- (void)hideTShelf:(id)sender;

- (void)addTShelfTab:(id)sender;

- (void)removeTShelfTab:(id)sender;

- (void)renameTShelfTab:(id)sender;

- (void)openWith:(id)sender;

- (void)runCommand:(id)sender;

- (void)startXTerm:(id)sender;

- (void)emptyRecycler:(id)sender;

- (void)putAway:(id)sender;

@end

@interface GWorkspace (FileOperations)

- (int)fileOperationRef;

- (FileOperation *)fileOpWithRef:(int)ref;

- (void)endOfFileOperation:(FileOperation *)op;

@end

#endif // GWORKSPACE_H
