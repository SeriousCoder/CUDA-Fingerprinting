using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using CUDAFingerprinting.Common;
using CUDAFingerprinting.GPU.RidgeLine.Tests.Properties;

namespace CUDAFingerprinting.GPU.RidgeLine.Tests
{
    class Program
    {
        enum MinutiaTypes
        {
            NotMinutia,
            LineEnding,
            Intersection
        }

        struct Minutiae
        {
            public int X;
            public int Y;
            public float Angle;
            public MinutiaTypes MinutiaType;
        }

        [DllImport("CUDAFingerprinting.GPU.RidgeLine.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "Start")]
        public static extern bool Start(IntPtr ptr, float[] source, int step, int lengthWings, int width, int height);

        //[DllImport("CUDAFingerprinting.GPU.RidgeLine.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "GetX")]
        //public static extern int[] GetX();
        //[DllImport("CUDAFingerprinting.GPU.RidgeLine.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "GetY")]
        //public static extern int[] GetY();
        //[DllImport("CUDAFingerprinting.GPU.RidgeLine.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "GetMType")]
        //public static extern int[] GetMType();
        //[DllImport("CUDAFingerprinting.GPU.RidgeLine.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "GetAngle")]
        //public static extern float[] GetAngle();

        static void Main(string[] args)
        {
            var bmp = Resources.SampleFinger4;
            var image = ImageHelper.LoadImage<double>(bmp);

            int arraySize = Marshal.SizeOf(typeof(Minutiae));
            IntPtr minutiaeIntPtr = Marshal.AllocHGlobal(arraySize * image.GetLength(0) * image.GetLength(1));

            Console.WriteLine(@"{0}",Start(minutiaeIntPtr, array2Dto1D(image), 2, 3, image.GetLength(0), image.GetLength(1)));



            int size = image.GetLength(0) * image.GetLength(1);

            //var x = GetX();
            //var y = GetY();
            //var angle = GetAngle();
            //var mType = GetMType();

            List<Minutia> listOfMinutiaes = new List<Minutia>();

            for (int i = 0; i < size; i++)
            {
                IntPtr ptr = new IntPtr(minutiaeIntPtr.ToInt32() + arraySize * i);
                Minutiae minutiae = (Minutiae) Marshal.PtrToStructure(ptr, typeof(Minutiae));

                if (minutiae.MinutiaType != MinutiaTypes.NotMinutia)
                {
                    Minutia foo = new Minutia();
                    foo.X = minutiae.X;
                    foo.Y = minutiae.Y;
                    foo.Angle = minutiae.Angle;

                    listOfMinutiaes.Add(foo);
                    Console.WriteLine(@"{0} {1} {2} {3}", minutiae.X, minutiae.Y, minutiae.Angle, minutiae.MinutiaType);
                }
            }

            ImageHelper.MarkMinutiae("..\\..\\rez.bmp", listOfMinutiaes, "res.bmp");
        }

        private static int[] array2Dto1D(int[,] source)
        {
            int[] res = new int[source.GetLength(0) * source.GetLength(1)];
            for (int y = 0; y < source.GetLength(0); y++)
            {
                for (int x = 0; x < source.GetLength(1); x++)
                {
                    res[y * source.GetLength(1) + x] = source[y, x];
                }
            }
            return res;
        }

        private static float[] array2Dto1D(double[,] source)
        {
            float[] res = new float[source.GetLength(0) * source.GetLength(1)];
            for (int y = 0; y < source.GetLength(0); y++)
            {
                for (int x = 0; x < source.GetLength(1); x++)
                {
                    float result = (float)source[y, x];
                    if (float.IsPositiveInfinity(result))
                    {
                        result = float.MaxValue;
                    }
                    else if (float.IsNegativeInfinity(result))
                    {
                        result = float.MinValue;
                    }
                    res[y * source.GetLength(1) + x] = result;
                }
            }
            return res;
        }
    }
}
