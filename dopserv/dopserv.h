#define PR_TUNABLE_BUFFER_SIZE 1024
#define PR_TUNABLE_PATH_MAX 1024
#define PR_LOG_ERR "ERRRO: "
#define PR_LU "lu"
#define TRUE 1
#define FALSE 0

#ifdef BARE
#define puts(...)
#define printf(...)
#define fprintf(...)
#define pr_log_pri(prefix, msg)
#define pr_response_send_raw(...)
#define errquit(s) exit(1)
#else //BARE
#define pr_log_pri(prefix, msg) fprintf(stderr, prefix msg)
#define pr_response_send_raw printf
#define pr_fsio_gets fgets
#define pr_fsio_close fclose
#define errquit(s) do{puts(s "\n");exit(1);}while(0)
#endif //BARE

typedef struct server_struc {
  struct server_struc *next, *prev;

  const char *ServerName;
} server_rec;

typedef struct {
	char cwd[PR_TUNABLE_PATH_MAX];	/* Current working directory */

	off_t total_bytes_in;
	off_t total_bytes_out;
} session_t;


char *stdinread();
int pr_display_file(const char *code);
char *sreplace(char *s, ...);
const char *pr_strtime(time_t t);
char *sstrncpy(char *dest, const char *src, size_t n);
