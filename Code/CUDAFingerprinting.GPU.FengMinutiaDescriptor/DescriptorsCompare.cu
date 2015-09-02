#include "cuda_runtime.h"
#include "MinutiaHelper.cuh"
#include <stdio.h>

//#include "device_launch_parameters.h"

__device__ void transformate(Descriptor* desc, /* float angle, float cosAngle, float sinAngle,*/ 
	Minutia center, Minutia* dst, int j)
{ 
	int dx = (*desc).minutias[j].x - (*desc).center.x;
	int dy = (*desc).minutias[j].y - (*desc).center.y;

	float angle = center.angle - (*desc).center.angle;

	float cosAngle = cos(angle);
	float sinAngle = sin(angle);

	int x = (int)round(dx * cosAngle + dy * sinAngle) + center.x;
	int y = (int)round(-dx * sinAngle + dy * cosAngle) + center.y;

	(*dst).angle = (*desc).minutias[j].angle + angle;
	normalizeAngle(&((*dst).angle));
	(*dst).x = x;
	(*dst).y = y;
}

__device__ void matchingPoints(Minutia min, Descriptor* desc, int* m, int* M, int width, int height)
{
	float eps = 0.1;

	*m = 0;
	*M = 0;

	int j = 0;
	bool isExist = false;
	while ((j < (*desc).length) && !isExist)
	{
		if ((sqrLength((*desc).minutias[j], min) < COMPARE_RADIUS*COMPARE_RADIUS)
			&& (abs((*desc).minutias[j].angle - min.angle) < eps))
		{
			isExist = true;
		}
		j++;
	}
	
	if (isExist)
	{
		*m = 1;
		*M = 1;
	}
	else
	{
		if ((sqrLength(min, (*desc).center) < FENG_CONSTANT * DESCRIPTOR_RADIUS * DESCRIPTOR_RADIUS) &&
			(min.x >= 0 && min.x < width && min.y >= 0 && min.y < height))
		{
				*M = 1; 
		}
	}
}

__global__ void compareDescriptors(Descriptor* input, Descriptor* current, int height, int width, int pitch, float* s,
	int inputNum, int* currentNum) ///block 128*2
{
	__shared__ int cache_m[MAX_DESC_SIZE][8];
	__shared__ int cache_M[MAX_DESC_SIZE][8];
	__shared__ Minutia temp[MAX_DESC_SIZE][8];
	
	for (int t = 32 * blockIdx.x; t < blockIdx.x + 32; t += 4)
	{
		int k = t + (threadIdx.y / 2);
			if (k < 100)
				for (int x = 0; x < inputNum; x++)
				{
					for (int j = 0; j < currentNum[k]; j++)
					{
						cache_m[threadIdx.x][threadIdx.y] = 0;
						cache_M[threadIdx.x][threadIdx.y] = 0;

						temp[threadIdx.x][threadIdx.y].x = 0;
						temp[threadIdx.x][threadIdx.y].y = 0;
						temp[threadIdx.x][threadIdx.y].angle = 0;

						int y = k*pitch + j;

						__syncthreads();

						if (threadIdx.y % 2 == 0 && threadIdx.x < input[x].length)
						{
							transformate(&input[x], current[y].center, &temp[threadIdx.x][threadIdx.y], threadIdx.x);

						}
						if (threadIdx.y % 2 == 1 && threadIdx.x < current[y].length)
						{
							transformate(&current[y], input[x].center, &temp[threadIdx.x][threadIdx.y], threadIdx.x);
						}
						__syncthreads();

						if (threadIdx.y % 2 == 0 && threadIdx.x < input[x].length)
						{
							matchingPoints(temp[threadIdx.x][threadIdx.y], &current[y], &cache_m[threadIdx.x][threadIdx.y],
								&cache_M[threadIdx.x][threadIdx.y], width, height);
						}
						if (threadIdx.y % 2 == 1 && threadIdx.x < current[y].length)
						{
							matchingPoints(temp[threadIdx.x][threadIdx.y], &input[x], &cache_m[threadIdx.x][threadIdx.y],
								&cache_M[threadIdx.x][threadIdx.y], width, height);
						}

						__syncthreads();

						int i = MAX_DESC_SIZE / 2;
						while (i != 0)
						{
							if (threadIdx.x < i)
							{
								cache_m[threadIdx.x][threadIdx.y] += cache_m[threadIdx.x + i][threadIdx.y];
							}
							else
							{
								cache_M[threadIdx.x - i][threadIdx.y] += cache_M[threadIdx.x][threadIdx.y];
							}

							__syncthreads();
							i /= 2;
						}

						if (threadIdx.x == 0 && threadIdx.y % 2 == 0)
						{
							s[k*MAX_DESC_SIZE*MAX_DESC_SIZE + x*MAX_DESC_SIZE + y] =
								(1.0 + cache_m[0][threadIdx.y]) * (1.0 + cache_m[0][threadIdx.y + 1])
								/ (1.0 + cache_M[0][threadIdx.y]) / (1.0 + cache_M[0][threadIdx.y + 1]);
						}
						__syncthreads();
					}
				}
	}
}



