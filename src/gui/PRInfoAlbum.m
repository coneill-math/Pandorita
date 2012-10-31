//
//  PRAlbum.m
//  Pandorita
//
//  Created by Chris O'Neill on 10/28/12.
//
//

#import "PRInfoAlbum.h"


@implementation PRInfoTrack

- (id)init
{
	self = [super init];
	
	if (self)
	{
		linkStr = @"";
		trackName = @"";
		sampleLinkStr = @"";
		trackNumber = 0;
	}
	
	return self;
}

- (NSString *)linkStr
{
	return linkStr;
}

- (NSString *)trackName
{
	return trackName;
}

- (NSString *)sampleLinkStr
{
	return sampleLinkStr;
}

- (NSUInteger)trackNumber
{
	return trackNumber;
}

- (void)setLinkStr:(NSString *)str
{
	RETAIN_MEMBER(str);
	RELEASE_MEMBER(linkStr);
	linkStr = str;
}

- (void)setTrackName:(NSString *)str
{
	RETAIN_MEMBER(str);
	RELEASE_MEMBER(trackName);
	trackName = str;
}

- (void)setSampleLinkStr:(NSString *)str
{
	RETAIN_MEMBER(str);
	RELEASE_MEMBER(sampleLinkStr);
	sampleLinkStr = str;
}

- (void)setTrackNumber:(NSUInteger)num
{
	trackNumber = num;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ - %@ - %@", trackName, linkStr, sampleLinkStr];
}

- (void)dealloc
{
	RELEASE_MEMBER(linkStr);
	RELEASE_MEMBER(trackName);
	RELEASE_MEMBER(sampleLinkStr);
	[super dealloc];
}

@end

@implementation PRInfoAlbum

- (id)init
{
	self = [super init];
	
	if (self)
	{
		linkStr = @"";
		musicId = @"";
		albumName = @"";
		albumYear = @"";
		albumArtwork = nil;
		tracks = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (NSString *)linkStr
{
	return linkStr;
}

- (NSString *)musicId
{
	return musicId;
}

- (NSImage *)albumArtwork
{
	return albumArtwork;
}

- (NSString *)albumName
{
	return albumName;
}

- (NSString *)albumYear
{
	return albumYear;
}

- (NSUInteger)trackCount
{
	return [tracks count];
}

- (PRInfoTrack *)trackAtIndex:(NSUInteger)index
{
	return [tracks objectAtIndex:index];
}

- (void)setLinkStr:(NSString *)str
{
	RETAIN_MEMBER(str);
	RELEASE_MEMBER(linkStr);
	linkStr = str;
}

- (void)setMusicId:(NSString *)str
{
	RETAIN_MEMBER(str);
	RELEASE_MEMBER(musicId);
	musicId = str;
}

- (void)setAlbumArtwork:(NSImage *)img
{
	RETAIN_MEMBER(img);
	RELEASE_MEMBER(albumArtwork);
	albumArtwork = img;
}

- (void)setAlbumName:(NSString *)str
{
	RETAIN_MEMBER(str);
	RELEASE_MEMBER(albumName);
	albumName = str;
}

- (void)setAlbumYear:(NSString *)str
{
	RETAIN_MEMBER(str);
	RELEASE_MEMBER(albumYear);
	albumYear = str;
}

- (void)addTrack:(PRInfoTrack *)track
{
	[tracks addObject:track];
	[track setTrackNumber:[tracks count]];
}

- (NSComparisonResult)compareToInfoAlbum:(PRInfoAlbum *)object
{
	// make sure its not null
	if (!object)
	{
		return NSGreaterThanComparison;
	}
	
	// empty years at the end
	if ([[self albumYear] isEqualToString:@""] && ![[object albumYear] isEqualToString:@""])
	{
		return NSGreaterThanComparison;
	}
	
	if (![[self albumYear] isEqualToString:@""] && [[object albumYear] isEqualToString:@""])
	{
		return NSLessThanComparison;
	}
	
	// nonempty years
	NSComparisonResult yearCompare = [albumYear compare:[object albumYear]];
	if (yearCompare != NSEqualToComparison)
	{
		return yearCompare;
	}
	
	return [albumName compare:[object albumName]];
}

- (void)dealloc
{
	RELEASE_MEMBER(linkStr);
	RELEASE_MEMBER(musicId);
	RELEASE_MEMBER(albumArtwork);
	RELEASE_MEMBER(albumName);
	RELEASE_MEMBER(albumYear);
	RELEASE_MEMBER(tracks);
	[super dealloc];
}

@end
