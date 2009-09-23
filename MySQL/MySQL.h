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

#import <Cocoa/Cocoa.h>
#import "Gearbox.h"
#import "mysql/include/mysql.h"

@protocol ShiftDbo;

@interface MySQL : NSObject <Gearbox>{
	IBOutlet NSView *editor;

	IBOutlet NSTextField *name;
	IBOutlet NSTextField *host;
	IBOutlet NSTextField *user;
	IBOutlet NSTextField *password;
	IBOutlet NSTextField *database;
	IBOutlet NSTextField *socket;
	IBOutlet NSTextField *port;
	
	IBOutlet NSImageView *nameWarning;
	IBOutlet NSImageView *hostWarning;
	IBOutlet NSImageView *userWarning;

@protected
	MYSQL               connection;
    BOOL                connected;
    NSStringEncoding    encoding;
    unsigned int        connectionFlags;
}

- (NSArray *) stringArrayFromResult:(MYSQL_RES *)result;

@end
