using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Json;

namespace TwitterKML
{
    /// <summary>
    /// A tweet has a time, content, and a place.
    /// </summary>
    [System.Diagnostics.DebuggerDisplay("{When} - {Content,nq}")]
    class Tweet
    {
        /// <summary>
        /// Get when the tweet was made.
        /// </summary>
        public readonly DateTime When;
        /// <summary>
        /// Get the content of the tweet.
        /// </summary>
        public readonly string Content;
        /// <summary>
        /// Get where the tweet was made
        /// </summary>
        public readonly Point Where;

        //Constructor
        /// <summary>
        /// Create a tweet from a JSON value.
        /// </summary>
        /// <param name="Content"></param>
        public Tweet(JsonValue Content)
        {
            //Convert from mongo DT to C# DT.
            this.When = new DateTime((long)Content["properties"]["created_at"]["$date"] * TimeSpan.TicksPerMillisecond, DateTimeKind.Utc).AddYears(1969);

            JsonArray Loc = (JsonArray)Content["geometry"]["coordinates"];
            this.Where = new Point((double)Loc[0], (double)Loc[1]);

            this.Content = (string)Content["properties"]["text"];
        }
    }
}
