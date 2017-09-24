//#include "kernel.cuh"
//#include "cuda_runtime.h"
#include <iostream>
//#include "device_launch_parameters.h"
//#include "device_functions.h"
//#include <stdio.h>
//#include "constsmacros.h"
#include <stdlib.h>
//#include <math.h>
//#include "ImageLoading.cu"
////#include "CUDAArray.cuh"
//#include <float.h>
//#include "OrientationField.cu"
//#include "Convolution.cu"
//
//#define M_PI 3.14159265358979323846
//#define Pi4 (M_PI / 4)
//
//__device__ __host__
//Point NewPoint(int x, int y)
//{
//	Point newP;
//	newP.x = x;
//	newP.y = y;
//	return newP;
//}
//
//__device__ void AddMinutiae(CUDAArray<Minutiae>* minutiaes, Minutiae minutiae, int* indexOfMinutiae)
//{
//	minutiaes->SetAt(0, *indexOfMinutiae, minutiae);
//	*indexOfMinutiae += 1;
//}
//
//__device__ bool OutOfImage(CUDAArray<float> image, int x, int y, int partX, int partY)
//{
//	return (x < 0) || (y < 0) || (y >= image.Width) || (x >= image.Height);
//	//return (x < blockIdx.x * partX) || (y < blockIdx.y * partY) || (x >= (blockIdx.x + 1) * partX) || (y >= (blockIdx.y + 1) * partY) || (y >= image.Width) || (x >= image.Height);
//}
//
//__device__ void NewSection(int x, int y, Direction direction, CUDAArray<float> image, CUDAArray<float> orientationField, 
//	Point* section, float* sectionAngle, int* centerSection, bool* flag, int size, int partX, int partY)
//{
//	int lengthWings = size / 2;
//
//	for (int i = 0; i < size; i++)
//	{
//		section[i] = NewPoint(-1, -1);
//
//	}
//
//	int lEnd = lengthWings;
//	int rEnd = lEnd;
//
//	bool rightE = false;
//	bool leftE = false;
//
//	float angle = -orientationField.At(y, x);
//	angle += M_PI_2;
//
//	section[lengthWings] = NewPoint(x, y);
//
//	for (int i = 1; i <= lengthWings; i++)
//	{
//		int xs = (int)(x - i * cos(angle));
//		int ys = (int)(y + i * sin(angle) + 0.95);
//		int xe = (int)(x + i * cos(angle) + 0.95);
//		int ye = (int)(y - i * sin(angle));
//
//		if (!OutOfImage(image, xs, ys, partX, partY) && (image.At(ys, xs) < 20) && !rightE)
//		{
//			section[lengthWings - i] = NewPoint(xs, ys);
//			rEnd--;
//		}
//		else
//		{
//			rightE = true;
//		}
//
//		if (!OutOfImage(image, xe, ye, partX, partY) && (image.At(ye, xe) < 20) && !leftE)
//		{
//			section[lengthWings + i] = NewPoint(xe, ye);
//			lEnd++;
//		}
//		else
//		{
//			leftE = true;
//		}
//
//		*centerSection = (lEnd + rEnd) / 2;
//	}
//
//	x = section[*centerSection].x;
//	y = section[*centerSection].y;
//
//	angle = -orientationField.At(y, x);
//	angle += (float) direction * M_PI;
//	if (angle < 0) angle += 2.0 * M_PI;
//
//	if (abs(*sectionAngle - angle) > 0.2 && abs(*sectionAngle - angle) < 6) angle += M_PI;
//	while (angle > 2.0 * M_PI) angle -= 2 * M_PI;
//
//	*sectionAngle = angle;
//}
//
//
//
//__device__ bool CheckAndDeleteFalseMinutia(Minutiae minutia)
//{
//	return false;
//}
//
//__device__ void MakeStep(int* x, int* y, CUDAArray<float> image, Point* section, int* centerSection, float* sectionAngle, int step, int partX, int partY)
//{
//	*x = section[*centerSection].x;
//	*y = section[*centerSection].y;
//
//	float dx = (float)*x + (float)step * cos(*sectionAngle);
//	float dy = (float)*y - (float)step * sin(*sectionAngle);
//
//	*x = (int)(dx >= 0 ? dx + 0.5 : dx - 0.5);
//	*y = (int)(dy >= 0 ? dy + 0.5 : dy - 0.5);
//
//	if (OutOfImage(image, *x, *y, partX, partY))
//	{
//		*x = -1;
//		*y = -1;
//	}
//}
//
//__device__ MinutiaeType CheckStopCriteria(int x, int y, CUDAArray<float> image, CUDAArray<bool> visited, int threshold = 20)
//{
//	if (visited.At(y, x))
//		return Intersection;
//	if (image.At(y, x) > threshold)
//		return LineEnding;
//
//	return NotMinutiae;
//}
//
//__device__ void Paint(CUDAArray<float> image, CUDAArray<bool> visited, Point* oldSection, Point* section, int size, int partX, int partY)
//{
//	Point queue[40];
//
//	int shift = 0; // 30 * (blockIdx.x * gridDim.x + blockIdx.y);
//	int rPointer = 0, lPointer = 0;
//	//queue = (Point*)malloc(32 * 32 * sizeof(Point));
//	Point v1, v2;
//
//	int x1 = -1, x2 = -1, y1 = -1, y2 = -1, x_a, y_a;
//
//	for (int i = 0; i < size; i++)
//	{
//		if (oldSection[i].x == -1) continue;
//
//		if (x1 == -1)
//		{
//			x1 = oldSection[i].x;
//			y1 = oldSection[i].y;
//		}
//
//		x2 = oldSection[i].x;
//		y2 = oldSection[i].y;
//
//		visited.SetAt(y2, x2, true);
//		queue[shift + rPointer] = oldSection[i];
//		rPointer++;
//	}
//
//	v1 = NewPoint(x2 - x1, y2 - y1);
//	x_a = x1;
//	y_a = y1;
//
//	x1 = -1;
//	y1 = -1;
//	x2 = -1;
//	y2 = -1;
//
//	for (int i = 0; i < size; i++)
//	{
//		if (section[i].x == -1) continue;
//
//		if (x1 == -1)
//		{
//			x1 = section[i].x;
//			y1 = section[i].y;
//		}
//
//		x2 = section[i].x;
//		y2 = section[i].y;
//
//		visited.SetAt(y2, x2, true);
//	}
//
//	v2 = NewPoint(x2 - x1, y2 - y1);
//
//	if (v1.x*v2.x + v1.y*v2.y < 0)
//	{
//		x1 = x2;
//		y1 = y2;
//		v1.x = -v1.x;
//		v1.y = -v1.y;
//	}
//
//	while (abs(rPointer - lPointer) > 0)
//	{
//		for (int i = -2; i < 3; i++)
//			for (int j = -2; j < 3; j++)
//			{
//				if (i == 0 && j == 0) continue;
//
//				int x = queue[lPointer].x + i;
//				int y = queue[lPointer].y + j;
//
//				if (OutOfImage(image, x, y, partX, partY) || visited.At(y, x) || image.At(y, x) > 20) continue;
//
//				Point pointV1 = NewPoint(x_a - x, y_a - y);
//				Point pointV2 = NewPoint(x1 - x, y1 - y);
//
//				int skew1 = v1.x*pointV1.y - pointV1.x*v1.y >= 0 ? 1 : -1;
//				int skew2 = v2.x*pointV2.y - pointV2.x*v2.y >= 0 ? 1 : -1;
//
//				if (skew1*skew2 < 0)
//				{
//					queue[shift + rPointer] = NewPoint(x, y);
//					rPointer++;
//					visited.SetAt(y, x, true);
//					if (rPointer == 40) rPointer = 0;
//				}
//			}
//
//		lPointer++;
//		if (lPointer == 40) lPointer = 0;
//	}
//}
//
//__device__ void FollowLine(int x, int y, Direction direction, CUDAArray<float> image, CUDAArray<float> orientationField,
//	CUDAArray<bool> visited, CUDAArray<Minutiae> minutiaes,	Point* section, float* sectionAngle, 
//	int* centerSection, bool* flag, int size, int step, int partX, int partY, int* indexOfMinutiae)
//{
//	NewSection(x, y, direction, image, orientationField, section, sectionAngle, 
//		centerSection, flag, size, partX, partY);
//	if (section[*centerSection].x == -1) return;
//
//	MinutiaeType type;
//
//	Point* oldSection = new Point[size];
//
//	do
//	{		
//		for (int i = 0; i < size; i++){
//			oldSection[i] = section[i];
//		}
//
//		MakeStep(&x, &y, image, section, centerSection, sectionAngle, step, partX, partY);
//		
//		if (x == -1) return;
//
//		NewSection(x, y, direction, image, orientationField, section, sectionAngle, centerSection, flag, size, partX, partY);
//		if (section[*centerSection].x == -1) return;
//
//		type = CheckStopCriteria(x, y, image, visited);
//
//		Paint(image, visited, oldSection, section, size, partX, partY);
//	} while (type == NotMinutiae);
//
//	Minutiae possMinutiae;
//	possMinutiae.x = x;
//	possMinutiae.y = y;
//	possMinutiae.angle = *sectionAngle;
//	possMinutiae.type = type;
//
//	//printf("Minutia. x = %d y = %d type = %d\n", possMinutiae.x, possMinutiae.y, possMinutiae.type);
//
//	//if (IsDuplicate(possMinutiae)) return;
//
//	if (!CheckAndDeleteFalseMinutia(possMinutiae))
//	{
//		//printf("Minutia. x = %d y = %d type = %d\n", possMinutiae.x, possMinutiae.y, possMinutiae.type);
//		AddMinutiae(&minutiaes, possMinutiae, indexOfMinutiae);
//		//printf("%d %d: minutiae detected. x = %d; y = %d; type = %d\n", blockIdx.x, blockIdx.y, possMinutiae.x, possMinutiae.y, possMinutiae.type);
//	}
//}
//
//__global__ void FindMinutia(CUDAArray<float> image, CUDAArray<float> orientationField, CUDAArray<bool> visited,
//	CUDAArray<Minutiae> minutiaes, const int size, const int step, int colorThreshold = 15)
//{
//	Point* section = new Point[size];
//	float sectionAngle;
//	int centerSection;
//	bool flag  = false;
//
//	int partX = 32; //image.Height / gridDim.x;
//	int partY = 32; //image.Width / gridDim.y;
//
//	int indexOfMinutiae = 0; // blockIdx.x * image.Height + blockIdx.y * defaultThreadCount;
//
//	//printf("%d %d %d\n", blockIdx.x, blockIdx.y, threadIdx.x);
//
//	//if (blockIdx.x == 7 && blockIdx.y == 7)
//	//for (int i = blockIdx.x * partX; i < (blockIdx.x + 1) * partX; i++)
//	//	for (int j = blockIdx.y * partY; j < (blockIdx.y + 1) * partY; j++)
//	for (int i = 0; i < image.Width; i++)
//		for (int j = 0; j < image.Height; j++)
//		{
//			if (OutOfImage(image, i, j, partX, partY))
//			{
//				//printf("Tu-tu. %d %d\n", i, j);
//				continue;
//			}
//
//			if ((image.At(j, i) >= colorThreshold) || visited.At(j, i)) continue;
//			
//			sectionAngle = -orientationField.At(j, i);
//			if (sectionAngle < 0) sectionAngle += 2.0 * M_PI;
//			FollowLine(i, j, Forward, image, orientationField, visited, minutiaes, 
//				section, &sectionAngle, &centerSection, &flag, size, step, partX, partY, &indexOfMinutiae);
//
//			flag = false;
//
//			sectionAngle = -orientationField.At(j, i) + M_PI;
//			FollowLine(i, j, Back, image, orientationField, visited, minutiaes, 
//				section, &sectionAngle, &centerSection, &flag, size, step, partX, partY, &indexOfMinutiae);
//		}
//
//	printf("Finded minutiaes: %d\n	", indexOfMinutiae);
//
//	//printf("%d %d: Lets look i = %d; j = %d \n", blockIdx.x, blockIdx.y, i, j);
//}
//
//bool Start(Minutiae* minutias, float* source, int step, int lengthWings, int width, int height)
//{
//	int sizeSection = lengthWings * 2 + 1;
//
//	CUDAArray<float> image = CUDAArray<float>(source, width, height);
//
//	dim3 blockSize = 1;
//	dim3 gridSize = 1; // dim3(ceilMod(image.Height, defaultThreadCount), ceilMod(image.Width, defaultThreadCount));
//
//	CUDAArray<float> orientationField = CUDAArray<float>(OrientationFieldInPixels(source, width, height), width, height);
//	CUDAArray<bool> visited = CUDAArray<bool>((bool*)calloc(width * height, sizeof(bool)), width, height);
//	CUDAArray<Minutiae> minutiaes = CUDAArray<Minutiae>((Minutiae*)calloc(width * height, sizeof(Minutiae)), width * height, 1);
//
//	FindMinutia << <gridSize, blockSize >> > (image, orientationField, visited, minutiaes, sizeSection, step);
//	cudaDeviceSynchronize();
//	cudaError_t e = cudaGetLastError(); 
//	if (e != cudaSuccess) {
//		printf("Cuda failure %s:%d: '%s'\n", __FILE__, __LINE__, cudaGetErrorString(e));
//		exit(0);
//	}
//
//	//CountOfMinutiaes(countOfMinutiae.GetData(), gridSize.x * gridSize.y);
//
//	//return visited.GetData();
//
//	/*ListOfMinutiae** notProcessedPools = minutiaes.GetData();
//
//	return Parsing(MergeMinutiaePools(notProcessedPools));*/
//
//	minutiaes.GetData(minutias);
//	return visited.GetData();
//}
//
//void outputToFile()
//{
//	freopen("OUTPUT.log", "w", stdout);
//}
//
////int main(int argc, char *argv[])
////{
////	/*DEBUG*/
////	freopen("OUTPUT.log", "w", stdout);
////
////
////	int width;
////	int height;
////	/*if (argc != 2)
////	{
////		printf("Need path to file");
////		return 0;
////	}*/
////	char* filename = "H:\\GitHub\\CUDA-Fingerprinting\\Code\\CUDAFingerprinting.GPU.RidgeLine\\res.bmp";  //Write your way to bmp file
////	int* img = loadBmp(filename, &width, &height);
////	float* source = (float*)malloc(height*width*sizeof(float));
////	for (int i = 0; i < height; i++)
////		for (int j = 0; j < width; j++)
////		{
////			source[i * width + j] = (float)img[i * width + j];
////		}
////
////	Minutiae* foo = (Minutiae*)malloc(sizeof(Minutiae) * width * height);
////
////	bool* res = Start(foo, source, 2, 3, width, height);
////	
////	for (int i = 0; i < height; i++)
////		for (int j = 0; j < width; j++)
////		{
////			img[i * width + j] = res[i * width + j] ? 255 : 0;
////		}
////
////
////
////	saveBmp("..\\rez.bmp", img, width, height);
////
//// 	return 0;
////}
