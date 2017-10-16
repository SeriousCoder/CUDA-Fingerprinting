//#include "kernel.cuh"
//#include "cuda_runtime.h"
//#include <iostream>
//#include "device_launch_parameters.h"
//#include "device_functions.h"
//#include <stdio.h>
//#include "constsmacros.h"
//#include <stdlib.h>
//#include <math.h>
//#include "ImageLoading.cu"
////#include "CUDAArray.cuh"
//#include <float.h>
//#include "OrientationField.cu"
//#include "Convolution.cu"
//#include "time.h"
//
//#define M_PI 3.14159265358979323846
//
//Point NewPoint(int x, int y)
//{
//	Point newP;
//	newP.x = x;
//	newP.y = y;
//	return newP;
//}
//
//int countOfEndings;
//
//void AddMinutiae(Minutiae* minutiaes, Minutiae minutiae, int* indexOfMinutiae)
//{
//	minutiaes[*indexOfMinutiae] = minutiae;
//	(*indexOfMinutiae)++;
//	//printf("Added new minutia. Type = %d\n", minutiae.type);
//	if (minutiae.type == 1) countOfEndings++;
//}
//
//bool OutOfImage(int x, int y, float* image, int* width, int* height)
//{
//	//160 - 192; 320 - 352
//	return (x < 0) || (y < 0) || (x >= *width) || (y >= *height);
//}
//
//int NewSection(int x, int y, Direction direction, float* image, float* orientField,
//	Point* section, float* sectionAngle, int* centerSection, bool* flag,
//	int sizeOfSection, int* width, int* height)
//{
//	int countOfPixels = 0;
//
//	//printf("=+=+=+=+=+=+=+=+=+=\n");
//	//printf("Making new section from point (%d, %d)\n", x, y);
//
//	for (int i = 0; i < sizeOfSection; i++)
//	{
//		section[i].x = -1;
//		section[i].y = -1;
//	}
//
//	int wing = sizeOfSection / 2;
//
//	int lEnd = wing, rEnd = lEnd;
//	bool rightE = false, leftE = false;
//
//	float angle = -orientField[y * (*width) + x];
//	//printf("Angle in this pixel: %f\n", angle);
//	angle += (float)M_PI_2;
//
//	section[wing] = NewPoint(x, y);
//	countOfPixels++;
//
//	for (int i = 1; i <= wing; i++)
//	{
//		int xs = (int)(x - i * cos(angle));
//		int ys = (int)(y + i * sin(angle) + 0.95);
//		int xe = (int)(x + i * cos(angle) + 0.95);
//		int ye = (int)(y - i * sin(angle));
//
//		//printf("Left pixel = (%d, %d); right pixel = (%d, %d)\n", xs, ys, xe, ye);
//
//		if (!OutOfImage(xs, ys, image, width, height) && (image[ys * (*width) + xs] < 20) && !rightE)
//		{
//			section[wing - i] = NewPoint(xs, ys);
//			rEnd--;
//			countOfPixels++;
//		}
//		else
//		{
//			rightE = true;
//		}
//
//		if (!OutOfImage(xe, ye, image, width, height) && (image[ye * (*width) + xe] < 20) && !leftE)
//		{
//			section[wing + i] = NewPoint(xe, ye);
//			lEnd++;
//			countOfPixels++;
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
//	//printf("New center: (%d, %d)\n", x, y);
//
//	angle = -orientField[y * (*width) + x];
//	angle += (float) direction * M_PI;
//	if (angle < 0) angle += 2.0 * M_PI;
//
//	if (abs(*sectionAngle - angle) > 0.2 && abs(*sectionAngle - angle) < 6) angle += M_PI;
//	while (angle > 2.0 * M_PI) angle -= 2 * M_PI;
//
//	//printf("Old angle: %f\nNew angle: %f\n", *sectionAngle, angle);
//
//	*sectionAngle = angle;
//
//	//printf("=+=+=+=+=+=+=+=+=+=\n");
//
//	return countOfPixels;
//}
//
//bool MakeStep(int* x, int* y, float* image, float* sectionAngle, Point* section,
//	int* sectionCenter, int step, int* width, int* height)
//{
//	*x = section[*sectionCenter].x;
//	*y = section[*sectionCenter].y;
//
//	float dx = (float)*x + step * cos(*sectionAngle);
//	float dy = (float)*y - step * sin(*sectionAngle);
//
//	*x = (int)(dx >= 0 ? dx + 0.5 : dx - 0.5);
//	*y = (int)(dy >= 0 ? dy + 0.5 : dy - 0.5);
//
//	if (OutOfImage(*x, *y, image, width, height)) return true;
//
//	return false;
//}
//
//int steps;
//
//void Paint(float* image, bool* visited, Point* oldSection, Point* newSection,
//	int size, int* width, int* height)
//{
//	Point queue[400];
//	Point v1, v2;
//
//	int left = 0, right = 0;
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
//		visited[y2 * (*width) + x2] = true;
//		queue[right] = NewPoint(x2, y2);
//		right++;
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
//		if (newSection[i].x == -1) continue;
//
//		if (x1 == -1)
//		{
//			x1 = newSection[i].x;
//			y1 = newSection[i].y;
//		}
//
//		x2 = newSection[i].x;
//		y2 = newSection[i].y;
//
//		visited[y2 * (*width) + x2] = true;
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
//	while (abs(right - left) > 0)
//	{
//		for (int i = -2; i < 3; i++)
//			for (int j = -2; j < 3; j++)
//			{
//				if (i == 0 && j == 0) continue;
//
//				int x = queue[left].x + i;
//				int y = queue[left].y + j;
//
//				if (OutOfImage(x, y, image, width, height) || visited[y * (*width) + x] || image[y * (*width) + x] > 20) continue;
//
//				Point pointV1 = NewPoint(x_a - x, y_a - y);
//				Point pointV2 = NewPoint(x1 - x, y1 - y);
//
//				int skew1 = v1.x*pointV1.y - pointV1.x * v1.y >= 0 ? 1 : -1;
//				int skew2 = v2.x*pointV2.y - pointV2.x * v2.y >= 0 ? 1 : -1;
//
//				if (skew1*skew2 < 0)
//				{
//					queue[right] = NewPoint(x, y);
//					visited[y * (*width) + x] = true;
//					right++;
//					if (right == 400) right = 0;
//				}
//			} 
//
//		left++;
//		if (left == 400) left = 0;
//	}
//}
//
//void Paint2(float* image, bool* visited, Point* oldSection, float *sectionAngle,
//	int size, int* width, int* height)
//{
//	Point queue[40];
//
//	int rPointer = 0, lPointer = 0;
//
//	for (int i = 0; i < size; i++)
//	{
//		if (oldSection[i].x == -1) continue;
//
//		visited[oldSection[i].y * (*width) + oldSection[i].x] = true;
//		queue[rPointer] = oldSection[i];
//		rPointer++;
//	}
//
//	while (abs(rPointer - lPointer) > 0)
//	{
//		int x = queue[lPointer].x, y = queue[lPointer].y;
//
//		Point foo = NewPoint(x, y);
//		int bar = 0;
//
//		MakeStep(&x, &y, image, sectionAngle, &foo, &bar, 1, width, height);
//
//		for (int i = -1; i < 2; i++)
//			for (int j = -1; j < 2; j++)
//			{
//				if (OutOfImage(x + i, y + j, image, width, height)) continue;
//				if (image[(y + j) * (*width) + x + i] < 20 && !visited[(y + j) * (*width) + x + i])
//				{
//					visited[(y + j) * (*width) + x + i] = true;
//					queue[rPointer] = NewPoint(x + i, y + j);
//					rPointer++;
//					if (rPointer == 40) rPointer = 0;
//				}
//			}
//
//		lPointer++;
//		if (lPointer == 40) lPointer = 0;
//	}
//}
//
//MinutiaeType CheckStopCriteria(int x, int y, float* image, bool* visited, int* width, int threshold = 20)
//{
//	if (visited[y * (*width) + x])
//		return Intersection;
//
//	if (image[y * (*width) + x] > threshold)
//		return LineEnding;
//
//	return NotMinutiae;
//}
//
//void saveMyBmp_Paint(bool* visited, int index, int width, int height)
//{
//	int* img = (int*)malloc(width * height * sizeof(int));
//
//	for (int i = 0; i < height; i++)
//		for (int j = 0; j < width; j++)
//		{
//			if (visited[i * width + j]) img[i * width + j] = 255; else img[i * width + j] = 0;
//		}
//
//	char filename[80];
//	sprintf(filename, "res%d-%d.bmp", index, steps);
//
//	steps++;
//
//	saveBmp(filename, img, width, height);
//}
//
//int indexOfMinutiae = 0;
//
//void saveMyBmp(bool* visited, int* index, int width, int height)
//{
//	int* img = (int*)malloc(width * height * sizeof(int));
//
//	for (int i = 0; i < height; i++)
//		for (int j = 0; j < width; j++)
//		{
//			if (visited[i * width + j]) img[i * width + j] = 255; else img[i * width + j] = 0;
//		}
//
//	char filename[80];
//	sprintf(filename, "res%d-%d.bmp", indexOfMinutiae, *index);
//
//	saveBmp(filename, img, width, height);
//}
//
//
//void FollowLine(int x, int y, Direction direction, float* image, float* orientField,
//	bool* visited, Minutiae* minutiaes, Point* section, float* sectionAngle,
//	int* centerSection, bool* flag, int* sizeOfSection, int* step, int* width, 
//	int* height, int* indexOfMinutiae)
//{
//	int pixelsInSection = NewSection(x, y, direction, image, orientField, section,
//		sectionAngle, centerSection, flag, *sizeOfSection, width, height);
//	if (pixelsInSection == 1) return;
//
//	MinutiaeType type; steps = 0;
//	//int x, y;
//
//	Point* oldSection = new Point[*sizeOfSection];
//	bool outOfImage = false;
//
//	do
//	{
//		//printf("First/last section: \n");
//		for (int i = 0; i < *sizeOfSection; i++)
//		{
//			oldSection[i] = section[i];
//			//printf("(%d, %d) ", oldSection[i].x, oldSection[i].y);
//		}
//
//		//printf("\n");
//
//		outOfImage = MakeStep(&x, &y, image, sectionAngle, section, centerSection,
//			*step, width, height);
//
//		if (outOfImage)
//		{
//			Paint2(image, visited, oldSection, sectionAngle, *sizeOfSection, width, height);
//			return;
//		}
//
//		//printf("Step complited. New point: (%d, %d)\n", x, y);
//
//		type = CheckStopCriteria(x, y, image, visited, width);
//
//		NewSection(x, y, direction, image, orientField, section,
//			sectionAngle, centerSection, flag, *sizeOfSection, width, height);
//		if (section[*centerSection].x == -1)
//		{
//			Paint2(image, visited, oldSection, sectionAngle, *sizeOfSection, width, height);
//			return;
//		}
//
//		Paint(image, visited, oldSection, section, *sizeOfSection, 
//			width, height);
//		//saveMyBmp_Paint(visited, *indexOfMinutiae, *width, *height);
//	} while (type == NotMinutiae);
//
//	Minutiae newMinutiae;
//	newMinutiae.x = x;
//	newMinutiae.y = y;
//	newMinutiae.angle = *sectionAngle;
//	newMinutiae.type = type;
//
//	
//
//	AddMinutiae(minutiaes, newMinutiae, indexOfMinutiae);
//	
//	/*if (type == LineEnding) *///saveMyBmp(visited, indexOfMinutiae, *width, *height);
//}
//
//void FindMinutiae(float* image, float* orientField, bool* visited,
//	Minutiae* minutiaes, int sizeOfSection, int* width, 
//	int* height, int step, int colorThreshold = 20)
//{
//	Point* section = new Point[sizeOfSection];
//	float sectionAngle;
//	int centerSection;
//	bool flag = false;
//
//	int test = 0;
//
//	//160 - 192; 320 - 352
//	for (int i = 0; i < *width; i++)
//		for (int j = 0; j < *height; j++)
//		{
//			//On parallel version need add check out of image
//			if ((image[j * (*width) + i] >= colorThreshold) || (visited[j * (*width) + i]))
//				continue;
//
//			/*printf("================================================================\n");
//			printf("Starting point: (%d, %d)  //color = %f\n", i, j, image[j * (*width) + i]);
//			printf("     ***** Minutiae #%d *****     \n", indexOfMinutiae);
//			printf("Forward....\n");*/
//
//			sectionAngle = -orientField[j * (*width) + i];
//			if (sectionAngle < 0) sectionAngle += 2.0 * M_PI;
//			FollowLine(i, j, Forward, image, orientField, visited, minutiaes,
//				section, &sectionAngle, &centerSection, &flag, &sizeOfSection,
//				&step, width, height, &indexOfMinutiae);
//
//			flag = false;
//
//			/*printf("-----------------------------\n");
//			printf("     ***** Minutiae #%d *****     \n", indexOfMinutiae);
//			printf("Back....\n");*/
//			sectionAngle = -orientField[j * (*width) + i] + M_PI;
//			//if (sectionAngle > 2.0 * M_PI) sectionAngle -= M_PI;
//			FollowLine(i, j, Back, image, orientField, visited, minutiaes,
//				section, &sectionAngle, &centerSection, &flag, &sizeOfSection,
//				&step, width, height, &indexOfMinutiae);
//		}
//
//	//printf("Finded minutiaes: %d\n", indexOfMinutiae);
//}
//
//bool Start(Minutiae* minutiaeOut, float* source, int step, int lengthWings, int width, int height)
//{
//	/*DEBUG*/
//	//freopen("OUTPUT.log", "w", stdout);
//
//	int time = clock();
//
//	countOfEndings = 0;
//
//	bool* visited = (bool*)calloc(width * height, sizeof(bool));
//	int countOfMinutiae = 0;
//
//	float* orientFieldin = OrientationFieldInPixels(source, width, height);
//
//	/*printf("Angles:\n");
//	for (int i = 0; i < width; i++) {
//		for (int j = 0; j < height; j++)
//		{
//			if (source[j * width + i] < 15)
//				printf("%f ", orientFieldin[j * (width)+i]);
//			else
//				printf("0.000000 ", orientFieldin[j * (width)+i]);
//		}
//		printf("\n");
//	}*/
//
//	FindMinutiae(source, orientFieldin, visited, minutiaeOut, lengthWings * 2 + 1, &width, &height, step);
//
//	//minutiaeOut = minutiaes;
//
//	//printf("Endings: %d", countOfEndings);
//
//	DeleteDuplicate(minutiaeOut);
//
//	printf("Time: %d", clock() - time);
//
//	return false;
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
////	printf("Need path to file");
////	return 0;
////	}*/
////	char* filename = "H:\\GitHub\\CUDA-Fingerprinting\\Code\\CUDAFingerprinting.GPU.RidgeLine\\res.bmp";  //Write your way to bmp file
////	int* img = loadBmp(filename, &width, &height);
////	float* source = (float*)malloc(height*width*sizeof(float));
////	for (int i = 0; i < height; i++)
////		for (int j = 0; j < width; j++)
////		{
////			source[(height - i - 1) * width + j] = (float)img[i * width + j];
////		}
////
////	//Minutiae* foo = (Minutiae*)malloc(sizeof(Minutiae) * width * height);
////
////	float* orientField = OrientationFieldInPixels(source, width, height);
////	Minutiae* minutiaes = (Minutiae*)calloc(width * height, sizeof(Minutiae));
////
////	/*for (int i = 0; i < width; i++)
////		printf("%f\n", orientField[30 * (width) + i]);*/
////
////	Start(minutiaes, source, 2, 3, width, height);
////
////	/*for (int i = 0; i < height; i++)
////	for (int j = 0; j < width; j++)
////	{
////	img[i * width + j] = res[i * width + j] ? 255 : 0;
////	}
////*/
////
////
////	//saveBmp("..\\rez.bmp", img, width, height);
////
////	return 0;
////}