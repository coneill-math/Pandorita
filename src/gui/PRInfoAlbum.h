//
//  PRAlbum.h
//  Pandorita
//
//  Created by Chris O'Neill on 10/28/12.
//
//

#import <Foundation/Foundation.h>


@interface PRInfoTrack : NSObject
{
	NSString *linkStr;
	NSString *trackName;
	NSString *sampleLinkStr;
	NSUInteger trackNumber;
}

- (NSString *)linkStr;
- (NSString *)trackName;
- (NSString *)sampleLinkStr;
- (NSUInteger)trackNumber;

- (void)setLinkStr:(NSString *)str;
- (void)setTrackName:(NSString *)str;
- (void)setSampleLinkStr:(NSString *)str;
- (void)setTrackNumber:(NSUInteger)num;

@end

@interface PRInfoAlbum : NSObject
{
	NSString *linkStr; // Pandorita-style link
	NSString *musicId;
	
	NSImage *albumArtwork;
	NSString *albumName;
	NSString *albumYear;
	
	NSMutableArray *tracks;
}

- (NSString *)linkStr;
- (NSString *)musicId;
- (NSImage *)albumArtwork;
- (NSString *)albumName;
- (NSString *)albumYear;

- (NSUInteger)trackCount;
- (PRInfoTrack *)trackAtIndex:(NSUInteger)index;

- (void)setLinkStr:(NSString *)str;
- (void)setMusicId:(NSString *)str;
- (void)setAlbumArtwork:(NSImage *)img;
- (void)setAlbumName:(NSString *)str;
- (void)setAlbumYear:(NSString *)str;

- (void)addTrack:(PRInfoTrack *)track;

- (NSComparisonResult)compareToInfoAlbum:(PRInfoAlbum *)object;

@end
