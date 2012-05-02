/*
Copyright (c) 2009-2011
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
#define _POSIX_C_SOURCE 1 /* required by getaddrinfo() */
#define _BSD_SOURCE /* snprintf() */
#define _DARWIN_C_SOURCE /* snprintf() on OS X */
#endif

#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#include "macwaitress.h"

/*	urlencode post-data
 *	@param encode this
 *	@return malloc'ed encoded string, don't forget to free it
 */
char *WaitressUrlEncode (const char *in) {
//	assert (in != NULL);

	size_t inLen = strlen (in);
	/* worst case: encode all characters */
	char *out = calloc (inLen * 3 + 1, sizeof (*in));
	const char *inPos = in;
	char *outPos = out;

	while (inPos - in < inLen) {
		if (!isalnum (*inPos) && *inPos != '_' && *inPos != '-' && *inPos != '.') {
			*outPos++ = '%';
			snprintf (outPos, 3, "%02x", *inPos & 0xff);
			outPos += 2;
		} else {
			/* copy character */
			*outPos++ = *inPos;
		}
		++inPos;
	}

	return out;
}


