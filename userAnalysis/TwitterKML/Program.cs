using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Json;
using System.IO;
using System.Xml;
using System.Xml.Linq;

namespace TwitterKML
{
    class Program
    {
        static void Main(string[] args)
        {
            //JSON file with one line per tweet.
            string rawPath = @"D:\Andrew Hardin\Desktop\coastal_users_better.txt";
            
            //Load the users.
            User[] Users;
            using (StreamReader rdr = new StreamReader(rawPath))
            {
                Users = rdr.ReadAllLines().Select(x => new User(x)).ToArray();
            }

            //Only select the reliable users.
            User[] Reliable = Users.Where(x => x.Reliable).ToArray();


            //Writeout diagnostics.
            string Base = Path.GetDirectoryName(rawPath);
            WriteDistanceList(Base + @"\TriangleDistances.csv", Reliable);
            WriteUserKML(Base + @"\diagnostic.kml", Reliable);
            WriteMultipoint(Base + @"\ImportToArcmap.csv", Reliable);
        }

        /// <summary>
        /// Write a KML with every user at a given path.
        /// </summary>
        /// <param name="path"></param>
        /// <param name="Users"></param>
        static void WriteUserKML(string path, IEnumerable<User> Users)
        {
            XElement Root = new XElement(NS.ogis + "kml",
                           new XAttribute(NS.gx + "gx", "http://www.google.com/kml/ext/2.2"));
            Root.Add(new XElement("Document",
                new XElement("visibility", 0),
                new XElement("Style",
                    new XAttribute("id", "Before"),
                    new XElement("IconStyle",
                        new XElement("scale", .4),
                        new XElement("Icon",
                            new XElement("href", "http://maps.google.com/mapfiles/kml/paddle/grn-blank-lv.png")
                        )
                    ),
                    new XElement("LabelStyle",
                        new XElement("scale", 0)
                    ),
                    new XElement("LineStyle",
                        new XElement("color", "ff5bbd00"),
                        new XElement("width", 1.4)
                    )
                ),
                new XElement("Style",
                    new XAttribute("id", "During"),
                    new XElement("IconStyle",
                        new XElement("scale", .4),
                        new XElement("Icon",
                            new XElement("href", "http://maps.google.com/mapfiles/kml/paddle/red-circle-lv.png")
                        )
                    ),
                    new XElement("LabelStyle",
                        new XElement("scale", 0)
                    ),
                    new XElement("LineStyle",
                        new XElement("color", "ff1515a6"),
                        new XElement("width", 1.4)
                    )
                ),
                new XElement("Style",
                    new XAttribute("id", "After"),
                    new XElement("IconStyle",
                        new XElement("scale", .4),
                        new XElement("Icon",
                            new XElement("href", "http://maps.google.com/mapfiles/kml/paddle/ylw-blank-lv.png")
                        )
                    ),
                    new XElement("LabelStyle",
                        new XElement("scale", 0)
                    ),
                    new XElement("LineStyle",
                        new XElement("color", "ff7fffff"),
                        new XElement("width", 1.4)
                    )
                ),
                new XElement("Style",
                    new XAttribute("id", "tweet"),
                    new XElement("IconStyle",
                        new XElement("scale", .2),
                        new XElement("Icon",
                            new XElement("href", "http://maps.google.com/mapfiles/kml/paddle/ylw-blank-lv.png")
                        )
                    ),
                    new XElement("LabelStyle",
                        new XElement("scale", 0)
                    ),
                    new XElement("LineStyle",
                        new XElement("color", "ff7fffff"),
                        new XElement("width", 1.4)
                    )
                ),
                Users.Select(x => x.ToKML())));

            Root.Save(path);
        }
        /// <summary>
        /// Write the list of distance parameters per user.
        /// </summary>
        /// <param name="Path"></param>
        /// <param name="Users"></param>
        static void WriteDistanceList(string Path, IEnumerable<User> Users)
        {
            using (StreamWriter wrtr = new StreamWriter(Path))
            {
                //Figure out the divisions.
                StateTransitions[] Keys = Users.First().CalculateDistances().Keys.ToArray();
                string DivisionKey = "";
                for (int i = 0; i < Keys.Length; i++)
                {
                    for (int j = i+1; j < Keys.Length; j++)
                    {
                        DivisionKey += Keys[i] + "/" + Keys[j] + ",";
                    }
                }
                
                //Write the CSV header.
                wrtr.WriteLine("handle,flew," + string.Join(",", Enum.GetNames(typeof(State)).Select(x => x + " nTweets")) + "," + string.Join<StateTransitions>(",", Keys) + ",perimeter," + DivisionKey);

                //Loop through every user writing them to the CSV.
                foreach (User item in Users)
                {
                    Dictionary<StateTransitions, double> values = item.CalculateDistances();

                    //Calculating the division ratios.
                    string DivisionValues = "";
                    for (int i = 0; i < Keys.Length; i++)
                    {
                        for (int j = i + 1; j < Keys.Length; j++)
                        {
                            DivisionValues += (values[Keys[i]] / values[Keys[j]]) + ",";
                        }
                    }

                    //Calculate the number of tweets per user.
                    string nTweets = "";
                    for (int i = 0; i < item.TweetBuckets.Length; i++)
                    {
                        nTweets += item.TweetBuckets[i].Length + ",";
                    }

                    //Write everything out to the CSV.
                    wrtr.WriteLine(item.Handle.Replace(',', '_') + "," + item.Flew + "," + nTweets + string.Join<double>(",", Keys.Select(x => values[x])) + "," + values.Sum(x => x.Value) + "," + DivisionValues);
                }
            }
        }
        /// <summary>
        /// Write the median location for each user to a CSV.
        /// </summary>
        /// <param name="path"></param>
        /// <param name="Users"></param>
        static void WriteMultipoint(string path, IEnumerable<User> Users)
        {
            using (StreamWriter wrtr = new StreamWriter(path))
            {
                wrtr.WriteLine("user,type,latitude,longitude");
                foreach (User item in Users)
                {
                    for (int i = 0; i < item.BucketMedians.Length; i++)
                    {
                        wrtr.WriteLine(item.Handle.Replace(',','_') + "," + (State)i + "," + item.BucketMedians[i].y + "," + item.BucketMedians[i].x);
                    }
                }
            }
        }
    }
}
