/*
Copyright (c) 2008-2012
	Lars-Dominik Braun <lars@6xq.net>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#ifndef __FreeBSD__
#define _BSD_SOURCE /* required by strdup() */
#define _DARWIN_C_SOURCE /* strdup() on OS X */
#endif

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <stdint.h>
#include <json.h>

/* needed for urlencode */
#include <waitress.h>

#include "piano_private.h"
#include "piano.h"
#include "xml.h"
#include "crypt.h"
#include "config.h"

#define PIANO_RPC_PATH "/services/json/?"
#define PIANO_SEND_BUFFER_SIZE 10000

/*	initialize piano handle
 *	@param piano handle
 *	@return nothing
 */
void PianoInit (PianoHandle_t *ph) {
	memset (ph, 0, sizeof (*ph));

	/* route-id seems to be random. we're using time anyway... */
	snprintf (ph->routeId, sizeof (ph->routeId), "%07luP",
			(unsigned long) time (NULL) % 10000000);
}

/*	destroy artist linked list
 */
static void PianoDestroyArtists (PianoArtist_t *artists) {
	PianoArtist_t *curArtist, *lastArtist;

	curArtist = artists;
	while (curArtist != NULL) {
		free (curArtist->name);
		free (curArtist->musicId);
		free (curArtist->seedId);
		lastArtist = curArtist;
		curArtist = curArtist->next;
		free (lastArtist);
	}
}

/*	free complete search result
 *	@public yes
 *	@param search result
 */
void PianoDestroySearchResult (PianoSearchResult_t *searchResult) {
	PianoDestroyArtists (searchResult->artists);
	PianoDestroyPlaylist (searchResult->songs);
}

/*	free single station
 *	@param station
 */
void PianoDestroyStation (PianoStation_t *station) {
	free (station->name);
	free (station->id);
	free (station->seedId);
	memset (station, 0, sizeof (*station));
}

/*	free complete station list
 *	@param piano handle
 */
static void PianoDestroyStations (PianoStation_t *stations) {
	PianoStation_t *curStation, *lastStation;

	curStation = stations;
	while (curStation != NULL) {
		lastStation = curStation;
		curStation = curStation->next;
		PianoDestroyStation (lastStation);
		free (lastStation);
	}
}

/* FIXME: copy & waste */
/*	free _all_ elements of playlist
 *	@param piano handle
 *	@return nothing
 */
void PianoDestroyPlaylist (PianoSong_t *playlist) {
	PianoSong_t *curSong, *lastSong;

	curSong = playlist;
	while (curSong != NULL) {
		free (curSong->audioUrl);
		free (curSong->coverArt);
		free (curSong->artist);
		free (curSong->musicId);
		free (curSong->title);
		free (curSong->userSeed);
		free (curSong->stationId);
		free (curSong->album);
		free (curSong->artistMusicId);
		free (curSong->feedbackId);
		free (curSong->seedId);
		free (curSong->detailUrl);
		free (curSong->trackToken);
		lastSong = curSong;
		curSong = curSong->next;
		free (lastSong);
	}
}

void PianoDestroyStationInfo (PianoStationInfo_t *info) {
	PianoDestroyPlaylist (info->feedback);
	PianoDestroyPlaylist (info->songSeeds);
	PianoDestroyArtists (info->artistSeeds);
	PianoDestroyStations (info->stationSeeds);
}

/*	destroy genre linked list
 */
static void PianoDestroyGenres (PianoGenre_t *genres) {
	PianoGenre_t *curGenre, *lastGenre;

	curGenre = genres;
	while (curGenre != NULL) {
		free (curGenre->name);
		free (curGenre->musicId);
		lastGenre = curGenre;
		curGenre = curGenre->next;
		free (lastGenre);
	}
}

/*	destroy user information
 */
static void PianoDestroyUserInfo (PianoUserInfo_t *user) {
	free (user->webAuthToken);
	free (user->authToken);
	free (user->listenerId);
}

/*	frees the whole piano handle structure
 *	@param piano handle
 *	@return nothing
 */
