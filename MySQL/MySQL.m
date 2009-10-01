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

- (NSArray *) gbFeatures
{
	return [NSArray arrayWithObjects:GBFeatureTable, GBFeatureView, GBFeatureStoredProc, GBFeatureFunction, GBFeatureTrigger, nil];
}



//connection functions
- (BOOL) isConnected
{
	return connected;
}

- (BOOL) connect:(NSDictionary *)favorite
{	
	mysql_init(&connection);
	connected = NO;
	mysql_options(&connection,MYSQL_READ_DEFAULT_GROUP,"shift");
	if (mysql_real_connect(&connection,
							[[favorite objectForKey:@"host"] UTF8String],
							[[favorite objectForKey:@"user"] UTF8String],
							[[favorite objectForKey:@"password"] UTF8String],
							[[favorite objectForKey:@"database"] UTF8String],0,NULL,0))
	{
		connected = YES;
		[self postNotification:GBNotificationConnected withInfo:nil];
	}else {
		[self postNotification:GBNotificationConnectionFailed withInfo:nil];
		NSLog(@"MySQL: Failed to connected. Error:%@\n", [self lastErrorMessage]);
	}

	return connected;
}

- (void) disconnect
{
	if (connected)
		mysql_close(&connection);
	connected = NO;
}

- (void) selectSchema:(NSString *)schema
{
	if (connected) {
		mysql_select_db(&connection, [schema UTF8String]);
	}
}

- (NSArray *) listSchemas:(NSString *)filter
{
	if (!connected)
		return [NSArray array];
	
	
	const char *mysqlFilter = NULL;
	
	if (filter != nil && [filter length] > 0)
		mysqlFilter = [[NSString stringWithFormat:@"%%%@%%", filter] UTF8String];

	MYSQL_RES *result = mysql_list_dbs(&connection, mysqlFilter);
	NSArray *schemas = [self stringArrayFromResult:result];
	
	mysql_free_result(result);
	
	return schemas;
}

- (NSArray *) listTables:(NSString *)filter
{
	if (!connected)
		return [NSArray array];
	
	const char *mysqlFilter = NULL;
	
	if (filter != nil && [filter length] > 0)
		mysqlFilter = [[NSString stringWithFormat:@"%%%@%%", filter] UTF8String];
	
	MYSQL_RES *result = mysql_list_tables(&connection, mysqlFilter);
	NSArray *tables = [self stringArrayFromResult:result];

	mysql_free_result(result);
	
	return tables;
}

- (NSArray *) listViews:(NSString *)filter
{
	return nil;
}

- (NSArray *) listStoredProcs:(NSString *)filter
{
	//SELECT routine_name FROM information_schema.routines WHERE routine_schema LIKE 'testspp' AND routine_type = ''; 
	return nil;
}

- (NSArray *) listFunctions:(NSString *)filter
{
	//SELECT routine_name FROM information_schema.routines WHERE routine_schema LIKE 'testspp' AND routine_type = ''; 
	return nil;
}

- (NSArray *) listTriggers:(NSString *)filter
{
	//SELECT trigger_name FROM information_schema.triggers WHERE routine_schema LIKE 'testspp'; 
	return nil;
}

- (NSArray *) query:(NSString *)query
{
	return [NSArray array];
}

- (NSString *) lastErrorMessage
{
	return [NSString stringWithFormat:@"%s", mysql_error(&connection)];
}


//local helper methods
- (NSArray *) stringArrayFromResult:(MYSQL_RES *)result
{
	NSMutableArray *array = [NSMutableArray array];
	
	MYSQL_ROW row;
	
	while ((row = mysql_fetch_row(result)))
	{
		unsigned long *lengths;
		lengths = mysql_fetch_lengths(result);
		[array addObject:[NSString stringWithFormat:@"%.*s", (int) lengths[0], row[0]]];
	}
		
	return [NSArray arrayWithArray:array];
	
}
@end