/*
__global__ void compareDescriptors(Descriptor* input, Descriptor* current, int height, int width, int pitch, float* s,
	int inputNum, int* currentNum) ///block 32*2 maybe warp size be better
{
	__shared__ int cache_m[MAX_DESC_SIZE][2];
	__shared__ int cache_M[MAX_DESC_SIZE][2];
	__shared__ Minutia temp[MAX_DESC_SIZE][2];

	int k = blockIdx.x;
	if (k < 10)
		for (int x = 0; x < inputNum; x++)
			for (int j = 0; j < currentNum[k]; j++)
			{
				int y = k*pitch + j;
				for (int t = 0; t < 4; t++)
				{
					int a = 4 * threadIdx.x + t;
					cache_m[a][threadIdx.y] = 0;
					cache_M[a][threadIdx.y] = 0;

					temp[a][threadIdx.y].x = 0;
					temp[a][threadIdx.y].y = 0;
					temp[a][threadIdx.y].angle = 0;

					

					__syncthreads();

					if (threadIdx.y == 0 && a < input[x].length)
					{
						transformate(&input[x], current[y].center, &temp[a][0], a);
					}
					if (threadIdx.y == 1 && a < current[y].length)
					{
						transformate(&current[k*pitch + y], input[x].center, &temp[a][1], a);
					}
					__syncthreads();

					if (threadIdx.y == 0 && a < input[x].length)
					{
						matchingPoints(temp[a][0], &current[y], &cache_m[a][0],
							&cache_M[a][0], width, height);
					}
					if (threadIdx.y == 1 && a < current[y].length)
					{
						matchingPoints(temp[a][1], &input[x], &cache_m[a][1],
							&cache_M[a][1], width, height);
					}

					__syncthreads();
				}

				int a = 4 * threadIdx.x;
				for (int t = 3; t > 0; t--)
				{
					cache_m[a][threadIdx.y] += cache_m[a + t][threadIdx.y];
					cache_M[a][threadIdx.y] += cache_M[a + t][threadIdx.y];
				}
				
				int i = MAX_DESC_SIZE / 2;
				while (i != 0)
				{
					if (a < i)
					{
						for (int t = 3; t > 0; t--)
						{
							cache_m[a][threadIdx.y] += cache_m[a + i + t][threadIdx.y];
						}
					}
					else
					{
						for (int t = 3; t > 0; t--)
						{
							cache_M[a - i][threadIdx.y] += cache_M[a + t][threadIdx.y];
						}
					}

					__syncthreads();
					i /= 2;
				}
				if (threadIdx.x == 0 && threadIdx.y == 0)
				{
						s[k*MAX_DESC_SIZE*MAX_DESC_SIZE + x*MAX_DESC_SIZE + y] =
							(1.0 + cache_m[0][0]) * (1.0 + cache_m[0][1]) / (1.0 + cache_M[0][0]) / (1.0 + cache_M[0][1]);

				}
				__syncthreads();
			}
}
	*/