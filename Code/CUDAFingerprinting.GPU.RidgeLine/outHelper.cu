#include "kernel.cuh"
#include <stdlib.h>
#include <iostream>

int* _x;
int* _y;
int* _mType;
float* _angle;

__host__
bool Parsing(Minutiae* minutiaeList, int size)
{
	printf("Try to parse\n");

	_x = (int*)malloc(sizeof(int)*size);
	_y = (int*)malloc(sizeof(int)*size);
	_mType = (int*)malloc(sizeof(int)*size);
	_angle = (float*)malloc(sizeof(float)*size);

	int i = 0;

	for (int i = 0; i < size; i++)
	{
		_x[i] = minutiaeList[i].x;
		_y[i] = minutiaeList[i].y;
		_mType[i] = minutiaeList[i].type;
		_angle[i] = minutiaeList[i].angle;
	}

	return true;
}


int* GetX()
{
	return _x;
}

int* GetY()
{
	return _y;
}

int* GetMType()
{
	return _mType;
}

float* GetAngle()
{
	return _angle;
}