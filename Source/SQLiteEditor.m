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

#import "SQLiteEditor.h"

#import "SQLiteConnection.h"

@implementation SQLiteEditor

- (SQLiteConnection *)connection
{
	if (connection == nil)
		connection = [[SQLiteConnection alloc] init];

	// Validate requirements
	// Would be nice to add in a check for valid connection and pop up a notice if it fails, a'la apple mail
	[fileWarning setHidden:![[file stringValue] isEqualToString:@""]];
	
	if ([[file stringValue] isEqualToString:@""]){
		return nil;
	}
	connection.name = [name stringValue];
	connection.file = filePath;
	
	return connection;
}

- (void) setConnection:(SQLiteConnection *)aConnection
{
	connection = aConnection;
	
	filePath = (connection.file) ? connection.file : @"";
	[filePath retain];
	
	[name setObjectValue:(connection.name) ? connection.name : @""];
	[file setObjectValue:(connection.file) ? [connection.file lastPathComponent] : @""];
}

- (IBAction) selectFile:(id)sender
{
	int result;
    NSOpenPanel *filePanel = [NSOpenPanel openPanel];
	//	NSSavePanel *filePanel = [NSSavePanel savePanel];
	
	
	//	NSMutableArray*      topLevelObjs = [NSMutableArray array];
	//	NSDictionary*        nameTable = [NSDictionary dictionaryWithObjectsAndKeys:
	//									  self, NSNibOwner,
	//									  topLevelObjs, NSNibTopLevelObjects,
	//									  nil];
	//	[[NSBundle bundleForClass:[self class]] loadNibFile:@"Editor" externalNameTable:nameTable withZone:nil];
	//	[topLevelObjs makeObjectsPerformSelector:@selector(release)];

	[filePanel setPrompt:@"Choose"];
	[filePanel setTitle:@"Choose Database"];
	[filePanel setNameFieldLabel:@"Database"];
	[filePanel setDelegate:self];
	
	[filePanel setAllowedFileTypes:[NSArray arrayWithObjects:@"sqlite",@"sqlite3",@"db",nil]];
	//	[filePanel setAllowsOtherFileTypes:YES];
	[filePanel setExtensionHidden:NO];
	[filePanel setResolvesAliases:NO];
    result = [filePanel runModal];
    if (result == NSOKButton) {
		filePath = [[[filePanel URL] path] retain];
		[file setStringValue:[filePath lastPathComponent]];
    }
}

- (void) dealloc
{
	if (filePath)
		[filePath release];
	[super dealloc];
}

@end
