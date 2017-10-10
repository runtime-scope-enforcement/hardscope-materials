#include "malloc.h"

#define BLOCKSIZE 128
#define HEAP_TOTAL (TOTAL_DATA_SIZE*10)
#define BITMAP_SIZE_BITS (HEAP_TOTAL/BLOCKSIZE)
#define BITMAP_SIZE (BITMAP_SIZE_BITS/sizeof(int))

ee_u8 static_memblk[HEAP_TOTAL];
static int bitmap[BITMAP_SIZE] = {0};
static size_t start = 0;
static size_t end = 0;

void *portable_malloc_1(ee_size_t size) {
  void *a;
  if (start + size >= HEAP_TOTAL) {
    abort();
  }
  a = static_memblk + start;
  start += size;
  return a;
}

void portable_free(void *ptr) {
//haha yea
}
