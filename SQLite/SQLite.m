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


@implementation SQLite

- (void) dealloc
{
	if (filePath)
		[filePath release];
	[super dealloc];
}


+ (NSString *) gbTitle{
	return @"SQLite";
}

+ (NSImage *) gbIcon{
	return [NSImage imageNamed:@""];
}

- (NSView *) gbEditor{
	return editor;
}

- (void) gbLoadFavoriteIntoEditor:(NSDictionary *)userFavorite
{
	filePath = ([userFavorite objectForKey:@"file"]) ? [userFavorite objectForKey:@"file"] : @"";
	[filePath retain];
	NSString *nameString = ([userFavorite objectForKey:@"name"]) ? [userFavorite objectForKey:@"name"] : @""; 
	NSString *fileString = [filePath lastPathComponent];

	[name setObjectValue:nameString];
	[file setObjectValue:fileString];
}

- (NSDictionary *) gbEditorAsDictionary
{
	NSMutableDictionary *userFavorite = [[NSMutableDictionary alloc] init];
	
	// Validate requirements
	// Would be nice to add in a check for valid connection and pop up a notice if it fails, a'la apple mail
	[fileWarning setHidden:![[file stringValue] isEqualToString:@""]];
	
	if ([[file stringValue] isEqualToString:@""]){
		return nil;
	}
	[userFavorite setObject:[name stringValue] forKey:@"name"];
	[userFavorite setObject:filePath forKey:@"file"];	
	
	return userFavorite;
}

- (NSView *) gbAdvanced
{
	return [[NSView alloc] init];
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
//	
//	
//	[savePanel setAccessoryView:saveAccessory];
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

- (NSArray *) gbFeatures
{
	return [NSArray arrayWithObjects:GBFeatureTable, GBFeatureView, GBFeatureTrigger, nil];
}

- (NSArray *)sqliteMasterType:(NSString *)field filter:(NSString *)filter
{
	NSArray *array;
	@try {
		if (filter != nil && [filter length] > 0)
			filter = [NSString stringWithFormat:@"AND `name` LIKE %%%@%%", filter];
		else
			filter = @"";

		NSString *query = [NSString stringWithFormat:@"SELECT `name` FROM SQLITE_MASTER WHERE `type`='%@' %@;", field, filter];
		array = [[self query:query] valueForKey:@"name"];
	}
	@catch (NSException * e) {
		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[e reason], @"reason",
							  [[e userInfo] objectForKey:@"query"], @"query", nil];
		[self postNotification:GBNotificationInvalidQuery withInfo:info];
	}
	
	return array;	
}

//database querying functions
- (void) selectSchema:(NSString *)schema
{
}

- (NSArray *) listSchemas:(NSString *)filter
{
	return [NSArray arrayWithObject:[[favorite objectForKey:@"file"] lastPathComponent]];
}

- (NSArray *) listTables:(NSString *)filter
{
	return [self sqliteMasterType:@"table" filter:filter];
}

- (NSArray *) listViews:(NSString *)filter
{
	return [self sqliteMasterType:@"view" filter:filter];
}

- (NSArray *) listStoredProcs:(NSString *)filter
{
	return nil;
}

- (NSArray *) listFunctions:(NSString *)filter
{
	return nil;
}

- (NSArray *) listTriggers:(NSString *)filter
{
	return [self sqliteMasterType:@"trigger" filter:filter];
}


- (NSArray *) query:(NSString *)query
{	
	if (!connected) {
		return [NSArray array];
	}
	
	NSMutableArray *results = [NSMutableArray array];
	sqlite3_stmt *statement;
	
	if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSMutableDictionary *row = [NSMutableDictionary dictionary];
			for (int i=0; i<sqlite3_column_count(statement); i++) {
				id value;
				switch (sqlite3_column_type(statement, i)) {
					case SQLITE_INTEGER:
						value = [NSNumber numberWithInt:sqlite3_column_int(statement, i)];
						break;
					case SQLITE_FLOAT:
						value = [NSNumber numberWithDouble:sqlite3_column_double(statement, i)];
						break;
					case SQLITE_TEXT:
						value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, i)];
						break;
					case SQLITE_BLOB:
					{
						const void *data = sqlite3_column_blob(statement, i);
						value = [NSData dataWithBytes:data length:sizeof data];//not sure if this is the correct way to get the length
						break;
					}
					case SQLITE_NULL:
					default:
						value = nil;
						break;
				}
				[row setObject:value forKey:[NSString stringWithUTF8String:sqlite3_column_name(statement, i)]];
			}
			[results addObject:row];
		}
	}else {
		//exception
		@throw [NSException exceptionWithName:GBNotificationInvalidQuery 
									   reason:[self lastErrorMessage] 
									 userInfo:[NSDictionary dictionaryWithObject:query forKey:@"query"]];
	}

	sqlite3_finalize(statement); //release statement
	return [NSArray arrayWithArray:results];
}

