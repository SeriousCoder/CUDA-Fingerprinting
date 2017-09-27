using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using CUDAFingerprinting.Common;
using CUDAFingerprinting.Common.OrientationField;
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

        [StructLayout(LayoutKind.Sequential)]
        struct Minutiae
        {
            [MarshalAs(UnmanagedType.I4)]
            public int X;
            [MarshalAs(UnmanagedType.I4)]
            public int Y;
            [MarshalAs(UnmanagedType.R4)]
            public float Angle;
            [MarshalAs(UnmanagedType.I4)]
            public int MinutiaType;
        }

        //[DllImport("CUDAFingerprinting.GPU.MinutiaeDetectionRL.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "Start")]
        //public static extern bool Start(IntPtr ptr, float[] source, float[] orientField, int step, int lengthWings, int width, int height);

       
        //public static extern bool Start(IntPtr ptr, float[] source, int step, int lengthWings, int width, int height);
        [DllImport("CUDAFingerprinting.GPU.RidgeLine.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "Start")]
        public static extern bool Start(IntPtr ptr, float[] source, int step, int lengthWings, int width, int height);
        //public static extern bool Start(float[] source, float[] orientField, int step, int lengthWings, int width, int height);

        //[DllImport("CUDAFingerprinting.GPU.RidgeLine.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "GetX")]
        //public static extern int[] GetX();
        //[DllImport("CUDAFingerprinting.GPU.RidgeLine.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "GetY")]
        //public static extern int[] GetY();
        //[DllImport("CUDAFingerprinting.GPU.RidgeLine.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "GetMType")]
        //public static extern int[] GetMType();
        //[DllImport("CUDAFingerprinting.GPU.RidgeLine.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "GetAngle")]
        //public static extern float[] GetAngle();

        [DllImport("CUDAFingerprinting.GPU.RidgeLine.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "outputToFile")]
        public static extern void outputToFile();

        static void Main(string[] args)
        {
            var bmp = Resources.RawFinger;
            int[,] image = ImageHelper.LoadImage<int>(bmp);
            double[,] source = Normalization.DoNormalization(convertToDoubles(image), 100, 1000);

            ImageHelper.SaveArray(source, "norm.bmp", true);

            int minutiaeSize = Marshal.SizeOf(typeof(Minutiae));
            IntPtr minutiaeIntPtr = Marshal.AllocHGlobal(minutiaeSize * image.GetLength(0) * image.GetLength(1));

            PixelwiseOrientationField orientation = new PixelwiseOrientationField(image, 18);

            //outputToFile();

            bool res = Start(minutiaeIntPtr, array2Dto1D(source), 4, 3,
                image.GetLength(1), image.GetLength(0));

            //if (!res) Console.WriteLine("Parsing down");

            //Console.WriteLine(@"{0}",res);

            int size = image.GetLength(0) * image.GetLength(1);

            //int[] x = new int[size];
            //x = GetX();
            //int[] y = new int[size];
            //y = GetY();
            //float[] angle = new float[size]; 
            //angle = GetAngle();
            //int[] mType = new int[size];
            //mType = GetMType();

            List<Minutia> listOfMinutiaes = new List<Minutia>();

            for (int i = 0; i < size; i++)
            {
                //if (mType[i] == 1)
                //{
                //    Minutia newMinutiae = new Minutia();

                //    newMinutiae.X = x[i];
                //    newMinutiae.Y = y[i];
                //    newMinutiae.Angle = angle[i];
                //    //newMinutiae.MinutiaType = (MinutiaTypes) mType[i];

                //    listOfMinutiaes.Add(newMinutiae);
                //}

                IntPtr ptr = new IntPtr(minutiaeIntPtr.ToInt32() + minutiaeSize * i);
                Minutiae minutiae = (Minutiae)Marshal.PtrToStructure(ptr, typeof(Minutiae));

                if (minutiae.MinutiaType == 1)
                {
                    Minutia foo = new Minutia();
                    foo.X = minutiae.X;
                    foo.Y = image.GetLength(0) - minutiae.Y + 1;
                    foo.Angle = minutiae.Angle;

                    listOfMinutiaes.Add(foo);
                    //Console.WriteLine(@"{0} {1} {2} {3}", minutiae.X, minutiae.Y, minutiae.Angle, minutiae.MinutiaType);
                }
            }

            Marshal.FreeHGlobal(minutiaeIntPtr);

            ImageHelper.MarkMinutiae(bmp, listOfMinutiaes, "res.bmp");
        }

        private static float[] array2Dto1D(int[,] source)
        {
            float[] res = new float[source.GetLength(0) * source.GetLength(1)];
            for (int y = 0; y < source.GetLength(0); y++)
            {
                for (int x = 0; x < source.GetLength(1); x++)
                {
                    res[y * source.GetLength(1) + x] = source[y, x];
                    //Console.Write("{0} ", res[y * source.GetLength(1) + x] < 20 ? "*" : "0");
                }
                //Console.WriteLine();
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

        private static double[,] convertToDoubles(int[,] source)
        {
            double[,] newDoubles = new double[source.GetLength(0), source.GetLength(1)];

            for (int y = 0; y < source.GetLength(0); y++)
            {
                for (int x = 0; x < source.GetLength(1); x++)
                {
                    newDoubles[y, x] = source[y, x];
                }
            }

            return newDoubles;
        }
    }
}
