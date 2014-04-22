using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Xml.Linq;

namespace TwitterKML
{
    /// <summary>
    /// Extension methods applied to objects.
    /// </summary>
    static class Extensions
    {
        public static IEnumerable<string> ReadAllLines(this StreamReader rdr)
        {
            while (!rdr.EndOfStream)
            {
                yield return rdr.ReadLine();
            }
        }

        public static double Median(this IEnumerable<double> self)
        {
            IEnumerable<double> Ordered = self.OrderBy(x => x);
            IEnumerator<double> Enum = Ordered.GetEnumerator();
            int n = Ordered.Count();
            if (n % 2 == 0)//average
            {
                for (int i = 0; i < n / 2; i++)
                {
                    Enum.MoveNext();
                }
                double a = Enum.Current;
                Enum.MoveNext();
                double b = Enum.Current;
                return (a + b) / 2.0;
            }
            else
            {
                //Take the middle
                for (int i = 0; i < n / 2 + 1; i++)
                {
                    Enum.MoveNext();
                }
                return Enum.Current;
            }
        }

        public static double Sum(this double[,] self)
        {
            double ans = 0;
            foreach (var item in self)
            {
                ans += item;
            }
            return ans;
        }
    }

    /// <summary>
    /// Utility methods.
    /// </summary>
    static class Utility
    {
        /// <summary>
        /// Calculate the distance on an ellipsoid from a pair of latitude and longitude points. Vincenty's Formulae. Source: http://www.movable-type.co.uk/scripts/latlong-vincenty.html
        /// </summary>
        /// <param name="Lat1"></param>
        /// <param name="Lon1"></param>
        /// <param name="Lat2"></param>
        /// <param name="Lon2"></param>
        /// <param name="SemiMajor">The length along the semimajor axis</param>
        /// <param name="SemiMinor">The length along the semiminor axis</param>
        /// <param name="Flattening">The flattening coefficient of the ellipsoid</param>
        /// <returns>Meters</returns>
        public static double EllipsoidDistance(double Lat1, double Lon1, double Lat2, double Lon2, double SemiMajor = 6378137.0, double SemiMinor = 6356752.3142, double Flattening = 1.0 / 298.257223563)
        {
            const double accuracy = 1e-12;
            const double DegToRad = Math.PI / 180.0;

            double f = Flattening;
            double a = SemiMajor;
            double b = SemiMinor;


            double L = (Lon2 - Lon1) * DegToRad;
            double U1 = Math.Atan((1 - f) * Math.Tan(Lat1 * DegToRad));
            double U2 = Math.Atan((1 - f) * Math.Tan(Lat2 * DegToRad));
            double sinU1 = Math.Sin(U1);
            double sinU2 = Math.Sin(U2);
            double cosU1 = Math.Cos(U1);
            double cosU2 = Math.Cos(U2);

            double lambda = L;
            double lambdaP = lambda;
            double sinLambda, cosLambda, sinSigma, cosSigma, sigma, sinAlpha, cosSqAlpha, cos2SigmaM, C;
            do
            {
                sinLambda = Math.Sin(lambda);
                cosLambda = Math.Cos(lambda);
                sinSigma = Math.Sqrt((cosU2 * sinLambda) * (cosU2 * sinLambda) + (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda) * (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda));
                if (sinSigma == 0) return 0;    //co-incident points
                cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda;
                sigma = Math.Atan2(sinSigma, cosSigma);
                sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
                cosSqAlpha = 1 - sinAlpha * sinAlpha;
                cos2SigmaM = cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha;
                if (double.IsNaN(cos2SigmaM)) cos2SigmaM = 0;   //equatorial line
                C = (f / 16.0) * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha));
                lambdaP = lambda;
                lambda = L + (1 - C) * f * sinAlpha * (sigma + C * sinSigma * (cos2SigmaM + C * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)));
            }
            while (Math.Abs(lambda - lambdaP) > accuracy);

            double uSq = cosSqAlpha * (a * a - b * b) / (b * b);
            double A = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
            double B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
            double deltaSigma = B * sinSigma * (cos2SigmaM + (B / 4) * (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) - (B / 6) * cos2SigmaM * (-3 + 4 * sinSigma * sinSigma) * (-3 + 4 * cos2SigmaM * cos2SigmaM)));
            double s = b * A * (sigma - deltaSigma);

            return s;
        }
    }

    enum State { Before = 0, During = 1, After = 2 }
    /// <summary>
    /// The transitions between states.
    /// </summary>
    enum StateTransitions { Before_During, Before_After, During_After }

    /// <summary>
    /// Namespaces for the KML authoring. 
    /// </summary>
    static class NS
    {
        public static readonly XNamespace ogis = "http://www.opengis.net/kml/2.2";
        public static readonly XNamespace gx = "http://www.google.com/kml/ext/2.2";
    }

    /// <summary>
    /// A simple point object.
    /// </summary>
    [System.Diagnostics.DebuggerDisplay("Point (x = {x,nq}, y = {y,nq})")]
    class Point
    {
        /// <summary>
        /// Get the x component.
        /// </summary>
        public readonly double x;
        /// <summary>
        /// Get the y component.
        /// </summary>
        public readonly double y;

        //Constructors
        public Point()
            : this(0, 0)
        { }
        public Point(double x, double y)
        {
            this.x = x;
            this.y = y;
        }

        /// <summary>
        /// Calculate the distance between the two points on an ellipsoid.
        /// </summary>
        /// <param name="other"></param>
        /// <returns></returns>
        public double EllipsoidDistance(Point other)
        {
            return Utility.EllipsoidDistance(this.y, this.x, other.y, other.x);
        }
    }
}
