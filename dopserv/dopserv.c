#ifndef BARE
#include <fcntl.h>
#include <unistd.h>
#endif
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <time.h>
#include <sys/types.h>
#include "dopserv.h"

char inbuf[8192];
char message[4096];

#ifdef BARE
server_rec serverstruct;
static char msgout[8192];

extern char stdinbuf[];
static const char *inptr = stdinbuf;
char mygetchar() {return (*inptr++);}
char *stdinread() {
	if (!sscanf(inptr, "%s", inbuf)) return NULL;
	inptr += strlen(inbuf)+1;
	return inbuf;
}
#else //BARE
#define mygetchar getchar
char *stdinread() {
	if (scanf("%s", inbuf) == EOF) return NULL;
	return inbuf;
}
#endif //BARE

session_t session;
server_rec *main_server = NULL;

int main(int argc, char *argv[]) {
#ifdef BARE
	main_server = &serverstruct;
	main_server->ServerName = "DOPserv";
#else
	main_server = calloc(1, sizeof(main_server));
	main_server->ServerName = strdup("DOPserv");
#endif //BARE
	char *cmd;
	int i = 20;

	while (i-- && (cmd = stdinread())) {
		if (!strcmp(cmd, "PUT")) {
			const char *filename = stdinread();
			printf("putting to %s\n", filename);
			char *msgptr = message;
			char c;
			while ((c = mygetchar()) == '\n'); //we may need to consume some whitespace
			do {
				*msgptr++ = c;
			} while ((c = mygetchar()));
			*msgptr = '\0';
			printf("220 written %d bytes: %s\n", strlen(message), message);
		} else if (!strcmp(cmd, "GET")) {
			puts("502 GET");
		} else if (!strcmp(cmd, "CWD")) {
			const char* newdir = stdinread();
			printf("changing to %s\n", newdir);
			sstrncpy(session.cwd, newdir, sizeof(session.cwd)-1);
			pr_display_file("220");
		} else if (!strcmp(cmd, "PWD")) {
			puts(session.cwd);
			puts("220");
		} else if (!strcmp(cmd, "QUIT")) {
			puts("BYE");
			break;
		} else {
			printf("502 Unknown %s\n", inbuf);
		}
	}

	return 0;
}

int pr_display_file(const char *code) {
	char buf[PR_TUNABLE_BUFFER_SIZE] = {'\0'};
	int len;
	char *outs;
	const char *mg_time;
	unsigned char first = TRUE;

#ifdef BARE
	mg_time = pr_strtime(0);
#else
	mg_time = pr_strtime(time(NULL));
#endif

	int readlen = 0;
	while (readlen < strlen(message)) {
		memcpy(buf+readlen, message, sizeof(buf)-readlen);
	  buf[sizeof(buf)-1] = '\0';
	  len = strlen(buf);
		readlen += len;

	  while(len && (buf[len-1] == '\r' || buf[len-1] == '\n')) {
	    buf[len-1] = '\0';
	    len--;
	  }

	  outs = sreplace(buf,
	    "%C", (session.cwd[0] ? session.cwd : "(none)"),
	    "%T", mg_time,
	    "%V", main_server->ServerName,
	    NULL);

	  sstrncpy(buf, outs, sizeof(buf));

	  if (first) {
	    pr_response_send_raw("%s-%s", code, outs);
	    first = FALSE;

	  } else {
			pr_response_send_raw(" %s", outs);
	  }
	}

	return 0;
}


