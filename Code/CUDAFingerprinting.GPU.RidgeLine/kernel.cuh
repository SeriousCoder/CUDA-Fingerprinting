#include "CUDAArray.cuh"

#define min(a,b) (((a)<(b))?(a):(b))

enum Direction
{
	Forward,
	Back
};

enum MinutiaeType
{
	NotMinutiae,
	LineEnding,
	Intersection
};

struct Point
{
	int x;
	int y;
};

typedef struct Minutiae
{
	int x;
	int y;
	float angle;
	int type;
};


extern "C"
{
	//__declspec(dllexport) bool Start(float* source, float* orientField, int step, int lengthWings, int width, int height);
	__declspec(dllexport) bool Start(Minutiae* minutias, float* source, int step, int lengthWings, int width, int height);
	__declspec(dllexport) void outputToFile();
	__declspec(dllexport) int* GetX();
	__declspec(dllexport) int* GetY();
	__declspec(dllexport) int* GetMType();
	__declspec(dllexport) float* GetAngle();
}

//__global__ void FindMinutia(CUDAArray<float> image, CUDAArray<float> orientationField, CUDAArray<bool> visited,
//	CUDAArray<int> countOfMinutiae, CUDAArray<ListOfMinutiae*> minutiaes,
//	const int size, const int step, int colorThreshold);

bool Parsing(Minutiae* minutiaeList, int size);

void DeleteDuplicate(Minutiae* minutiaes, int size = 300, int delta = 5);

#define cudaCheckError() {\
	cudaError_t e = cudaGetLastError(); \
	if (e != cudaSuccess) {\
		printf("Cuda failure %s:%d: '%s'\n", __FILE__, __LINE__, cudaGetErrorString(e));\
		exit(0);\
											}\
}