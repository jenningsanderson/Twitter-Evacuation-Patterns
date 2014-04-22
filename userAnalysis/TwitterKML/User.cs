using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Linq;
using System.Json;

namespace TwitterKML
{
    /// <summary>
    /// A user contains a series of tweets and a handle.
    /// </summary>
    [System.Diagnostics.DebuggerDisplay("{Handle,nq}{Reliable?\"*\":\"\",nq} [{Tweets.Length}]")]
    class User
    {
        /// <summary>
        /// These are the time period subsets we're working with.
        /// </summary>
        public static DateTime[] Subsets = { new DateTime(2012, 10, 22, 0, 0, 0, DateTimeKind.Utc), 
                                               new DateTime(2012, 10, 27, 12, 0, 0, DateTimeKind.Utc), 
                                               new DateTime(2012,11,1,0,0,0,DateTimeKind.Utc), 
                                               new DateTime(2012, 11, 7, 0, 0, 0, DateTimeKind.Utc) };


        /// <summary>
        /// Get the unique user ID.
        /// </summary>
        public readonly string UID;
        /// <summary>
        /// Get the users handle (nice name).
        /// </summary>
        public readonly string Handle;
        /// <summary>
        /// Get the collection of tweets.
        /// </summary>
        public readonly Tweet[] Tweets;
        /// <summary>
        /// Get the tweets for every bucket.
        /// </summary>
        public readonly Tweet[][] TweetBuckets;
        /// <summary>
        /// Get the median of each bucket.
        /// </summary>
        public readonly Point[] BucketMedians;
        /// <summary>
        /// Get the speed between tweets. Units are meters / second.
        /// </summary>
        public readonly double[] TweetSpeeds;

        //Properties
        /// <summary>
        /// They flew if they ever moved faster than a given threshold.
        /// </summary>
        public bool Flew
        {
            get
            {
                return TweetSpeeds.Any(x => x > 67); //150mph
            }
        }
        /// <summary>
        /// Get if the user is reliable tweeter.
        /// </summary>
        public bool Reliable
        {
            get
            {
                return TweetBuckets.All(x => x.Length >= ReliableParam);
            }
        }
        /// <summary>
        /// Get the parameter used to determine reliability.
        /// </summary>
        private readonly int ReliableParam;

        //Constructor
        /// <summary>
        /// Create a User by providing a JSON value.
        /// </summary>
        /// <param name="Profile"></param>
        public User(string json, int nPerBucket = 30)
        {
            JsonValue Profile = JsonValue.Parse(json);
            this.UID = (string)Profile["id"];
            this.Handle = (string)Profile["handle"];
            this.Tweets = ((JsonArray)Profile["features"]).Select<JsonValue, Tweet>(x => new Tweet(x)).GroupBy(x => x.When).Select(x => x.First()).OrderBy(x => x.When).ToArray();
            this.ReliableParam = nPerBucket;

            //Subset the tweets.
            this.TweetBuckets = new Tweet[Subsets.Length - 1][];
            for (int i = 0; i < TweetBuckets.Length; i++)
            {
                this.TweetBuckets[i] = Tweets.Where(x => x.When >= Subsets[i] && x.When < Subsets[i + 1]).ToArray();
            }

            //Calculate the median center.
            this.BucketMedians = new Point[this.TweetBuckets.Length];
            for (int i = 0; i < BucketMedians.Length; i++)
            {
                BucketMedians[i] = new Point(TweetBuckets[i].Select(x => x.Where.x).Median(), TweetBuckets[i].Select(x => x.Where.y).Median());
            }

            //Calculate tweet speeds.
            this.TweetSpeeds = new double[this.Tweets.Length - 1];
            for (int i = 0; i < this.Tweets.Length - 1; i++)
            {
                Tweet A = this.Tweets[i];
                Tweet B = this.Tweets[i + 1];
                TweetSpeeds[i] = Utility.EllipsoidDistance(A.Where.y, A.Where.x, B.Where.y, B.Where.x) / (B.When - A.When).TotalSeconds;
            }
        }

        //Methods
        /// <summary>
        /// Calculate the distance for each state transition.
        /// </summary>
        /// <returns></returns>
        public Dictionary<StateTransitions, double> CalculateDistances()
        {
            Dictionary<StateTransitions, double> Ans = new Dictionary<StateTransitions, double>();
            for (int i = 0; i < BucketMedians.Length; i++)
            {
                State A = (State)i;
                for (int j = i + 1; j < BucketMedians.Length; j++)
                {
                    State B = (State)j;
                    StateTransitions ST = (StateTransitions)Enum.Parse(typeof(StateTransitions), A + "_" + B);
                    Ans.Add(ST, Utility.EllipsoidDistance(BucketMedians[i].y, BucketMedians[i].x, BucketMedians[j].y, BucketMedians[j].x));
                }
            }
            return Ans;
        }
        /// <summary>
        /// Convert the user to a KML representation.
        /// </summary>
        /// <returns></returns>
        public XElement ToKML()
        {
            XElement Root = new XElement(NS.ogis + "Folder",
                new XElement("name", Handle),
                new XElement("open", 0),
                new XElement("visibility", 0));
            XElement Paths = new XElement("Folder",
                new XElement("name", "paths"));
            XElement Points = new XElement("Folder",
                new XElement("name", "median points"));


            for (int i = 0; i < BucketMedians.Length; i++)
            {
                Points.Add(new XElement("Placemark",
                    new XElement("name", (State)i),
                    new XElement("styleUrl", "#" + (State)i),
                    new XElement("Point",
                        new XElement("coordinates", BucketMedians[i].x + "," + BucketMedians[i].y)
                    )
                ));
                Paths.Add(new XElement("Placemark",
                    new XElement("name", (State)i + "(" + TweetBuckets[i].Length + ")"),
                    new XElement("styleUrl", "#" + (State)i),
                    new XElement("LineString",
                        new XElement("extrude", 1),
                        new XElement("tessellate", 1),
                        new XElement("coordinates", string.Join(" ", TweetBuckets[i].Select(x => x.Where.x + "," + x.Where.y)))
                    )
                ));
            }

            XElement SingleTweets = new XElement("Folder",
                new XElement("name", "tweets"));
            for (int i = 0; i < TweetBuckets.Length; i++)
            {
                XElement Category = new XElement("Folder",
                    new XElement("name", (State)i));
                foreach (var tweet in TweetBuckets[i])
                {
                    Category.Add(new XElement("Placemark",
                        new XElement("styleURL", "#tweet"),
                        //new XElement("name", (tweet.When + new TimeSpan(-4, 0, 0)).ToString()),
                        new XElement("visibility", 0),
                        //new XElement("Snippet", tweet.Content),
                        new XElement("description", tweet.When.ToUniversalTime().ToString() + Environment.NewLine + tweet.Content),
                        new XElement("Point",
                            new XElement("coordinates", tweet.Where.x + "," + tweet.Where.y)
                        )
                    ));
                }
                SingleTweets.Add(Category);
            }

            Root.Add(Points);
            Root.Add(Paths);
            Root.Add(SingleTweets);
            return Root;
        }
    }

}