char *sreplace(char *s, ...) {
	va_list args;
	char *m,*r,*src = s,*cp;
	char **mptr,**rptr;
	char *pbuf = NULL;
	size_t mlen = 0, rlen = 0, blen;
	int dyn = TRUE;
	char *marr[33],*rarr[33];
  char buf[PR_TUNABLE_PATH_MAX] = {'\0'};

	cp = buf;
	*cp = '\0';

	memset(marr, '\0', sizeof(marr));
	memset(rarr, '\0', sizeof(rarr));
	blen = strlen(src) + 1;

	va_start(args, s);

	while ((m = va_arg(args, char *)) != NULL && mlen < sizeof(marr)-1) {
	  char *tmp = NULL;
	  size_t count = 0;

	  if ((r = va_arg(args, char *)) == NULL)
	    break;

	  /* Increase the length of the needed buffer by the difference between
	   * the given match and replacement strings, multiplied by the number
	   * of times the match string occurs in the source string.
	   */
	  tmp = strstr(s, m);
	  while (tmp) {
	    count++;

	    /* Be sure to increment the pointer returned by strstr(3), to
	     * advance past the beginning of the substring for which we are
	     * looking.  Otherwise, we just loop endlessly, seeing the same
	     * value for tmp over and over.
	     */
	    tmp += strlen(m);
	    tmp = strstr(tmp, m);
	  }

	  /* We are only concerned about match/replacement strings that actually
	   * occur in the given string.
	   */
	  if (count) {
	    blen += count * (strlen(r) - strlen(m));
	    marr[mlen] = m;
	    rarr[mlen++] = r;
	  }
	}

	va_end(args);


	/* Try to handle large buffer situations (i.e. escaping of PR_TUNABLE_PATH_MAX
	 * (>2048) correctly, but do not allow very big buffer sizes, that may
	 * be dangerous (BUFSIZ may be defined in stdio.h) in some library
	 * functions.
	 */

#ifndef BUFSIZ
# define BUFSIZ 8192
#endif

#ifndef BARE //calloc call should be avoided
	if (blen < BUFSIZ)
	  cp = pbuf = (char *) calloc(1, ++blen);
#endif

	if (!pbuf) {
	  cp = pbuf = buf;
	  dyn = FALSE;
	  blen = sizeof(buf);
	}

	while (*src) {
	  for (mptr = marr, rptr = rarr; *mptr; mptr++, rptr++) {
	    mlen = strlen(*mptr);
	    rlen = strlen(*rptr);

	    if (strncmp(src, *mptr, mlen) == 0) {
	      sstrncpy(cp, *rptr, blen - strlen(pbuf));
	if (((cp + rlen) - pbuf + 1) > blen) {
	  pr_log_pri(PR_LOG_ERR,
		  "WARNING: attempt to overflow internal ProFTPD buffers");
	  cp = pbuf + blen - 1;
	  goto done;

	} else {
	  cp += rlen;
	}
	
	      src += mlen;
	      break;
	    }
	  }

	  if (!*mptr) {
	    if ((cp - pbuf + 1) > blen) {
	pr_log_pri(PR_LOG_ERR,
		"WARNING: attempt to overflow internal ProFTPD buffers");
	cp = pbuf + blen - 1;
	    }
	    *cp++ = *src++;
	  }
	}

 done:
	*cp = '\0';

	if (dyn)
	  return pbuf;

#ifdef BARE
    return strcpy(msgout, buf);
#else
	return strdup(buf);
#endif
}

const char *pr_strtime(time_t t) {
	static char buf[30];
	char *mons[] = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
	  "Aug", "Sep", "Oct", "Nov", "Dec" };
	char *days[] = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" };
	struct tm *tr;

	memset(buf, '\0', sizeof(buf));

	tr = localtime(&t);
	if (tr != NULL) {
	  snprintf(buf, sizeof(buf), "%s %s %2d %02d:%02d:%02d %d",
	    days[tr->tm_wday], mons[tr->tm_mon], tr->tm_mday, tr->tm_hour,
	    tr->tm_min, tr->tm_sec, tr->tm_year + 1900);

	} else
	  buf[0] = '\0';

	buf[sizeof(buf)-1] = '\0';

	return buf;
}

char *sstrncpy(char *dest, const char *src, size_t n) {
	register char *d = dest;
	//fprintf(stderr, "sstrncpy(%p, %p, %u)\n", dest, src, n);

	if (!dest)
	  return NULL;

	if (src && *src) {
	  for (; *src && n > 1; n--)
	    *d++ = *src++;
	}

	*d = '\0';
	return dest;
}
