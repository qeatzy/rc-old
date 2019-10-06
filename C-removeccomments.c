/* Author:  qeatzy
 * Create:  2018-11-29
 * Revision:2018-11-30
 * state:   final. tested with cpython code, work correctly and fast, need some documation.
 *                  see C-removeccomments_stream.c for an failed improvement.
 */ 
#include <stdio.h>
#include <unistd.h> // read

#define SEGSIZE 4096
#define BUFSIZE ((int)1e6)
char filebuf[BUFSIZE];
#define MAXLINECOUNT ((int)5e5)
struct {
    char /*atest*/ *p;
    int n;
} lines[MAXLINECOUNT];

#ifndef DEBUG
#define pf(...) ;
#define pline(xxx,yyy) ;
#else
#define pf printf
void pline(const char *ptr, int len) {
    if (ptr == NULL) { puts("empty line"); return; }
    for (int i = 0; i < len; i++) putchar(ptr[i]);
    putchar('\n');
}
#endif

int readfile(int fd, char **filebuf) {
    if (filebuf == NULL || *filebuf == NULL) return 0;
    int total = 0, n;
    char *buf = *filebuf;
    /* while ((n = fread(buf,1,SEGSIZE,stream)) > 0) { */
    while ((n = read(fd,buf,SEGSIZE)) > 0) {
        total += n, buf += n;
        if (total > BUFSIZE) {
            fprintf(stderr, "error: file larger %d\n", BUFSIZE);
            return -1;
        }
    }
    return total;
}

int match_quote(const char *ptr, int *pos, int len) {
    /* pf("match_quote: pos,len = %d %d\n", *pos, len); */
    int ret = 0, j = *pos;
    while (j < len) {
        while (ptr[j] != '"' && j < len) j++;
        if (j < len) {
            j++;
            if (ptr[j-2] == '\\') continue;
            else { ret = 1; break; }
        }
    }
    *pos = j;
    /* if (ret) pf("match_quote succeeded\n"); */
    return ret;
}

int match_cms(const char *ptr, int *pos, int len) {
    /* pf("match_cms: pos,len = %d %d\n", *pos, len); */
    int ret = 0, j = (*pos < len ? *pos + 1 : *pos);    // "/*/" not, "/**/" valid
    while (j < len) {
        while (ptr[j] != '/' && j < len) j++;
        if (j < len) {
            j++;
            if (ptr[j-2] == '*') { ret = 1; break; }
            else continue;
        }
    }
    *pos = j;
    /* if (ret) pf("match_cms succeeded\n"); */
    return ret;
}

