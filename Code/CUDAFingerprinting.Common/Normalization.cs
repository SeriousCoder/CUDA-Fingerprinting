﻿using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Runtime.ExceptionServices;
using System.Text;

namespace CUDAFingerprinting.Common
{
    static class Normalization
    {
        public static double CalculateMean(this double[,] image)
        {
            int height = image.GetLength(1);
            int width = image.GetLength(0);
            double mean = 0;
            for (int i = 0; i < height; i++)
            {
                for (int j = 0; j < width; j++)
                {
                    mean += image[i, j] / (height * width);
                }
            }
            return mean;
        }
        public static double CalculateVariation(this double[,] image, double mean)
        {
            int height = image.GetLength(1);
            int width = image.GetLength(0);
            double variation = 0;
            for (int i = 0; i < height; i++)
            {
                for (int j = 0; j < width; j++)
                {
                    variation += Math.Pow((image[i, j] - mean), 2) / (height * width);
                }
            }
            return variation;
        }

        static public double[,] DoNormalization(this double[,] image, int bordMean, int bordVar)
        {
            var mean = image.CalculateMean();
            var variation = image.CalculateVariation(mean);

            for (int i = 0; i < image.GetLength(0); i++)
            {
                for (int j = 0; j < image.GetLength(1); j++)
                {
                    if (image[i, j] > mean)
                    {
                        image[i, j] = bordMean + Math.Sqrt((bordVar * Math.Pow(image[i, j] - mean, 2)) / variation);
                    }
                    else
                    {
                        image[i, j] = bordMean - Math.Sqrt((bordVar * Math.Pow(image[i, j] - mean, 2)) / variation);
                    }
                }
            }

            return image;
        }
    }
}
