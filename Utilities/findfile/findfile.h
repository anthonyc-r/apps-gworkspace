 /*
 *  FindFile.h: Interface and declarations for the FindFile Class 
 *  of the FindFile tool for the GNUstep GWorkspace application
 *
 *  Copyright (c) 2003 Enrico Sersale <enrico@imago.ro>
 *  
 *  Author: Enrico Sersale
 *  Date: January 2003
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

#ifndef FINDFILE_H
#define FINDFILE_H

#include <Foundation/Foundation.h>

@protocol FindFileProtocol

- (oneway void)findAtPath:(NSString *)apath 
             withCriteria:(NSString *)crit;

@end 

@protocol FinderProtocol

- (void)registerFindFile:(id)anObject;

- (BOOL)getFoundPath:(NSString *)fpath;

- (void)findDone;

@end 

@interface FindFile: NSObject <FindFileProtocol>
{
  NSString *findPath;
  NSDictionary *criteria;
	BOOL stopped;
  id <FinderProtocol> finder;
}

- (void)registerWithFinder;

- (void)doFind;

- (void)done;

- (void)connectionDidDie:(NSNotification *)notification;

@end

#endif // FINDFILE_H
