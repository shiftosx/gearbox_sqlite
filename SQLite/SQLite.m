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

#import "SQLite.h"
#import <sqlite3.h>


@implementation SQLite

+ (NSString *) gbTitle{
	return @"SQLite";
}

+ (NSImage *) gbIcon{
	return [NSImage imageNamed:@""];
}

- (NSView *) gbEditor{
	return editor;
}

- (void) gbLoadFavoriteIntoEditor:(NSDictionary *)favorite
{
	NSString *nameString = ([favorite objectForKey:@"name"]) ? [favorite objectForKey:@"name"] : @""; 
	NSString *fileString = ([favorite objectForKey:@"file"]) ? [favorite objectForKey:@"file"] : @""; 

	[name setObjectValue:nameString];
	[file setObjectValue:fileString];
}

- (NSDictionary *) gbEditorAsDictionary
{
	NSMutableDictionary *favorite = [[NSMutableDictionary alloc] init];
	
	// Validate requirements
	// Would be nice to add in a check for valid connection and pop up a notice if it fails, a'la apple mail
	[nameWarning setHidden:![[name stringValue] isEqualToString:@""]];
//	[fileWarning setHidden:![[file stringValue] isEqualToString:@""]];
	
	if ([[name stringValue] isEqualToString:@""]/* || [[file stringValue] isEqualToString:@""]*/){
		return nil;
	}
	
	[favorite setObject:[name stringValue] forKey:@"name"];
//	[favorite setObject:[file stringValue] forKey:@"file"];	
	
	return favorite;
}

- (NSView *) gbAdvanced
{
	return [[NSView alloc] init];
}

- (IBAction) selectFile:(id)sender
{
	int result;
//    NSOpenPanel *filePanel = [NSOpenPanel openPanel];
	NSSavePanel *filePanel = [NSSavePanel savePanel];

	
//	NSMutableArray*      topLevelObjs = [NSMutableArray array];
//	NSDictionary*        nameTable = [NSDictionary dictionaryWithObjectsAndKeys:
//									  self, NSNibOwner,
//									  topLevelObjs, NSNibTopLevelObjects,
//									  nil];
//	[[NSBundle bundleForClass:[self class]] loadNibFile:@"Editor" externalNameTable:nameTable withZone:nil];
//	[topLevelObjs makeObjectsPerformSelector:@selector(release)];
//	
//	
//	[savePanel setAccessoryView:saveAccessory];
	[filePanel setPrompt:@"Choose"];
	[filePanel setTitle:@"Choose Database"];
	[filePanel setNameFieldLabel:@"Database"];
	[filePanel setDelegate:self];
	
	[filePanel setAllowedFileTypes:[NSArray arrayWithObjects:@"mp3",@"zip",nil]];
//	[filePanel setAllowsOtherFileTypes:YES];
//	[savePanel setRequiredFileType:nil];
//	[savePanel setExtensionHidden:NO];
    result = [filePanel runModal];
    if (result == NSOKButton) {
		[file setStringValue:[[filePanel filename] lastPathComponent]];
    }
}

- (NSString *)panel:(id)sender userEnteredFilename:(NSString *)filename confirmed:(BOOL)okFlag
{
	NSString *path = [[sender directory] stringByAppendingPathComponent:filename];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
		return [filename stringByAppendingPathExtension:@"shiftTemporaryOverride"];
	else
		return filename;
}

- (BOOL)panel:(id)sender isValidFilename:(NSString *)filename
{
//	if ([[NSFileManager defaultManager] fileExistsAtPath:filename])
	NSLog(@"valid? %@",filename);
	return YES;
}

@end