int splittolines(char *buf, int total) {
    pf("splittolines: total = %d\n", total);
    if (buf == NULL || total <= 0) { return 0; }
    int n = 0, i, prev = -1;
    int flag_quote = 0, flag_cms = 0, flag_ccms = 0;
    buf[total] = '\n';
    for (i = 0; i < total; i++, n++) {
        char *ptr = buf + i;
        /* if (i != 0 && ptr[-1] != '\n') pf("ptr error\n"); */
        int j = 0, start, len, cms = -1;
        while (ptr[j] <= ' ' && ptr[j] != '\n' && ptr[j] != '\r') j++;  // remove leading space
        len = start = j;
        while (ptr[len] != '\n' && ptr[len] != '\r') len++;
        lines[n].p = ptr;
        lines[n].n = len;
        char sout[16]; sprintf(sout,"%2d %2d %2d", n+1, start, len);
        /* pf("%s ",sout); pline(lines[n].p, lines[n].n); */
        // start processing
        if (prev != -1) {            // previous line continue, prev != -1
            if (flag_quote) {
                if (match_quote(ptr, &j, len)) flag_quote = 0;
            }
            if (flag_ccms) {
                lines[n].p = NULL;
                j = len;
            }
        }
        if (flag_cms) {
            if (match_cms(ptr, &j, len)) {
                flag_cms = 0;
                ptr += j, len -= j, j = 0;    // remove leading C-style comment
                while (ptr[j] <= ' ' && j < len) j++;   // remove leading space after that
                start = j;
            } else lines[n].p = NULL; 
        }
            pf("last char %c prev,len = %d %d n+1 = %d\n", ptr[len-1], prev,len,n+1);
        if ((ptr[len-1] == '\\') && (len > 0)) {  // current line continue, set prev != -1
            prev = n;
        } else {
            prev = -1;
        }
            pf("last char %c prev,len = %d %d n+1 = %d\n", ptr[len-1], prev,len,n+1);
        i = (ptr + len) - buf;
        if (buf[i] == '\r' && buf[i+1] == '\n') i++;
        while (len > 0 && ptr[len-1] <= ' ') len--; // remove trailing space
            /* pf("j,len,%d %d\n", j, len); */
        /* pf("%s ",sout); pline(lines[n].p, lines[n].n); */
        while (j < len) { // all 3 flag cleared, processing remain part of line
            /* pf("j,len,%d %d\n", j, len); */
            while (ptr[j] != '"' && ptr[j] != '/' && j < len) j++;
            if (ptr[j] == '"') {
                j++;
                if (match_quote(ptr, &j, len)) continue;
                else { flag_quote = 1; break; }
            }
            if (ptr[j] == '/') {
                j++;
                if (n+1 == 41) pline(ptr+start,len-start);
                if (ptr[j] == '*') {
                    flag_cms = j;
                    j++;
                    if (match_cms(ptr, &j, len)) flag_cms = 0, cms = j;
                    else {
                        break;
                    }
                } else if (ptr[j] == '/') {
                    /* if (n+1 == 13) pf("start,j = %d %d  ^%c%c.*%c$ \n", start,j,ptr[start],ptr[start+1],ptr[len-1]); */
                    if (j == start + 1) { lines[n].p = NULL; }
                    flag_ccms = 1; break;
                }
            }
        }
        if (ptr[start] == '/' && ptr[start+1] == '*') {
            if (flag_cms || (j == len)) { lines[n].p = NULL; }
        } else if (flag_cms) { len = flag_cms - 1; }    // remove trailing C style comment
        if (lines[n].p != NULL) lines[n].p = ptr;
        if (prev == -1) {
            flag_quote = 0; // C string cannot span mutli-line
            flag_ccms = 0;  // so is C++ style comment
        }
        if (n+1 > 0) pf("flags.{q,c,cc} %d %d %d prev = %d\n",flag_quote,flag_cms,flag_ccms, prev);
        lines[n].n = len;
        pf("%s ",sout); pline(lines[n].p, lines[n].n);
    }
    return n;
}

/*
if previous line not continue,
   has a unmatching / *, find matching * /
if previous line continue,
   has a unmatching ", find matching "
   has a unmatching / *, find matching * /
   previous line is //, also //
after this processing, 
      either entrie line processed, and proceed to next line.
      or remain part of line, and all 3 flag been cleared, and previous line not matter.
*/

/* void printlines(int n) { */
/*     pf("printlines: n = %d\n", n); */
/*     for (int i = 0; i < n; i++) { */
/*         if (lines[i].p == NULL) { putchar('\n'); continue; } */
/*         lines[i].p[lines[i].n] = 0; */
/*         #<{(| printf("%2d %2d %s\n", i+1, lines[i].n, lines[i].p); |)}># */
/*         puts(lines[i].p); */
/*     } */
/* } */

void printlines(int n) {
    pf("printlines: n = %d\n", n);
    int empty = 1;  // 1 instead of 0 to do not print empty lines at start
    for (int i = 0; i < n; i++) {
        if (lines[i].p == NULL || lines[i].n == 0) { if (empty == 0) { putchar('\n');} empty = 1; continue; }
        empty = 0; lines[i].p[lines[i].n] = 0;
        puts(lines[i].p);
        /* printf("%2d %2d %s\n", i+1, lines[i].n, lines[i].p); */
    }
}

