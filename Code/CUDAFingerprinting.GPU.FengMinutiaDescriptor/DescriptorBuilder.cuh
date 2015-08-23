#ifndef CUDAFINGERPRINTING_DESCRIPTORBUILDER
#define CUDAFINGERPRINTING_DESCRIPTORBUILDER

#include "MinutiaStructs.cuh"

__global__ void buildDescriptors(Minutia *mins, int pitch, int *minutiaNum, Descriptor *desc, int dbSize);

#endif