void PianoDestroy (PianoHandle_t *ph) {
	PianoDestroyUserInfo (&ph->user);
	PianoDestroyStations (ph->stations);
	/* destroy genre stations */
	PianoGenreCategory_t *curGenreCat = ph->genreStations, *lastGenreCat;
	while (curGenreCat != NULL) {
		PianoDestroyGenres (curGenreCat->genres);
		free (curGenreCat->name);
		lastGenreCat = curGenreCat;
		curGenreCat = curGenreCat->next;
		free (lastGenreCat);
	}
	memset (ph, 0, sizeof (*ph));
}

/*	destroy request, free post data. req->responseData is *not* freed here, as
 *	it might be allocated by something else than malloc!
 *	@param piano request
 */
void PianoDestroyRequest (PianoRequest_t *req) {
	free (req->postData);
	memset (req, 0, sizeof (*req));
}

/*	convert audio format id to string that can be used in xml requests
 *	@param format id
 *	@return constant string
 */
static const char *PianoAudioFormatToString (PianoAudioFormat_t format) {
	switch (format) {
		case PIANO_AF_AACPLUS:
			return "aacplus";
			break;

		case PIANO_AF_MP3:
			return "mp3";
			break;

		case PIANO_AF_MP3_HI:
			return "mp3-hifi";
			break;

		default:
			return NULL;
			break;
	}
}

/*	prepare piano request (initializes request type, urlpath and postData)
 *	@param piano handle
 *	@param request structure
 *	@param request type
 */