int main() {
    char *buf = filebuf;
    int total = readfile(0, &buf);
    /* fwrite(buf,1,SEGSIZE,stdout); */
    int n = splittolines(buf, total);
    printlines(n);
}

/* ! gcc -O3 % -o ~/.vim/removeccomments */
/* ll ~/.vim/removeccomments */
/* ## behavior: */
/* 1. C style comment that span multi-line or occupy entire line gets zeroed out. */
/* 2. C style comment in the middle of a line remain unchanged. eg, `void init(#<{(| do initialization |)}>#) {...}` */
/* 3. C++ style comment that occupy entire line gets zeroed out. */
/* 4. C string literal being respected, via checking `"` and `\"`. */
/* 5. handles line-continuation. If previous line ending with `\`, current line is part of previous line. */
/* 6. line number remain the same. Zeroed out lines or part of line become empty.: */
/* ## testing & profiling: */
/* I tested with two largest cpython source code that contains many comments. Below is sorted output of:: */
/*     cd ~/code/cpython && wc $(find . -regex '.*\.[hc]\(pp\)?') | sort -g */
/*      14075    38036   370246 ./Modules/posixmodule.c */
/*      15702    47118   465001 ./Objects/unicodeobject.c */
/*      28377   421265  2100240 ./Modules/unicodename_db.h */
/*     556670  2125917 19079596 total     3.8.0a0 2018-11-30: */
/* in this case it do the job **correctly** and fast, **2-5 faster** than gcc: */
/*     time gcc -fpreprocessed -dD -E Modules/unicodeobject.c > res.c 2>/dev/null */
/*         # https://stackoverflow.com/questions/2394017/remove-comments-from-c-c-code */
/*     time ./removeccomments < Modules/unicodeobject.c > result.c */
/* ## install: */
/*     gcc -O3 removeccomments.c -o dest_path_name */
/* ## usage: */
/*     /path/to/removeccomments < input_file > output_file */
/* ## summary: */
/* - this program correctly remove comments in C source code, handling C string */
/* literal and line-continuation.: */
/* - do not add or delete lines, only empty lines that are comment. Output of `diff old new` is minimal. */
/* '{+,.-w !sed -e 's/:$/\n/'  > ~/code/repo/removeccomments/README.md */
/* !cp % ~/code/repo/removeccomments/removeccomments.c */
/* cd ~/code/repo/removeccomments && git add . && git ci --amend && git push -f */
/* promotion https://stackoverflow.com/a/53551634/3625404 */

// vim:cms=//%s:
    /* nn <buffer> <space>r :<C-u>!./%:r < %<CR> */
    /* nn <buffer> <space>r :<C-u>!./%:r < % >res.c&<CR> */
    /* nn <buffer> <space>r :<C-u>!./%:r < removeccomments.c >result&<CR> */
/* 39 https://stackoverflow.com/questions/241327/python-snippet-to-remove-c-and-c-comments */
/* 61 https://stackoverflow.com/questions/2394017/remove-comments-from-c-c-code */
/* 5  https://stackoverflow.com/questions/22858681/in-vim-how-to-remove-all-the-c-and-c-comments */
/* below test with cpython source code  */
  /*  14075    38036   370246 ./Modules/posixmodule.c */
  /*  15702    47118   465001 ./Objects/unicodeobject.c */
  /*  28377   421265  2100240 ./Modules/unicodename_db.h */
  /* 556670  2125917 19079596 total     3.8.0a0 2018-11-30 */
/* time gcc -fpreprocessed -dD -E Modules/posixmodule.c > res.c 2>/dev/null */
/* time ./xx < Modules/posixmodule.c > result.c */
/* time gcc -fpreprocessed -dD -E Objects/unicodeobject.c > res.c 2>/dev/null */
/* time ./xx < Objects/unicodeobject.c > result.c */
