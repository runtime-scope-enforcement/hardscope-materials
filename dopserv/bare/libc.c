#include <sys/types.h>
#include <inttypes.h>
#include <time.h>
#include <stdarg.h>

struct tm __time_tm;

size_t strlen(const char *s);
int strncmp(const char *s1, const char *s2, size_t n);
char *sstrncpy(char *dest, const char *src, size_t n);

int sscanf(const char *str, const char *format, char *d) {
    int i = 0;
    char c;
    while(1) {
        c=str[i];
        if (c == ' ' || c == '\n' || c == '\0') {
            break;
        }
        d[i] = c;
        i++;
    }
	d[i] = '\0';
	return i;
}

//char *strncpy(char *dest, const char *src) {
//	return sstrncpy(dest, src, strlen(src));
//}

char *strstr(const char *haystack, const char *needle) {
	int needle_len = strlen(needle);
	char *p = (char*) haystack;
	do {
		if (!strncmp(p, needle, needle_len)) {
			return p;
		}
	} while (*++p);
	return NULL;
}

int strncmp(const char *s1, const char *s2, size_t n) {
	for (int i=0;i<n;i++) {
		if (s1[i] != s2[i]) return s1[i]-s2[i];
		if (s1[i] == 0 && s2[i] == 0) break;
	}
	return 0;
}

//from uClibc
const uint16_t _vals[] = {
	60, 60, 24, 7 /* special */, 36524, 1461, 365, 0
};

const unsigned char _days[] = {
	31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, /* non-leap */
	    29,
};

struct tm *_time_t2tm(const time_t *__restrict timer,
					  int offset, struct tm *__restrict result)
{
	register int *p;
	time_t t1, t, v;
	int wday = wday; /* ok to be uninitialized, shutting up warning */

	{
		register const uint16_t *vp;
		t = *timer;
		p = (int *) result;
		p[7] = 0;
		vp = _vals;
		do {
			if ((v = *vp) == 7) {
				if (((unsigned long)(t + offset- -784223472856L))
					> (784223421720L - -784223472856L)
					) {
					return NULL;
				}

				wday = (t + 4) % (*vp);	/* t is unsigned */
				/* Set divisor to days in 400 years.  Be kind to bcc... */
				v = ((time_t)(vp[1])) << 2;
				++v;
				/* Change to days since 1/1/1601 so that for 32 bit time_t
				 * values, we'll have t >= 0.  This should be changed for
				 * archs with larger time_t types.
				 * Also, correct for offset since a multiple of 7. */

				/* TODO: Does this still work on archs with time_t > 32 bits? */
				t += (135140L - 366) + offset; /* 146097 - (365*30 + 7) -366 */
			}
			t -= ((t1 = t / v) * v);

			if ((*vp == 7) && (t == v-1)) {
				--t;			/* Correct for 400th year leap case */
				++p[4];			/* Stash the extra day... */
			}

			if (v <= 60) {
				*p++ = t;
				t = t1;
			} else {
				*p++ = t1;
			}
		} while (*++vp);
	}

	if (p[-1] == 4) {
		--p[-1];
		t = 365;
	}

	*p += ((int) t);			/* result[7] .. tm_yday */
	p -= 2;						/* at result[5] */
	*p = ((((p[-2]<<2) + p[-1])*25 + p[0])<< 2) + (p[1] - 299); /* tm_year */
	p[1] = wday;				/* result[6] .. tm_wday */

	{
		register const unsigned char *d = _days;

		wday = 1900 + *p;
//		if (__isleap(wday)) {
//			d += 11;
//		}

		wday = p[2] + 1;		/* result[7] .. tm_yday */
		*--p = 0;				/* at result[4] .. tm_mon */
		while (wday > *d) {
			wday -= *d;
			if (*d == 29) {
				d -= 11;		/* Backup to non-leap Feb. */
			}
			++d;
			++*p;				/* Increment tm_mon. */
		}
		p[-1] = wday;			/* result[3] .. tm_mday */
	}
	p[4] = 0;					/* result[8] .. tm_isdst */
	//result->__tm_gmtoff = 0;
	//result->__tm_zone = utc_string;

	return result;
}

struct tm *localtime(const time_t *timer)
{
	register struct tm *ptm = &__time_tm;
	return _time_t2tm(timer, 0, ptm);
}

#define EMIT_CHAR_WITH_LENCHECK(C,DEST,MAX) do{if(DEST<MAX)*DEST=C;else goto done;}while(0)
int snprintf(char * buf, size_t size, const char * format, ...)
{
	char* lastchar = buf + size;
	va_list arg;
	int rv;

	va_start(arg, format);

	const char *p = format;
	char *d = buf;
	char pad = 0;
	int i;
	while (*p) {
		pad = 0;
		i = 0;
		if (*p == '%') {
			p++;
			if (*p == '0') {
				pad = '0';
				p++;
			} else if (*p > '0' && *p <= '9') {
				pad = ' ';
			}
			if (pad) {
				while (*p >= '0' && *p <= '9') {
					i = i*10 + (*p - '0');
					p++;
				}
			}
			if (*p == 's') {
				char *s = va_arg(arg, char*);
				if (!s) break;
				i -= strlen(s);
				while (i-- > 0) {
					EMIT_CHAR_WITH_LENCHECK(pad, d, lastchar);
					d++;
				}
				while (*s) {
					EMIT_CHAR_WITH_LENCHECK(*s, d, lastchar);
					d++;
					s++;
				}
				p++;
			} else if (*p == 'd') {
				int s = va_arg(arg, int);
				int x = 10;
				int j = 0;
				for (j=1;s>x;j++,x*=10);
				i -= j;
				while (i-- > 0) {
					EMIT_CHAR_WITH_LENCHECK(pad, d, lastchar);
					d++;
				}
				while (j--) {
					x/=10;
					EMIT_CHAR_WITH_LENCHECK((s/x+'0'), d, lastchar);
					d++;
					s%=x;
				}
				p++;
			}
		} else {
			EMIT_CHAR_WITH_LENCHECK(*p, d, lastchar);
			d++;
			p++;
		}
	}
done:
	*d = '\0';

	va_end(arg);
	return d-buf;
}

