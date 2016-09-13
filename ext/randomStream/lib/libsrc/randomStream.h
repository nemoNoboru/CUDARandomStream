#ifndef RANDOMSTREAM_H
#define RANDOMSTREAM_H

#ifdef __cplusplus
extern "C" {
#endif

// all of your legacy C code here

#endif
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

  #define threads_per_block 512

  typedef struct _randomStream {
    int used;
    int size;
    uint64_t* stateArray;
    uint64_t* incArray;
    double* randoms;
    double *devOutput;

  } randomStream;

  void reCalculateStream( randomStream* stream );
  double getRandom( randomStream* stream );
  randomStream* createRandomStream( int size );
  void destroyStream( randomStream* stream );

  #ifdef __cplusplus
}
#endif /* RANDOMSTREAM_H */