PianoReturn_t PianoRequest (PianoHandle_t *ph, PianoRequest_t *req,
		PianoRequestType_t type) {
	char xmlSendBuf[PIANO_SEND_BUFFER_SIZE];
	char *jsonSendBuf;
	json_object *j = json_object_new_object();
	/* corrected timestamp */
	time_t timestamp = time (NULL) - ph->timeOffset;
	bool encrypted = true;

	assert (ph != NULL);
	assert (req != NULL);

	req->type = type;
	/* no tls by default */
	req->secure = false;

	switch (req->type) {
		case PIANO_REQUEST_LOGIN: {
			/* authenticate user */
			PianoRequestDataLogin_t *logindata = req->data;

			assert (logindata != NULL);

			switch (logindata->step) {
				case 0:
					encrypted = false;
					req->secure = true;

					json_object_object_add(j, "username", json_object_new_string("android"));
					json_object_object_add(j, "password", json_object_new_string("AC7IBG09A3DTSYM4R41UJWL07VLN8JI7"));
					json_object_object_add(j, "deviceModel", json_object_new_string("android-generic"));
					json_object_object_add(j, "version", json_object_new_string("5"));
					json_object_object_add(j, "includeUrls", json_object_new_boolean(true));
					snprintf (req->urlPath, sizeof (req->urlPath), PIANO_RPC_PATH
							"method=auth.partnerLogin");
					break;

				case 1: {
					char *urlencAuthToken;

					req->secure = true;

					json_object_object_add(j, "loginType", json_object_new_string("user"));
					json_object_object_add(j, "username", json_object_new_string(logindata->user));
					json_object_object_add(j, "password", json_object_new_string(logindata->password));
					json_object_object_add(j, "partnerAuthToken", json_object_new_string(ph->partnerAuthToken));
					json_object_object_add(j, "syncTime", json_object_new_int(timestamp));

					urlencAuthToken = WaitressUrlEncode (ph->partnerAuthToken);
					assert (urlencAuthToken != NULL);
					snprintf (req->urlPath, sizeof (req->urlPath), PIANO_RPC_PATH
							"method=auth.userLogin&auth_token=%s&partner_id=%i", urlencAuthToken, ph->partnerId);
					free (urlencAuthToken);

					break;
				}
			}
			break;
		}

		case PIANO_REQUEST_GET_STATIONS: {
			char *urlencAuthToken;

			/* get stations, user must be authenticated */
			assert (ph->user.listenerId != NULL);

			json_object_object_add(j, "userAuthToken", json_object_new_string(ph->user.authToken));
			json_object_object_add(j, "syncTime", json_object_new_int(timestamp));

			urlencAuthToken = WaitressUrlEncode (ph->user.authToken);
			assert (urlencAuthToken != NULL);
			snprintf (req->urlPath, sizeof (req->urlPath), PIANO_RPC_PATH
					"method=user.getStationList&auth_token=%s&partner_id=%i&user_id=%s", urlencAuthToken, ph->partnerId, ph->user.listenerId);
			free (urlencAuthToken);
			break;
		}

		case PIANO_REQUEST_GET_PLAYLIST: {
			/* get playlist for specified station */
			PianoRequestDataGetPlaylist_t *reqData = req->data;
			char *urlencAuthToken;

			assert (reqData != NULL);
			assert (reqData->station != NULL);
			assert (reqData->station->id != NULL);
			assert (reqData->format != PIANO_AF_UNKNOWN);

			req->secure = true;

			json_object_object_add(j, "stationToken", json_object_new_string(reqData->station->id));
			json_object_object_add(j, "userAuthToken", json_object_new_string(ph->user.authToken));
			json_object_object_add(j, "syncTime", json_object_new_int(timestamp));

			urlencAuthToken = WaitressUrlEncode (ph->user.authToken);
			assert (urlencAuthToken != NULL);
			snprintf (req->urlPath, sizeof (req->urlPath), PIANO_RPC_PATH
					"method=station.getPlaylist&auth_token=%s&partner_id=%i&user_id=%s", urlencAuthToken, ph->partnerId, ph->user.listenerId);
			break;
		}

		case PIANO_REQUEST_ADD_FEEDBACK: {
			/* low-level, don't use directly (see _RATE_SONG and _MOVE_SONG) */
			PianoRequestDataAddFeedback_t *reqData = req->data;
			char *urlencAuthToken;
			
			assert (reqData != NULL);
			assert (reqData->trackToken != NULL);
			assert (reqData->rating != PIANO_RATE_NONE);

			json_object_object_add(j, "trackToken", json_object_new_string(reqData->trackToken));
			json_object_object_add(j, "isPositive", json_object_new_boolean (reqData->rating == PIANO_RATE_LOVE));
			json_object_object_add(j, "userAuthToken", json_object_new_string(ph->user.authToken));
			json_object_object_add(j, "syncTime", json_object_new_int(timestamp));

			urlencAuthToken = WaitressUrlEncode (ph->user.authToken);
			assert (urlencAuthToken != NULL);
			snprintf (req->urlPath, sizeof (req->urlPath), PIANO_RPC_PATH
					"method=station.addFeedback&auth_token=%s&partner_id=%i&user_id=%s",
					urlencAuthToken, ph->partnerId, ph->user.listenerId);
			break;
		}

		case PIANO_REQUEST_DELETE_STATION: {
			/* delete station */
			PianoStation_t *station = req->data;
			char *urlencAuthToken;

			assert (station != NULL);
			assert (station->id != NULL);

			json_object_object_add(j, "stationToken", json_object_new_string(station->id));
			json_object_object_add(j, "userAuthToken", json_object_new_string(ph->user.authToken));
			json_object_object_add(j, "syncTime", json_object_new_int(timestamp));

			urlencAuthToken = WaitressUrlEncode (ph->user.authToken);
			assert (urlencAuthToken != NULL);
			snprintf (req->urlPath, sizeof (req->urlPath), PIANO_RPC_PATH
					"method=station.deleteStation&auth_token=%s&partner_id=%i&user_id=%s",
					urlencAuthToken, ph->partnerId, ph->user.listenerId);

			break;
		}

		case PIANO_REQUEST_SEARCH: {
			/* search for artist/song title */
			PianoRequestDataSearch_t *reqData = req->data;
			char *urlencAuthToken;

			assert (reqData != NULL);
			assert (reqData->searchStr != NULL);

			json_object_object_add(j, "searchText", json_object_new_string(reqData->searchStr));
			json_object_object_add(j, "userAuthToken", json_object_new_string(ph->user.authToken));
			json_object_object_add(j, "syncTime", json_object_new_int(timestamp));

			urlencAuthToken = WaitressUrlEncode (ph->user.authToken);
			assert (urlencAuthToken != NULL);
			snprintf (req->urlPath, sizeof (req->urlPath), PIANO_RPC_PATH
					"method=music.search&auth_token=%s&partner_id=%i&user_id=%s",
					urlencAuthToken, ph->partnerId, ph->user.listenerId);
			break;
		}

		case PIANO_REQUEST_CREATE_STATION: {
			/* create new station from specified musicid (type=mi, get one by
			 * performing a search) or shared station id (type=sh) */
			PianoRequestDataCreateStation_t *reqData = req->data;
			char *urlencAuthToken;

			assert (reqData != NULL);
			assert (reqData->id != NULL);

			json_object_object_add(j, "musicToken", json_object_new_string(reqData->id));
			json_object_object_add(j, "userAuthToken", json_object_new_string(ph->user.authToken));
			json_object_object_add(j, "syncTime", json_object_new_int(timestamp));

			urlencAuthToken = WaitressUrlEncode (ph->user.authToken);
			assert (urlencAuthToken != NULL);
			snprintf (req->urlPath, sizeof (req->urlPath), PIANO_RPC_PATH
					"method=station.createStation&auth_token=%s&partner_id=%i&user_id=%s",
					urlencAuthToken, ph->partnerId, ph->user.listenerId);
			break;
		}

		case PIANO_REQUEST_ADD_TIRED_SONG: {
			/* ban song for a month from all stations */
			PianoSong_t *song = req->data;
			char *urlencAuthToken;

			assert (song != NULL);

			json_object_object_add(j, "trackToken", json_object_new_string(song->trackToken));
			json_object_object_add(j, "userAuthToken", json_object_new_string(ph->user.authToken));
			json_object_object_add(j, "syncTime", json_object_new_int(timestamp));

			urlencAuthToken = WaitressUrlEncode (ph->user.authToken);
			assert (urlencAuthToken != NULL);
			snprintf (req->urlPath, sizeof (req->urlPath), PIANO_RPC_PATH
					"method=user.sleepSong&auth_token=%s&partner_id=%i&user_id=%s",
					urlencAuthToken, ph->partnerId, ph->user.listenerId);
			break;
		}

		case PIANO_REQUEST_GET_GENRE_STATIONS:
			/* receive list of pandora's genre stations */
			xmlSendBuf[0] = '\0';
			snprintf (req->urlPath, sizeof (req->urlPath), "/xml/genre?r=%lu",
					(unsigned long) timestamp);
			break;

		case PIANO_REQUEST_EXPLAIN: {
			/* explain why particular song was played */
			PianoRequestDataExplain_t *reqData = req->data;

			assert (reqData != NULL);
			assert (reqData->song != NULL);

			snprintf (xmlSendBuf, sizeof (xmlSendBuf), "<?xml version=\"1.0\"?>"
					"<methodCall><methodName>playlist.narrative</methodName>"
					"<params><param><value><int>%lu</int></value></param>"
					/* auth token */
					"<param><value><string>%s</string></value></param>"
					/* station id */
					"<param><value><string>%s</string></value></param>"
					/* music id */
					"<param><value><string>%s</string></value></param>"
					"</params></methodCall>", (unsigned long) timestamp,
					ph->user.authToken, reqData->song->stationId,
					reqData->song->musicId);
			snprintf (req->urlPath, sizeof (req->urlPath), PIANO_RPC_PATH
					"rid=%s&lid=%s&method=narrative&arg1=%s&arg2=%s",
					ph->routeId, ph->user.listenerId, reqData->song->stationId,
					reqData->song->musicId);
			break;
		}

		case PIANO_REQUEST_BOOKMARK_SONG: {
			/* bookmark song */
			PianoSong_t *song = req->data;

			assert (song != NULL);

			snprintf (xmlSendBuf, sizeof (xmlSendBuf), "<?xml version=\"1.0\"?>"
					"<methodCall><methodName>station.createBookmark</methodName>"
					"<params><param><value><int>%lu</int></value></param>"
					/* auth token */
					"<param><value><string>%s</string></value></param>"
					/* station id */
					"<param><value><string>%s</string></value></param>"
					/* music id */
					"<param><value><string>%s</string></value></param>"
					"</params></methodCall>", (unsigned long) timestamp,
					ph->user.authToken, song->stationId, song->musicId);
			snprintf (req->urlPath, sizeof (req->urlPath), PIANO_RPC_PATH
					"rid=%s&lid=%s&method=createBookmark&arg1=%s&arg2=%s",
					ph->routeId, ph->user.listenerId, song->stationId,
					song->musicId);
			break;
		}

		case PIANO_REQUEST_BOOKMARK_ARTIST: {
			/* bookmark artist */
			PianoSong_t *song = req->data;

			assert (song != NULL);

			snprintf (xmlSendBuf, sizeof (xmlSendBuf), "<?xml version=\"1.0\"?>"
					"<methodCall><methodName>station.createArtistBookmark</methodName>"
					"<params><param><value><int>%lu</int></value></param>"
					/* auth token */
					"<param><value><string>%s</string></value></param>"
					/* music id */
					"<param><value><string>%s</string></value></param>"
					"</params></methodCall>", (unsigned long) timestamp,
					ph->user.authToken, song->artistMusicId);
			snprintf (req->urlPath, sizeof (req->urlPath), PIANO_RPC_PATH
					"rid=%s&lid=%s&method=createArtistBookmark&arg1=%s",
					ph->routeId, ph->user.listenerId, song->artistMusicId);
			break;
		}

		/* "high-level" wrapper */
		case PIANO_REQUEST_RATE_SONG: {
			/* love/ban song */
			PianoRequestDataRateSong_t *reqData = req->data;
			PianoReturn_t pRet;

			assert (reqData != NULL);
			assert (reqData->song != NULL);
			assert (reqData->rating != PIANO_RATE_NONE);

			PianoRequestDataAddFeedback_t transformedReqData;
			transformedReqData.stationId = reqData->song->stationId;
			transformedReqData.trackToken = reqData->song->trackToken;
			transformedReqData.rating = reqData->rating;
			req->data = &transformedReqData;

			/* create request data (url, post data) */
			pRet = PianoRequest (ph, req, PIANO_REQUEST_ADD_FEEDBACK);
			/* and reset request type/data */
			req->type = PIANO_REQUEST_RATE_SONG;
			req->data = reqData;

			return pRet;
			break;
		}

		case PIANO_REQUEST_MOVE_SONG: {
			/* move song to a different station, needs two requests */
			PianoRequestDataMoveSong_t *reqData = req->data;
			PianoRequestDataAddFeedback_t transformedReqData;
			PianoReturn_t pRet;

			assert (reqData != NULL);
			assert (reqData->song != NULL);
			assert (reqData->from != NULL);
			assert (reqData->to != NULL);
			assert (reqData->step < 2);

			transformedReqData.trackToken = reqData->song->trackToken;
			req->data = &transformedReqData;

			switch (reqData->step) {
				case 0:
					transformedReqData.stationId = reqData->from->id;
					transformedReqData.rating = PIANO_RATE_BAN;
					break;

				case 1:
					transformedReqData.stationId = reqData->to->id;
					transformedReqData.rating = PIANO_RATE_LOVE;
					break;
			}

			/* create request data (url, post data) */
			pRet = PianoRequest (ph, req, PIANO_REQUEST_ADD_FEEDBACK);
			/* and reset request type/data */
			req->type = PIANO_REQUEST_MOVE_SONG;
			req->data = reqData;

			return pRet;
			break;
		}

		default:
			assert (0);
			break;
	}

	jsonSendBuf = json_object_to_json_string (j);
	if (encrypted) {
		fprintf (stderr, "sending json: %s\n", jsonSendBuf);
		if ((req->postData = PianoEncryptString (jsonSendBuf)) == NULL) {
			return PIANO_RET_OUT_OF_MEMORY;
		}
	} else {
		fprintf (stderr, "sending unencrypted json: %s\n", jsonSendBuf);
		req->postData = jsonSendBuf;
	}

	return PIANO_RET_OK;
}

