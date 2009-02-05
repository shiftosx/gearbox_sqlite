/* 
 * Shift is the legal property of its developers, whose names are listed in the copyright file included
 * with this source distribution.
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation; either version 3 of the License,
 * or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
 * Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA 
 * or see <http://www.gnu.org/licenses/>.
 */

#import "MySQL.h"


@implementation MySQL

+ (NSString *) gbTitle{
	return @"MySQL";
}

+ (NSImage *) gbIcon{
	NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"MySQL" ofType:@"icns"];
	return [[NSImage alloc] initByReferencingFile:imagePath];
}

- (NSView *) gbEditor{
	return editor;
}

- (void) gbLoadFavoriteIntoEditor:(NSDictionary *)favorite
{
	NSString *nameString = ([favorite objectForKey:@"name"]) ? [favorite objectForKey:@"name"] : @"";
	NSString *hostString = ([favorite objectForKey:@"host"]) ? [favorite objectForKey:@"host"] : @"";
	NSString *userString = ([favorite objectForKey:@"user"]) ? [favorite objectForKey:@"user"] : @"";
	NSString *passwordString = ([favorite objectForKey:@"password"]) ? [favorite objectForKey:@"password"] : @"";
	NSString *databaseString = ([favorite objectForKey:@"database"]) ? [favorite objectForKey:@"database"] : @"";
	NSString *socketString = ([favorite objectForKey:@"socket"]) ? [favorite objectForKey:@"socket"] : @"";
	
	[name setStringValue:nameString];
	[host setStringValue:hostString];
	[user setStringValue:userString];
	[password setStringValue:passwordString];
	[database setStringValue:databaseString];
	[socket setStringValue:socketString];
	if ([[favorite objectForKey:@"port"] intValue] > 0)
		[port setIntValue:[[favorite objectForKey:@"port"] intValue]];
}

- (NSDictionary *) gbEditorAsDictionary
{
	NSMutableDictionary *favorite = [[NSMutableDictionary alloc] init];

	// Validate requirements
	// Would be nice to add in a check for valid connection and pop up a notice if it fails, a'la apple mail
	[nameWarning setHidden:![[name stringValue] isEqualToString:@""]];
	[hostWarning setHidden:![[host stringValue] isEqualToString:@""]];
	[userWarning setHidden:![[user stringValue] isEqualToString:@""]];
	
	if ([[name stringValue] isEqualToString:@""] || [[host stringValue] isEqualToString:@""] || [[user stringValue] isEqualToString:@""]){
		return nil;
	}
		
	[favorite setObject:[name stringValue] forKey:@"name"];
	[favorite setObject:[host stringValue] forKey:@"host"];
	[favorite setObject:[user stringValue] forKey:@"user"];
	[favorite setObject:[password stringValue] forKey:@"password"];
	[favorite setObject:[database stringValue] forKey:@"database"];
	[favorite setObject:[socket stringValue] forKey:@"socket"];
	if ([port intValue] > 0)
		[favorite setObject:[NSNumber numberWithInt:[port intValue]] forKey:@"port"];
	
	
	return favorite;
}

- (NSView *) gbAdvanced
{
	return [[NSView alloc] init];
}
@end
