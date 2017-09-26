#include "kernel.cuh"
#include "cuda_runtime.h"
#include <math.h>
#include <stdlib.h>
#include <stdio.h>

void Sort(Minutiae* minutiaes, int size);
void merge(Minutiae* minutiaes, int left, int mid, int right);

void DeleteDuplicate(Minutiae* minutiaes, int size, int delta)
{
	//printf("Starting search a duplications\n");
	Sort(minutiaes, size);

	for (int i = 1; i < size; i++)
	{
		if (minutiaes[i].type == 0) break;

		for (int j = 0; j < i; j++)
		{
			if (minutiaes[i].type == minutiaes[j].type)
				if (sqrt(pow((float)minutiaes[i].x - minutiaes[j].x, 2) +
					pow((float)minutiaes[i].y - minutiaes[j].y, 2)) < delta)
				{
					minutiaes[i].type = 0;
					break;
				}
		}
	}
}

void Sort(Minutiae* minutiaes, int size)
{
	for (int i = 1; i < size; i *= 2)
		for (int j = 0; j < size - i; j += 2 * i)
			merge(minutiaes, j, j + i, min(j + 2 * i, size));
}

void merge(Minutiae* minutiaes, int left, int mid, int right)
{
	int it1 = 0, it2 = 0;
	Minutiae* result = (Minutiae*)malloc((right - left) * sizeof(Minutiae));

	while (left + it1 < mid && mid + it2 < right)
	{
		if (minutiaes[left + it1].type == minutiaes[mid + it2].type &&
			minutiaes[mid + it2].type == NotMinutiae) break;

		if (minutiaes[left + it1].type == minutiaes[mid + it2].type)
		{
			if (minutiaes[left + it1].x * 1000 + minutiaes[left + it1].y <
				minutiaes[mid + it2].x * 1000 + minutiaes[mid + it2].y)
			{
				result[it1 + it2] = minutiaes[left + it1];
				it1++;
			}
			else
			{
				result[it1 + it2] = minutiaes[mid + it2];
				it2++;
			}
		}
		else if (minutiaes[left + it1].type != NotMinutiae)
		{
			result[it1 + it2] = minutiaes[left + it1];
			it1++;
		}
		else
		{
			result[it1 + it2] = minutiaes[mid + it2];
			it2++;
		}

	}

	while (left + it1 < mid)
	{
		result[it1 + it2] = minutiaes[left + it1];
		it1++;
	}

	while (mid + it2 < right)
	{
		result[it1 + it2] = minutiaes[mid + it2];
		it2++;
	}

	for (int i = 0; i < it1 + it2; i++)
		minutiaes[left + i] = result[i];

	free(result);
}