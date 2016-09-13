#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "randomStream.h"
//#include <cuda.h>
extern "C" {

  __global__ void CudaPCG( uint64_t *state, uint64_t *inc , double* output){
    uint64_t oldstate = state[threadIdx.x + blockIdx.x * blockDim.x];
    // Advance internal state
    state[threadIdx.x + blockIdx.x * blockDim.x] = oldstate * 6364136223846793005ULL + (inc[threadIdx.x + blockIdx.x * blockDim.x]|1);
    // Calculate output function (XSH RR), uses old state for max ILP
    //uint32_t xorshifted = (((oldstate >> 18u) ^ oldstate) >> 27u);
    //uint32_t rot = (oldstate >> 59u);
    uint32_t buff = ((((oldstate >> 18u) ^ oldstate) >> 27u) >> (oldstate >> 59u)) | ((((oldstate >> 18u) ^ oldstate) >> 27u) << ((-(oldstate >> 59u)) & 31));
    output[threadIdx.x + blockIdx.x * blockDim.x] = (double)buff/(double)UINT32_MAX;
  }

  __global__ void CudaInitializeStates( uint64_t* state ){
    state[threadIdx.x + blockIdx.x * blockDim.x] = threadIdx.x + blockIdx.x * blockDim.x;
  }


  void reCalculateStream( randomStream* stream ){
    cudaMemcpy(stream->randoms, stream->devOutput, stream->size * sizeof(double), cudaMemcpyDeviceToHost);
    CudaPCG<<<stream->size/threads_per_block,threads_per_block>>>( stream->stateArray, stream->incArray, stream->devOutput );
    stream->used = 0;
  }

  double getRandom( randomStream* stream ){
    double toret;

    if (stream->size == stream->used +1 ){
      reCalculateStream( stream );
    }

    toret = stream->randoms[stream->used];
    stream->used++;
    return toret;
  }

  randomStream* createRandomStream( int size ){
    for(; size%threads_per_block != 0; size++);

    randomStream *stream = (randomStream*) malloc(sizeof(randomStream));
    stream->randoms = (double *)malloc(size*sizeof(double));
    stream->size = size;

    cudaMalloc((void **)&stream->stateArray, stream->size* sizeof(uint64_t));
    cudaMalloc((void **)&stream->devOutput, stream->size* sizeof(double));
    cudaMalloc((void **)&stream->incArray, stream->size* sizeof(uint64_t));

    CudaInitializeStates<<<stream->size/threads_per_block,threads_per_block>>>( stream->stateArray );
    CudaPCG<<<stream->size/threads_per_block,threads_per_block>>>( stream->stateArray, stream->incArray, stream->devOutput );
    CudaPCG<<<stream->size/threads_per_block,threads_per_block>>>( stream->stateArray, stream->incArray, stream->devOutput );
    reCalculateStream( stream );

    return stream;
  }


  void destroyStream( randomStream* stream ){
    free( stream->randoms );
    cudaFree( stream->stateArray );
    cudaFree( stream->incArray );
    cudaFree( stream->devOutput );
    free( stream );
  }
}