static char *PianoJsonStrdup (json_object *j, const char *key) {
	return strdup (json_object_get_string (json_object_object_get (j, key)));
}

static void PianoJsonParseStation (json_object *j, PianoStation_t *s) {
	s->name = PianoJsonStrdup (j, "stationName");
	s->id = PianoJsonStrdup (j, "stationToken");
	s->isCreator = true;
	s->isQuickMix = json_object_get_boolean (json_object_object_get (j, "isQuickMix"));
}

/*	parse xml response and update data structures/return new data structure
 *	@param piano handle
 *	@param initialized request (expects responseData to be a NUL-terminated
 *			string)
 */
PianoReturn_t PianoResponse (PianoHandle_t *ph, PianoRequest_t *req) {
	PianoReturn_t ret = PIANO_RET_OK;
	json_object *j, *result;

	assert (ph != NULL);
	assert (req != NULL);

	j = json_tokener_parse (req->responseData);
	result = json_object_object_get (j, "result");

	switch (req->type) {
		case PIANO_REQUEST_LOGIN: {
			/* authenticate user */
			PianoRequestDataLogin_t *reqData = req->data;

			assert (req->responseData != NULL);
			assert (reqData != NULL);

			switch (reqData->step) {
				case 0: {
					/* decrypt timestamp */
					const char *cryptedTimestamp = json_object_get_string (json_object_object_get (result, "syncTime"));
					unsigned long timestamp = 0;
					const time_t realTimestamp = time (NULL);
					char *decryptedTimestamp = NULL;
					size_t decryptedSize;

					ret = PIANO_RET_ERR;
					if ((decryptedTimestamp = PianoDecryptString (cryptedTimestamp,
							&decryptedSize)) != NULL && decryptedSize > 4) {
						/* skip four bytes garbage(?) at beginning */
						timestamp = strtoul (decryptedTimestamp+4, NULL, 0);
						ph->timeOffset = realTimestamp - timestamp;
						ret = PIANO_RET_CONTINUE_REQUEST;
					}
					free (decryptedTimestamp);
					/* get auth token */
					ph->partnerAuthToken = PianoJsonStrdup (result, "partnerAuthToken");
					ph->partnerId = json_object_get_int (json_object_object_get (result, "partnerId"));
					++reqData->step;
					break;
				}

				case 1:
					/* information exists when reauthenticating, destroy to
					 * avoid memleak */
					if (ph->user.listenerId != NULL) {
						PianoDestroyUserInfo (&ph->user);
					}
					ph->user.listenerId = PianoJsonStrdup (result, "userId");
					ph->user.authToken = PianoJsonStrdup (result, "userAuthToken");
					break;
			}
			break;
		}

		case PIANO_REQUEST_GET_STATIONS: {
			/* get stations */
			assert (req->responseData != NULL);

			json_object *stations = json_object_object_get (result, "stations");

			for (size_t i=0; i < json_object_array_length (stations); i++) {
				PianoStation_t *tmpStation;
				json_object *s = json_object_array_get_idx (stations, i);

				if ((tmpStation = calloc (1, sizeof (*tmpStation))) == NULL) {
					return PIANO_RET_OUT_OF_MEMORY;
				}

				PianoJsonParseStation (s, tmpStation);

				/* get stations selected for quickmix */
				if (tmpStation->isQuickMix) {
					/*PianoXmlStructParser (ezxml_child (dataNode, "struct"),
							PianoXmlParseQuickMixStationsCb, &quickMixIds);*/
				}
				/* start new linked list or append */
				if (ph->stations == NULL) {
					ph->stations = tmpStation;
				} else {
					PianoStation_t *curStation = ph->stations;
					while (curStation->next != NULL) {
						curStation = curStation->next;
					}
					curStation->next = tmpStation;
				}
			}
			
			ret = PianoXmlParseStations (ph, req->responseData);
			break;
		}

		case PIANO_REQUEST_GET_PLAYLIST: {
			/* get playlist, usually four songs */
			PianoRequestDataGetPlaylist_t *reqData = req->data;
			PianoSong_t *playlist = NULL;

			assert (req->responseData != NULL);
			assert (reqData != NULL);

			json_object *items = json_object_object_get (result, "items");
			assert (items != NULL);

			for (size_t i=0; i < json_object_array_length (items); i++) {
				json_object *s = json_object_array_get_idx (items, i);
				PianoSong_t *song;

				if ((song = calloc (1, sizeof (*song))) == NULL) {
					return PIANO_RET_OUT_OF_MEMORY;
				}

				if (json_object_object_get (s, "artistName") == NULL) {
					free (song);
					continue;
				}
				song->audioUrl = strdup (json_object_get_string (json_object_object_get (json_object_object_get(json_object_object_get (s, "audioUrlMap"), "highQuality"), "audioUrl")));
				song->artist = PianoJsonStrdup (s, "artistName");
				song->album = PianoJsonStrdup (s, "albumName");
				song->title = PianoJsonStrdup (s, "songName");
				song->trackToken = PianoJsonStrdup (s, "trackToken");
				song->fileGain = json_object_get_double (json_object_object_get (s, "trackGain"));
				song->audioFormat = PIANO_AF_AACPLUS;
				switch (json_object_get_int (json_object_object_get (s, "songRating"))) {
					case 1:
						song->rating = PIANO_RATE_LOVE;
						break;
				}

				/* begin linked list or append */
				if (playlist == NULL) {
					playlist = song;
				} else {
					PianoSong_t *curSong = playlist;
					while (curSong->next != NULL) {
						curSong = curSong->next;
					}
					curSong->next = song;
				}
			}

			reqData->retPlaylist = playlist;
			break;
		}

		case PIANO_REQUEST_RATE_SONG:
			/* love/ban song */
			/* response unused */
			break;

		case PIANO_REQUEST_ADD_FEEDBACK:
			/* never ever use this directly, low-level call */
			assert (0);
			break;

		case PIANO_REQUEST_MOVE_SONG: {
			/* move song to different station */
			PianoRequestDataMoveSong_t *reqData = req->data;

			assert (req->responseData != NULL);
			assert (reqData != NULL);
			assert (reqData->step < 2);

			ret = PianoXmlParseSimple (req->responseData);
			if (ret == PIANO_RET_OK && reqData->step == 0) {
				ret = PIANO_RET_CONTINUE_REQUEST;
				++reqData->step;
			}
			break;
		}

		case PIANO_REQUEST_DELETE_STATION: {
			/* delete station from server and station list */
			PianoStation_t *station = req->data;

			assert (station != NULL);

			/* delete station from local station list */
			PianoStation_t *curStation = ph->stations, *lastStation = NULL;
			while (curStation != NULL) {
				if (curStation == station) {
					if (lastStation != NULL) {
						lastStation->next = curStation->next;
					} else {
						/* first station in list */
						ph->stations = curStation->next;
					}
					PianoDestroyStation (curStation);
					free (curStation);
					break;
				}
				lastStation = curStation;
				curStation = curStation->next;
			}
			break;
		}

		case PIANO_REQUEST_SEARCH: {
			/* search artist/song */
			PianoRequestDataSearch_t *reqData = req->data;
			PianoSearchResult_t *searchResult;

			assert (req->responseData != NULL);
			assert (reqData != NULL);

			searchResult = &reqData->searchResult;
			memset (searchResult, 0, sizeof (*searchResult));

			/* get artists */
			json_object *artists = json_object_object_get (result, "artists");
			if (artists != NULL) {
				for (size_t i=0; i < json_object_array_length (artists); i++) {
					json_object *a = json_object_array_get_idx (artists, i);
					PianoArtist_t *artist;

					if ((artist = calloc (1, sizeof (*artist))) == NULL) {
						return PIANO_RET_OUT_OF_MEMORY;
					}

					artist->name = PianoJsonStrdup (a, "artistName");
					artist->musicId = PianoJsonStrdup (a, "musicToken");

					/* add result to linked list */
					if (searchResult->artists == NULL) {
						searchResult->artists = artist;
					} else {
						PianoArtist_t *curArtist = searchResult->artists;
						while (curArtist->next != NULL) {
							curArtist = curArtist->next;
						}
						curArtist->next = artist;
					}
				}
			}

			/* get songs */
			json_object *songs = json_object_object_get (result, "songs");
			if (songs != NULL) {
				for (size_t i=0; i < json_object_array_length (songs); i++) {
					json_object *s = json_object_array_get_idx (songs, i);
					PianoSong_t *song;

					if ((song = calloc (1, sizeof (*song))) == NULL) {
						return PIANO_RET_OUT_OF_MEMORY;
					}

					song->title = PianoJsonStrdup (s, "songName");
					song->artist = PianoJsonStrdup (s, "artistName");
					song->musicId = PianoJsonStrdup (s, "musicToken");

					/* add result to linked list */
					if (searchResult->songs == NULL) {
						searchResult->songs = song;
					} else {
						PianoSong_t *curSong = searchResult->songs;
						while (curSong->next != NULL) {
							curSong = curSong->next;
						}
						curSong->next = song;
					}
				}
			}
			break;
		}

		case PIANO_REQUEST_CREATE_STATION: {
			/* create station, insert new station into station list on success */
			PianoStation_t *tmpStation;

			if ((tmpStation = calloc (1, sizeof (*tmpStation))) == NULL) {
				return PIANO_RET_OUT_OF_MEMORY;
			}

			PianoJsonParseStation (result, tmpStation);

			/* start new linked list or append */
			if (ph->stations == NULL) {
				ph->stations = tmpStation;
			} else {
				PianoStation_t *curStation = ph->stations;
				while (curStation->next != NULL) {
					curStation = curStation->next;
				}
				curStation->next = tmpStation;
			}
			break;
		}

		case PIANO_REQUEST_ADD_TIRED_SONG:
		case PIANO_REQUEST_BOOKMARK_SONG:
		case PIANO_REQUEST_BOOKMARK_ARTIST:
		case PIANO_REQUEST_DELETE_FEEDBACK:
			/* response unused */
			break;

		case PIANO_REQUEST_GET_GENRE_STATIONS:
			/* get genre stations */
			assert (req->responseData != NULL);

			ret = PianoXmlParseGenreExplorer (ph, req->responseData);
			break;

		case PIANO_REQUEST_EXPLAIN: {
			/* explain why song was selected */
			PianoRequestDataExplain_t *reqData = req->data;

			assert (req->responseData != NULL);
			assert (reqData != NULL);

			ret = PianoXmlParseNarrative (req->responseData, &reqData->retExplain);
			break;
		}

		default:
			assert (0);
			break;
	}

	return ret;
}

