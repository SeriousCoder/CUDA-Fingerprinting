#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "device_functions.h"
#include <stdio.h>
#include "constsmacros.h"
#include <stdlib.h>
#include <math.h>

#include "CUDAArray.cuh"
extern "C"
{ 
	__declspec(dllexport) float* Normalize(float* source, int imgWidth, int imgHeight, int bordMean, int bordVar);
}
__global__ void cudaCalcMeanRow(CUDAArray<float> source, float* meanArray)
{
	
	int row = defaultColumn();
	int height = source.Height;
	int width = source.Width;
	int tempIndex = threadIdx.x;
	
	__shared__ float* temp;
	temp = (float*)malloc(blockDim.x * sizeof(float));
	float mean = 0;
	if (source.Height > row)
	{
		for (int j = 0; j < source.Width; j++)
		{
			//mean += source.At(row, j) / (height * width);
			mean += source.cudaPtr[row*(source.Stride / sizeof(float)) + j] / (height * width);
		}
	}
	
	temp[tempIndex] = mean;
	__syncthreads();
	
	//This is reduction.It will work only if number of threads in the block is a power of 2.
	int i = blockDim.x / 2;
	while (i != 0)
	{
		if (tempIndex < i) 
			temp[tempIndex] += temp[tempIndex + i];
		__syncthreads();
		i /= 2;
	}
	if (tempIndex == 0) 
		meanArray[blockIdx.x] = temp[0];//we need to write it only one time. Why not to choose the first thread for this purpose?
		
}


float CalculateMean(CUDAArray<float> image)
{
	int height = image.Height;
	float *dev_mean, mean = 0;
	
	dim3 blockSize = dim3(defaultThreadCount);
	dim3 gridSize = dim3(ceilMod(height, defaultThreadCount));
	float* meanArray = (float*)malloc(gridSize.x * sizeof(float));
	cudaMalloc((void**)&dev_mean, gridSize.x * sizeof(float));

	cudaCalcMeanRow <<<gridSize, blockSize >>> (image, dev_mean);
	cudaMemcpy(meanArray, dev_mean, gridSize.x * sizeof(float), cudaMemcpyDeviceToHost);
	for (int i = 0; i < height; i++)
	{
		mean += meanArray[i];
	}
	return mean;
}

__global__ void cudaCalcVariationRow(CUDAArray<float> image, float mean, float* variationArray)
{

	int row = defaultColumn();
	int height = image.Height;
	int width = image.Width;
	int tempIndex = threadIdx.x;

	__shared__ float* temp;
	temp = (float*)malloc(blockDim.x * sizeof(float));
	float variation = 0;
	if (image.Height > row)
	{
		for (int j = 0; j < image.Width; j++)
		{
			variation += pow((image.cudaPtr[row*(image.Stride / sizeof(float)) + j] - mean), 2) / (height * width);
		}
	}
	temp[tempIndex] = variation;
	__syncthreads();
	//This is reduction.It will work only if number of threads in the block is a power of 2.
	int i = blockDim.x / 2;
	while (i != 0)
	{
		if (tempIndex < i)
			temp[tempIndex] += temp[tempIndex + i];
		__syncthreads();
		i /= 2;
	}
	if (tempIndex == 0)
		variationArray[blockIdx.x] = temp[0];//we need to write it only one time. Why not to choose the first thread for this purpose?
}

float CalculateVariation(CUDAArray<float> image, float mean)
{
	int height = image.Height;
	float *dev_variation, variation = 0;

	dim3 blockSize = dim3(defaultThreadCount);
	dim3 gridSize = dim3(ceilMod(height, defaultThreadCount));
	float* variationArray = (float*)malloc(gridSize.x * sizeof(float));
	cudaMalloc((void**)&dev_variation, gridSize.x * sizeof(float));

	cudaCalcVariationRow <<<gridSize, blockSize >>> (image, mean, dev_variation);
	cudaMemcpy(variationArray, dev_variation, gridSize.x * sizeof(float), cudaMemcpyDeviceToHost);
	for (int i = 0; i < height; i++)
	{
		variation += variationArray[i];
	}
	return variation;
}
__global__ void cudaDoNormalizationRow(CUDAArray<float> image, float mean, float variation, int bordMean, int bordVar)
{
	int row = defaultColumn();

	if (image.Height > row)
	{
		for (int j = 0; j < image.Width; j++)
		{
			//if (image.At(row, j) > mean)
			float at = image.cudaPtr[row*(image.Stride / sizeof(float)) + j];
			if (image.cudaPtr[row*(image.Stride / sizeof(float)) + j] > mean)
			{
				//image.SetAt(row, j, bordMean + sqrt((bordVar * pow(image.At(row, j) - mean, 2)) / variation));
				at = bordMean + sqrt((bordVar * pow(at - mean, 2)) / variation);
			}
			else
			{
				//image.SetAt(row, j, bordMean - sqrt((bordVar * pow(image.At(row, j) - mean, 2)) / variation));
				at = bordMean - sqrt((bordVar * pow(at - mean, 2)) / variation);
			}
		}
	}
}

CUDAArray<float> DoNormalization(CUDAArray<float> image, int bordMean, int bordVar)
{
	int height = image.Height;

	float mean = CalculateMean(image);
	float variation = CalculateVariation(image, mean);

	dim3 blockSize = dim3(defaultThreadCount);
	dim3 gridSize = dim3(ceilMod(height, defaultThreadCount));
	cudaDoNormalizationRow <<<gridSize, blockSize >>> (image, mean, variation, bordMean, bordVar);
	return image;
}
float* Normalize(float* source, int imgWidth, int imgHeight, int bordMean, int bordVar)
{
	CUDAArray<float> image = CUDAArray<float>(source, imgWidth, imgHeight);
	int height = image.Height;

	float mean = CalculateMean(image);
	float variation = CalculateVariation(image, mean);

	dim3 blockSize = dim3(defaultThreadCount);
	dim3 gridSize = dim3(ceilMod(height, defaultThreadCount));
	cudaDoNormalizationRow <<<gridSize, blockSize >>> (image, mean, variation, bordMean, bordVar);
	image.GetData(source);
	return source;
}
/*
void main()
{
}
*/