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

#import "SQLiteSchema.h"
#import "SQLite.h"
#import "SQLiteConnection.h"

@implementation SQLiteSchema

@synthesize server;
@synthesize connection;

- (NSString *)name
{
	return [connection.file lastPathComponent];
}

- (NSArray *) supportedFeatures
{
	return [NSArray arrayWithObjects:GBFeatureTable, GBFeatureView, GBFeatureTrigger, nil];
}

- (NSArray *) tables
{
	NSArray *t = [self sqliteMasterField:@"table" ofType:[GBTable class]];
	return t;
}

- (NSArray *)views
{
	return [self sqliteMasterField:@"view" ofType:[GBTable class]];
}

- (NSArray *)triggers
{
	return [self sqliteMasterField:@"trigger" ofType:[GBTable class]];
}


//supprting methods
- (NSArray *)sqliteMasterField:(NSString *)field ofType:(Class)type
{
	NSMutableArray *array;
	GBResultSet *resultSet = nil;
	@try {
		NSString *query = [NSString stringWithFormat:@"SELECT `name` FROM SQLITE_MASTER WHERE `type`='%@';", field];
		resultSet = [server query:query];
	}
	@catch (NSException * e) {
		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[e reason], @"reason",
							  [[e userInfo] objectForKey:@"query"], @"query", nil];
		[self.server postNotification:GBNotificationInvalidQuery withInfo:info];
	}
	
	array = [NSMutableArray array];
	for (GBResult *row in [resultSet results]) {
		GBFeature *obj = [[type alloc] initWithServer:self.server];
		[obj setName:[row.row valueForKey:@"name"]];
		[array addObject:obj];
	}
	
	return array;	
}

@end