/*	get station from list by id
 *	@param search here
 *	@param search for this
 *	@return the first station structure matching the given id
 */
PianoStation_t *PianoFindStationById (PianoStation_t *stations,
		const char *searchStation) {
	while (stations != NULL) {
		if (strcmp (stations->id, searchStation) == 0) {
			return stations;
		}
		stations = stations->next;
	}
	return NULL;
}

/*	convert return value to human-readable string
 *	@param enum
 *	@return error string
 */
const char *PianoErrorToStr (PianoReturn_t ret) {
	switch (ret) {
		case PIANO_RET_OK:
			return "Everything is fine :)";
			break;

		case PIANO_RET_ERR:
			return "Unknown.";
			break;

		case PIANO_RET_XML_INVALID:
			return "Invalid XML.";
			break;

		case PIANO_RET_AUTH_TOKEN_INVALID:
			return "Invalid auth token.";
			break;
		
		case PIANO_RET_AUTH_USER_PASSWORD_INVALID:
			return "Username and/or password not correct.";
			break;

		case PIANO_RET_NOT_AUTHORIZED:
			return "Not authorized.";
			break;

		case PIANO_RET_PROTOCOL_INCOMPATIBLE:
			return "Protocol incompatible. Please upgrade " PACKAGE ".";
			break;

		case PIANO_RET_READONLY_MODE:
			return "Request cannot be completed at this time, please try "
					"again later.";
			break;

		case PIANO_RET_STATION_CODE_INVALID:
			return "Station id is invalid.";
			break;

		case PIANO_RET_IP_REJECTED:
			return "Your ip address was rejected. Please setup a control "
					"proxy (see manpage).";
			break;

		case PIANO_RET_STATION_NONEXISTENT:
			return "Station does not exist.";
			break;

		case PIANO_RET_OUT_OF_MEMORY:
			return "Out of memory.";
			break;

		case PIANO_RET_OUT_OF_SYNC:
			return "Out of sync. Please correct your system's time.";
			break;

		case PIANO_RET_PLAYLIST_END:
			return "Playlist end.";
			break;

		case PIANO_RET_QUICKMIX_NOT_PLAYABLE:
			return "Quickmix not playable.";
			break;

		case PIANO_RET_REMOVING_TOO_MANY_SEEDS:
			return "Last seed cannot be removed.";
			break;

		case PIANO_RET_EXCESSIVE_ACTIVITY:
			return "Excessive activity.";
			break;

		case PIANO_RET_DAILY_SKIP_LIMIT_REACHED:
			return "Daily skip limit reached.";
			break;

		default:
			return "No error message available.";
			break;
	}
}