- (NSString *) lastErrorMessage
{
	int errCode = sqlite3_errcode(database);
	NSString *errCodeString;
	
	switch (errCode) {
		case SQLITE_ERROR:
			errCodeString = @"SQL Error";
			break;
		case SQLITE_INTERNAL:
			errCodeString = @"Internal logic error in SQLite";
			break;
		case SQLITE_PERM:
			errCodeString = @"Access permission denied ";
			break;
		case SQLITE_ABORT:
			errCodeString = @"SQLite Aborted";
			break;
		case SQLITE_BUSY:
			errCodeString = @"The database file is locked";
			break;
		case SQLITE_LOCKED:
			errCodeString = @"A table in the database is locked";
			break;
		case SQLITE_NOMEM:
			errCodeString = @"SQLite ran out of memory";
			break;
		case SQLITE_READONLY:
			errCodeString = @"Attempt to write a readonly database";
			break;
		case SQLITE_INTERRUPT:
			errCodeString = @"SQLite Operation Terminated";
			break;
		case SQLITE_IOERR:
			errCodeString = @"Some kind of disk I/O error occurred";
			break;
		case SQLITE_CORRUPT:
			errCodeString = @"The database disk image is malformed";
			break;
		case SQLITE_FULL:
			errCodeString = @"Insertion failed because database is full";
			break;
		case SQLITE_CANTOPEN:
			errCodeString = @"Unable to open the database file";
			break;
		case SQLITE_EMPTY:
			errCodeString = @"Database is empty";
			break;
		case SQLITE_SCHEMA:
			errCodeString = @"The database schema changed";
			break;
		case SQLITE_TOOBIG:
			errCodeString = @"String or BLOB exceeds size limit";
			break;
		case SQLITE_CONSTRAINT:
			errCodeString = @"Abort due to constraint violation";
			break;
		case SQLITE_MISMATCH:
			errCodeString = @"Data type mismatch";
			break;
		case SQLITE_MISUSE:
			errCodeString = @"Library used incorrectly";
			break;
		case SQLITE_NOLFS:
			errCodeString = @"Uses OS features not supported on host";
			break;
		case SQLITE_AUTH:
			errCodeString = @"Authorization denied";
			break;
		case SQLITE_FORMAT:
			errCodeString = @"Auxiliary database format error";
			break;
		case SQLITE_RANGE:
			errCodeString = @"2nd parameter to sqlite3_bind out of range";
			break;
		case SQLITE_NOTADB:
			errCodeString = @"File opened that is not a database file";
			break;
		case SQLITE_ROW:
			errCodeString = @"sqlite3_step() has another row ready";
			break;
		case SQLITE_DONE:
			errCodeString = @"sqlite3_step() has finished executing";
		break;
	}
	return [NSString stringWithFormat:@"%@: %s",  errCodeString, sqlite3_errmsg(database)];
}

//connection functions
- (BOOL) isConnected
{
	return connected;
}

- (BOOL) connect:(NSDictionary *)userFavorite
{
	favorite = userFavorite;
	connected = (sqlite3_open([[favorite objectForKey:@"file"] UTF8String], &database) == SQLITE_OK);
	if (connected)
		[self postNotification:GBNotificationConnected withInfo:nil];
	else
		[self postNotification:GBNotificationConnectionFailed withInfo:nil];

	return connected;
}

- (void) disconnect
{
	// this won't work until we upgrade to libsqlite 3.5.9
//	sqlite3_stmt *pStmt;
//	while( (pStmt = sqlite3_next_stmt(database, 0))!=0 ){
//		sqlite3_finalize(pStmt);
//	}
	sqlite3_close(database);
	connected = NO;
}

@end