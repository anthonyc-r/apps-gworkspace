 /*  -*-objc-*-
 *  Fiend.m: Implementation of the Fiend Class 
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

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <AppKit/AppKit.h>
  #ifdef GNUSTEP 
#include "GWFunctions.h"
  #else
#include <GWorkspace/GWFunctions.h>
  #endif
#include "Fiend.h"
#include "FiendLeaf.h"
#include "Dialogs/Dialogs.h"
#include "GWorkspace.h"
#include "GNUstep.h"

@implementation Fiend

- (void)dealloc
{
  RELEASE (layers);
  RELEASE (namelabel);
  RELEASE (ffButt);
  RELEASE (rewButt);
  RELEASE (leftArr);
  RELEASE (rightArr);
  RELEASE (currentName);
  TEST_RELEASE (freePositions);
  RELEASE (tile);  
  RELEASE (myWin);
	[super dealloc];
}

- (id)init
{
	self = [super initWithFrame: NSMakeRect(0, 0, 64, 64)];
  if (self) {
	  NSUserDefaults *defaults;
	  NSDictionary *myPrefs;
    id leaf;
    NSRect r;
    int i, j;
	
	  gw = [GWorkspace gworkspace];

	  myWin = [[NSWindow alloc] initWithContentRect: NSZeroRect
					               styleMask: NSBorderlessWindowMask  
                              backing: NSBackingStoreRetained defer: NO];

    if ([myWin setFrameUsingName: @"Fiend"] == NO) {
      [myWin setFrame: NSMakeRect(100, 100, 64, 64) display: NO];
    }      
    [myWin setReleasedWhenClosed: NO]; 
    r = [myWin frame];      
       
    defaults = [NSUserDefaults standardUserDefaults];	

    layers = [[NSMutableDictionary alloc] initWithCapacity: 1];
    
    myPrefs = [defaults dictionaryForKey: @"fiendlayers"];
    if (myPrefs != nil) {
      NSArray *names = [myPrefs allKeys];

      for (i = 0; i < [names count]; i++) {
        NSString *layername = [names objectAtIndex: i];       
        NSDictionary *pathsAndRects = [myPrefs objectForKey: layername];
        NSArray *paths = [pathsAndRects allKeys];
        NSMutableArray *leaves = [NSMutableArray arrayWithCapacity: 1];
        
        for (j = 0; j < [paths count]; j++) {
          NSString *path = [paths objectAtIndex: j];
          
          if ([[NSFileManager defaultManager] fileExistsAtPath: path] == YES) { 
            NSDictionary *dict = [pathsAndRects objectForKey: path];
            int posx = [[dict objectForKey: @"posx"] intValue];
            int posy = [[dict objectForKey: @"posy"] intValue];            

            leaf = [[FiendLeaf alloc] initWithPosX: posx posY: posy
                                relativeToPoint: r.origin forPath: path 
                                             inFiend: self  ghostImage: nil];
            [leaves addObject: leaf];
            RELEASE (leaf);
          }                 
        }        
        [layers setObject: leaves forKey: layername];        
      }    
      currentName = [defaults stringForKey: @"fiendcurrentlayer"];
      if (currentName == nil) {
        ASSIGN (currentName, [names objectAtIndex: 0]);
      } else {
        RETAIN (currentName);
      }
      
    } else {
      NSMutableArray *leaves = [NSMutableArray arrayWithCapacity: 1];
      ASSIGN (currentName, @"Workspace");
      [layers setObject: leaves forKey: currentName];      
    }

    namelabel = [NSTextFieldCell new];
		[namelabel setFont: [NSFont boldSystemFontOfSize: 10]];
		[namelabel setBordered: NO];
		[namelabel setAlignment: NSLeftTextAlignment];
    [namelabel setStringValue: cutFileLabelText(currentName, namelabel, 52)];
	  [namelabel setDrawsBackground: NO];
	
    ASSIGN (leftArr, [NSImage imageNamed: @"FFArrow.tiff"]);
    
  	ffButt = [[NSButton alloc] initWithFrame: NSMakeRect(49, 6, 9, 9)];
		[ffButt setButtonType: NSMomentaryLight];    
    [ffButt setBordered: NO];    
    [ffButt setTransparent: YES];    
    [ffButt setTarget: self];
    [ffButt setAction: @selector(switchLayer:)];
		[self addSubview: ffButt]; 
    
    ASSIGN (rightArr, [NSImage imageNamed: @"REWArrow.tiff"]);

  	rewButt = [[NSButton alloc] initWithFrame: NSMakeRect(37, 6, 9, 9)];
		[rewButt setButtonType: NSMomentaryLight];    
    [rewButt setBordered: NO];  
    [rewButt setTransparent: YES];    
    [rewButt setTarget: self];
    [rewButt setAction: @selector(switchLayer:)];
		[self addSubview: rewButt]; 
  
    ASSIGN (tile, [NSImage imageNamed: @"common_Tile.tiff"]);
    
    [self registerForDraggedTypes: [NSArray arrayWithObjects: NSFilenamesPboardType, nil]];  
    [self findFreePositions];
    leaveshidden = NO;
    isDragTarget = NO;
		
		[myWin setContentView: self];		
  }
  
  return self;
}

- (void)activate
{
	[self orderFrontLeaves];
}

- (NSWindow *)myWin
{
  return myWin;
}

- (id)fiendLeafOfType:(NSString *)type withName:(NSString *)name
{
  NSArray *leaves = [layers objectForKey: currentName];
  int i;
        
	if (leaveshidden == YES) {
		return nil;
	}
	
  for (i = 0; i < [leaves count]; i++) {
    id leaf = [leaves objectAtIndex: i];
		NSString *ltype = [leaf myType];
		NSString *lname = [[leaf myPath] lastPathComponent];
		
		if (([ltype isEqual: type]) && ([lname isEqual: name])) {
			return leaf;
		}
	}
	
	return nil;
}

- (NSPoint)positionOfLeaf:(id)aleaf
{
	return [aleaf iconPosition];
}

- (BOOL)dissolveLeaf:(id)aleaf
{
	return [aleaf dissolveAndReturnWhenDone];
}

- (void)addLayer
{
  FileOpsDialog *dialog;
  NSString *layerName;
  NSMutableArray *leaves;
  int result;
  
  if ([myWin isVisible] == NO) {
    return;
  }

	dialog = [[FileOpsDialog alloc] initWithTitle: NSLocalizedString(@"New Layer", @"") editText: @""];
  AUTORELEASE (dialog);
	[dialog center];
  [dialog makeKeyWindow];
  [dialog orderFrontRegardless];
  
  result = [dialog runModal];
	if(result != NSAlertDefaultReturn) {
    return;
  }  
  
  layerName = [dialog getEditFieldText];
  
  if ([[layers allKeys] containsObject: layerName]) {
		NSString *msg = NSLocalizedString(@"A layer with this name is already present!", @"");
		NSString *buttstr = NSLocalizedString(@"Continue", @"");		
    NSRunAlertPanel(nil, msg, buttstr, nil, nil);  
    return;
	}
		
  leaves = [NSMutableArray arrayWithCapacity: 1];
  [layers setObject: leaves forKey: layerName];
  [self goToLayerNamed: layerName];
}

- (void)removeCurrentLayer
{
  NSArray *names, *leaves;
  NSString *newname;
	NSString *title, *msg, *buttstr;
  int i, index, result;

  if ([myWin isVisible] == NO) {
    return;
  }
  
  if ([layers count] == 1) {
		msg = NSLocalizedString(@"You can't remove the last layer!", @"");
		buttstr = NSLocalizedString(@"Continue", @"");		
    NSRunAlertPanel(nil, msg, buttstr, nil, nil);  
    return;
  }

	title = NSLocalizedString(@"Remove layer", @"");
	msg = NSLocalizedString(@"Are you sure that you want to remove this layer?", @"");
	buttstr = NSLocalizedString(@"Continue", @"");
  result = NSRunAlertPanel(title, msg, NSLocalizedString(@"OK", @""), buttstr, NULL);
  if(result != NSAlertDefaultReturn) {
    return;
  }
  
  names = [layers allKeys];  	
	index = [names indexOfObject: currentName];
	
  if (index == 0) {
    index = [names count];
  }
  index--;
  
  newname = [names objectAtIndex: index];

  leaves = [layers objectForKey: currentName];  
  for (i = 0; i < [leaves count]; i++) {
    id leaf = [leaves objectAtIndex: i];    
    [[leaf window] close];
  }

  [layers removeObjectForKey: currentName];     
  ASSIGN (currentName, newname);  
  
  [self switchLayer: ffButt];
}

- (void)renameCurrentLayer
{
  FileOpsDialog *dialog;
  NSString *layerName;
  NSMutableArray *leaves;
  int result;
  
  if ([myWin isVisible] == NO) {
    return;
  }

	dialog = [[FileOpsDialog alloc] initWithTitle: NSLocalizedString(@"Rename Layer", @"") editText: currentName];
  AUTORELEASE (dialog);
	[dialog center];
  [dialog makeKeyWindow];
  [dialog orderFrontRegardless];
  
  result = [dialog runModal];
	if(result != NSAlertDefaultReturn) {
    return;
  }  
  
  layerName = [dialog getEditFieldText];
  if ([layerName isEqualToString: currentName]) {  
    return;
  }
  
  if ([[layers allKeys] containsObject: layerName]) {
		NSString *msg = NSLocalizedString(@"A layer with this name is already present!", @"");
		NSString *buttstr = NSLocalizedString(@"Continue", @"");		
    NSRunAlertPanel(nil, msg, buttstr, nil, nil);  
    return;
	}
  
  leaves = [layers objectForKey: currentName];
  RETAIN (leaves);
  [layers removeObjectForKey: currentName];  
  ASSIGN (currentName, layerName);
  [layers setObject: leaves forKey: currentName];
  RELEASE (leaves);
  
  [namelabel setStringValue: cutFileLabelText(currentName, namelabel, 52)];
  [self setNeedsDisplay: YES];  
}

- (void)goToLayerNamed:(NSString *)lname
{
  NSArray *leaves;
  int i;

  if ([myWin isVisible] == NO) {
    return;
  }
  
  leaves = [layers objectForKey: currentName];  
  for (i = 0; i < [leaves count]; i++) {
    [[[leaves objectAtIndex: i] window] orderOut: self];
  }

  ASSIGN (currentName, lname);
	[self orderFrontLeaves];
  [self findFreePositions];
  
  [namelabel setStringValue: cutFileLabelText(currentName, namelabel, 52)];
  [self setNeedsDisplay: YES];
}

- (void)switchLayer:(id)sender
{
  NSArray *names, *leaves;
  NSString *newname;
  int i, index;

  if ([myWin isVisible] == NO) {
    return;
  }
  
  names = [layers allKeys];  
	index = [names indexOfObject: currentName];
	
  if (sender == ffButt) {
    if (index == [names count] -1) {
      index = -1;
    }
    index++;
  } else {
    if (index == 0) {
      index = [names count];
    }
    index--;
  }

  newname = [names objectAtIndex: index];
      
  leaves = [layers objectForKey: currentName];  
  for (i = 0; i < [leaves count]; i++) {
    [[[leaves objectAtIndex: i] window] orderOut: self];
  }

  ASSIGN (currentName, newname);
	[self orderFrontLeaves];
  [self findFreePositions];
  
  [namelabel setStringValue: cutFileLabelText(currentName, namelabel, 52)];
  [self setNeedsDisplay: YES];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (void)mouseDown:(NSEvent*)theEvent
{
	NSEvent *nextEvent;
  NSPoint location, lastLocation, origin, leaforigin;
  float initx, inity;
  id leaf;
  NSWindow *leafWin;
  NSArray *names, *leaves;
  int i, j;
  BOOL hidden = NO, dragged = NO;
  
  [self orderFrontLeaves];

  leaves = [layers objectForKey: currentName];
    
	if ([theEvent clickCount] > 1) {    
    if (leaveshidden == NO) {    
      leaveshidden = YES;
      for (i = 0; i < [leaves count]; i++) {
        leafWin = [[leaves objectAtIndex: i] window];
        [leafWin orderOut: nil];
      }  
    } else {
      leaveshidden = NO;
      [self orderFrontLeaves];
    }    
    return;
	}  

  names = [layers allKeys];
  
  initx = [myWin frame].origin.x;
  inity = [myWin frame].origin.y;
  
  lastLocation = [theEvent locationInWindow];

  while (1) {
	  nextEvent = [myWin nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];

    if ([nextEvent type] == NSLeftMouseUp) {    
      if (dragged == YES) {
        float nowx = [myWin frame].origin.x;
        float nowy = [myWin frame].origin.y;
        
        for (i = 0; i < [names count]; i++) {
          leaves = [layers objectForKey: [names objectAtIndex: i]];  

          for (j = 0; j < [leaves count]; j++) {
            leaf = [leaves objectAtIndex: j];
            leafWin = [leaf window];
            leaforigin = [leafWin frame].origin;            
 		        leaforigin.x -= (initx - nowx);
		        leaforigin.y -= (inity - nowy);                        
            [leafWin setFrameOrigin: leaforigin];        
          }
        }
      }
    
      [self findFreePositions];            
      [self orderFrontLeaves];
      [self updateDefaults];
      break;

    } else if ([nextEvent type] == NSLeftMouseDragged) {
      dragged = YES;
      
      if (hidden == NO) {
        for (i = 0; i < [names count]; i++) {
          leaves = [layers objectForKey: [names objectAtIndex: i]];          
          for (j = 0; j < [leaves count]; j++) {
            leaf = [leaves objectAtIndex: j];        
            [[leaf window] orderOut: self];                                   
          }
        }
        hidden = YES;
      }
      
 		  location = [myWin mouseLocationOutsideOfEventStream];
      origin = [myWin frame].origin;
		  origin.x += (location.x - lastLocation.x);
		  origin.y += (location.y - lastLocation.y);
      [myWin setFrameOrigin: origin];
      
    }
  }
}                                                        

- (void)draggedFiendLeaf:(FiendLeaf *)leaf
                 atPoint:(NSPoint)location 
                 mouseUp:(BOOL)mouseup
{
  LeafPosition *leafpos;
  static NSMutableArray *leaves;
  static FiendLeaf *hlightleaf;
  BOOL hlight, newpos;
  int i;
  NSRect r;
  static BOOL started = NO;
    
  if (started == NO) {  
    leaves = [layers objectForKey: currentName];  
    hlightleaf = nil;
    leafpos = [[LeafPosition alloc] initWithPosX: [leaf posx] posY: [leaf posy] 
                                 relativeToPoint: [[self window] frame].origin];
    [freePositions addObject: leafpos];
    RELEASE (leafpos);
    started = YES;
  }
  
  r = [myWin frame];
  
  if (mouseup == NO) {  
    hlight = NO;
    for (i = 0; i < [freePositions count]; i++) {
      LeafPosition *lfpos = [freePositions objectAtIndex: i];
      
      if ([lfpos containsPoint: location]) {
        if (hlightleaf == nil) {        
          hlightleaf = [[FiendLeaf alloc] initWithPosX: [lfpos posx] 
                  posY: [lfpos posy] relativeToPoint: r.origin forPath: nil 
                                       inFiend: self ghostImage: [leaf icon]];
          [[hlightleaf window] display];                           
          [[hlightleaf window] orderBack: self];                                 
        } else {        
          [hlightleaf setPosX: [lfpos posx] posY: [lfpos posy] relativeToPoint: r.origin];        
          [[hlightleaf window] orderBack: self];                                 
        }
                             
        hlight = YES;
        break;
      }
    }
      
    if ((hlight == NO) && (hlightleaf != nil)) { 
      [[hlightleaf window] orderOut: self]; 
      RELEASE (hlightleaf);
      hlightleaf = nil;
    }
    
  } else {
    if (hlightleaf != nil) { 
      [[hlightleaf window] orderOut: nil]; 
      RELEASE (hlightleaf);
      hlightleaf = nil;
    }
      
    newpos = NO;
    for (i = 0; i < [freePositions count]; i++) {
      leafpos = [freePositions objectAtIndex: i];
      
      if ([leafpos containsPoint: location]) {
        [leaf setPosX: [leafpos posx] posY: [leafpos posy] relativeToPoint: r.origin];        
        newpos = YES;
        break;
      }
    }
      
    if (newpos == NO) {    
      [[leaf window] close];
      [leaves removeObject: leaf];
    }
      
    [self orderFrontLeaves];
    [self findFreePositions];
    started = NO;
  }
}

- (void)findFreePositions
{
  NSArray *leaves;
  id leaf;
  NSArray *positions;
  int posx, posy;
  int i, j, m, count;
      
  TEST_RELEASE (freePositions);
  freePositions = [[NSMutableArray alloc] initWithCapacity: 1];

  positions = [self positionsAroundLeafAtPosX: 0 posY: 0];
  [freePositions addObjectsFromArray: positions];

  leaves = [layers objectForKey: currentName];
  
  for (i = 0; i < [leaves count]; i++) {
    leaf = [leaves objectAtIndex: i];
    posx = [leaf posx];
    posy = [leaf posy];   
    positions = [self positionsAroundLeafAtPosX: posx posY: posy];
    [freePositions addObjectsFromArray: positions];
  }

  count = [freePositions count];
  for (i = 0; i < count; i++) {
    BOOL inuse = NO;
    LeafPosition *lpos = [freePositions objectAtIndex: i];
    posx = [lpos posx];
    posy = [lpos posy];

    inuse = (posx == 0 && posy == 0);

    if (inuse == NO) {    
      for (j = 0; j < [leaves count]; j++) {
        leaf = [leaves objectAtIndex: j];
        inuse = (posx == [leaf posx] && posy == [leaf posy]);
        if (inuse == YES) {
          break;
        }
      }
    }
    
    if (inuse == NO) {    
      for (m = 0; m < count; m++) {
        LeafPosition *lpos2 = [freePositions objectAtIndex: m]; 
        if (m != i) {    
          inuse = (posx == [lpos2 posx] && posy == [lpos2 posy]);
          if (inuse == YES) {
            break;
          }    
        }
      }
    }
    
    if (inuse == YES) { 
      [freePositions removeObjectAtIndex: i];
      i--;
      count--;
    }
  }
  
}

- (NSArray *)positionsAroundLeafAtPosX:(int)posx posY:(int)posy
{
  NSMutableArray *leafpositions;
  LeafPosition *leafpos;  
  NSPoint or;
  int x, y;

  or = [myWin frame].origin;
  
  leafpositions = [NSMutableArray arrayWithCapacity: 1];
    
  for (x = posx - 1; x <= posx + 1; x++) {
    for (y = posy + 1; y >= posy - 1; y--) {      
      if ((x == posx && y == posy) == NO) {
        leafpos = [[LeafPosition alloc] initWithPosX: x posY: y relativeToPoint: or];
        [leafpositions addObject: leafpos];
        RELEASE (leafpos);
      }
    }
  }

  return leafpositions;
}

- (void)orderFrontLeaves
{
  NSArray *leaves;
  int i;

  leaves = [layers objectForKey: currentName];  
	[myWin orderFront: nil]; 
	[myWin setLevel: NSNormalWindowLevel];
	
	[self setNeedsDisplay: YES];
  if (leaveshidden == NO) {
    for (i = 0; i < [leaves count]; i++) {
			NSWindow *win = [[leaves objectAtIndex: i] window];
    	[win orderFront: nil];
			[win setLevel: NSNormalWindowLevel];
    }
  }   
}

- (void)hide
{
  NSArray *leaves;
  int i;

  leaves = [layers objectForKey: currentName];  
  for (i = 0; i < [leaves count]; i++) {
    [[[leaves objectAtIndex: i] window] orderOut: self];
  }
  
  [myWin orderOut: self]; 
}

- (void)verifyDraggingExited:(id)sender
{
  NSArray *leaves;
  int i;

  leaves = [layers objectForKey: currentName];  
  
  for (i = 0; i < [leaves count]; i++) {
    FiendLeaf *leaf = [leaves objectAtIndex: i];
    
    if ((leaf != (FiendLeaf *)sender) && ([leaf isDragTarget] == YES)) {
      [leaf draggingExited: nil];
    }
  }
}

- (void)updateDefaults
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];		
  NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithCapacity: 1];
  NSArray *names = [layers allKeys];
  int i, j;
    
  for (i = 0; i < [names count]; i++) {
    NSString *name = [names objectAtIndex: i];   
    NSArray *leaves = [layers objectForKey: name];      
    NSMutableDictionary *pathsAndRects = [NSMutableDictionary dictionaryWithCapacity: 1];    
    
    for (j = 0; j < [leaves count]; j++) {
      NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity: 1];    
      id leaf = [leaves objectAtIndex: j];
      [dict setObject: [NSString stringWithFormat: @"%i", [leaf posx]] forKey: @"posx"];      
      [dict setObject: [NSString stringWithFormat: @"%i", [leaf posy]] forKey: @"posy"];      
      [pathsAndRects setObject: dict forKey: [leaf myPath]];
    }
    
    [prefs setObject: pathsAndRects forKey: name];    
  }

 	[defaults setObject: prefs forKey: @"fiendlayers"];  
  [defaults setObject: currentName forKey: @"fiendcurrentlayer"];  
	[defaults synchronize];
  
  [myWin saveFrameUsingName: @"Fiend"];
}

- (void)drawRect:(NSRect)rect
{
  [self lockFocus];
	[tile compositeToPoint: NSZeroPoint operation: NSCompositeSourceOver]; 
  [leftArr compositeToPoint: NSMakePoint(49, 6) 
                  operation: NSCompositeSourceOver]; 
  [rightArr compositeToPoint: NSMakePoint(37, 6) 
                   operation: NSCompositeSourceOver]; 
	[namelabel drawWithFrame: NSMakeRect(4, 50, 56, 10) inView: self];   
  [self unlockFocus];  
}

@end

@implementation Fiend (DraggingDestination)

- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pb = [sender draggingPasteboard];
	
  if([[pb types] indexOfObject: NSFilenamesPboardType] != NSNotFound) {
  	NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];
		
		if ((sourceDragMask == NSDragOperationCopy) 
											|| (sourceDragMask == NSDragOperationLink)) {
			return NSDragOperationNone;
		}
	
    isDragTarget = YES;
  	return NSDragOperationAll;
  }
     
  return NSDragOperationNone;
}

- (unsigned int)draggingUpdated:(id <NSDraggingInfo>)sender
{
  NSDragOperation sourceDragMask;
	
	if (isDragTarget == NO) {
		return NSDragOperationNone;
	}

	sourceDragMask = [sender draggingSourceOperationMask];

	if ((sourceDragMask == NSDragOperationCopy) 
												|| (sourceDragMask == NSDragOperationLink)) {
		return NSDragOperationNone;
	}

	return NSDragOperationAll;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	isDragTarget = NO;  
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	return isDragTarget;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
  NSPasteboard *pb;
	NSArray *sourcePaths;
  NSString *path;
  NSMutableArray *leaves;
  id leaf;
  NSRect r;
  int px, py, posx, posy;
  int i;

  pb = [sender draggingPasteboard];
  sourcePaths = [pb propertyListForType: NSFilenamesPboardType];
  
  if ([sourcePaths count] > 1) {
		NSString *msg = NSLocalizedString(@"You can't dock multiple paths!", @"");
		NSString *buttstr = NSLocalizedString(@"Continue", @"");		
    NSRunAlertPanel(nil, msg, buttstr, nil, nil);
    isDragTarget = NO;
    return;
  }

  leaves = [layers objectForKey: currentName];  

  path = [sourcePaths objectAtIndex: 0];
  
  for (i = 0; i < [leaves count]; i++) {
    leaf = [leaves objectAtIndex: i];    
    if ([[leaf myPath] isEqualToString: path] == YES) {
			NSString *msg = NSLocalizedString(@"This object is already present in this layer!", @"");
			NSString *buttstr = NSLocalizedString(@"Continue", @"");		
      NSRunAlertPanel(nil, msg, buttstr, nil, nil);
      isDragTarget = NO;
      return;
    }
  }
      
  r = [myWin frame];

  posx = 0;
  posy = 0;
  for (i = 0; i < [leaves count]; i++) {
    leaf = [leaves objectAtIndex: i];
    px = [leaf posx];
    py = [leaf posy];
    if ((px == posx) && (py < posy)) {
      posy = py;
    }
  }
  posy--;
                  
  leaf = [[FiendLeaf alloc] initWithPosX: posx posY: posy
                            relativeToPoint: r.origin forPath: path 
                                          inFiend: self  ghostImage: nil];                          
  [leaves addObject: leaf];
  RELEASE (leaf);
  
  leaf = [leaves objectAtIndex: [leaves count] -1];
  [[leaf window] display]; 
  [self findFreePositions];  
  [self orderFrontLeaves];
  
  isDragTarget = NO;
  
  [self updateDefaults];
}

@end
