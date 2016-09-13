
> Module 1: Creating a twitter API at https://apps.twitter.com/

The Twitter micro-blogging service includes two RESTful APIs. The Twitter REST API methods allow developers to access core 
Twitter data. This includes update timelines, status data, and user information. The Search API methods give developers methods 
to interact with Twitter Search and trends data. Hence, in order to extract tweets, we need a Twitter account and hence a Twitter 
API to get our own access keys and authentication to use twitter data in our application.

> Module 2: Establishing Connection to fetch tweets from twitter

The first step would be to establish an authorized connection with Twitter for getting tweets based on different search parameters. 
It requires installation of R libraries such as “ROAuth” – an open standard authentication for R interface and “httr” – to handle 
http requests.

> Module 3: Retrieval of tweets to R Script
Once the connection is successfully established, we can fetch tweets with the help of twitter API to the working R script. One 
can extract a maximum of 3200 tweets at a time from the site. If required more, one can execute the set of code 
(that does fetching) in a loop.

> Module 4: Sentiment analysis (Naïve Bayes) of tweets via ‘bar plot’ and ‘pie chart’

We can now analyze the sentiment of tweets using Naïve Bayes algorithm, a supervised machine learning text classification 
algorithm that comes as a built-in algorithm in R language. All we have to do is to just use the “sentiment” library in R 
specifying the algorithm as “bayes” with required prior probability (that ranges between 0.0 – 1.0) and giving the tweet texts 
as input. With this library, we can make use of two functions “classify_emotion()” that has 6 built-in emotions such as joy, 
anger, sad, disgust, fear, surprise with which we can describe the state of mind of the tweeple and “classify_polarity()” 
that classifies polarities as positive, negative and neutral with which we can visualize the critics about the movie. Finally, 
we can visualize the emotions in a bar chart with x label as ‘emotions’ and y label as ‘number of tweets with the 
respective sentiment’ and visualizing the polarity in a piechart showing the volume of critics in the tweets which is done with 
the help of “rCharts” library – an interactive javascript data visualization library in R.

> Module 5: Formation of Word Cloud based on the occurrences of the word in the tweets

The word cloud is a graphical representation of frequently used words in a collection of text files. The height of each word in 
this picture is an indication of frequency of occurrence of the word in the entire text. We turn the corpus into a structured data 
by processing the texts by removing the numbers, stop words, punctuation, unicode characters, making all the words uniform 
to lowercase and finally, unnecessary white spaces are stripped. Now, the frequency of every word is calculated in the resultant 
data, sorted with respect to its frequency of occurrence, converted to a data frame and a cluster of words is formed.  

> Module 6: Visualization of top most 10 frequency of occurrences of the words in the analysis via ‘bar plot’

From the very same data processed for creating the word cloud, we visualize the top most 10 frequency of occurrences of the words 
by extracting the top 10 words with its frequency in the created data frame with “rCharts” library.

> Module 7: Visualization of location of the tweets (the place where it was generated)

Location of the tweets for a particular movie is tracked down by prompting the user to enter the latitude, longitude pair of 
location along with the radius (a coverage actually) until which the location of tweets is searched for. It is visualized with 
the help of “leaflet” package. It is designed in a way that if the user places the pointer over the marker on the location, it 
will display the name of the twitter user who tweeted the tweet.

> Module 8: Integrating all the above components in Shiny RStudio dashboard

Shiny RStudio is a web application framework for R. It helps take the R script to the next whole new level. Instead of running 
the script that are scattered here and there, Shiny provides a space for creating an application in R under one roof with an 
elegant UI. It consists of two R scripts ‘ui.R’ and ‘server.R’. ‘ui.R’ consists of code written to interact with user and all 
those values are passed to the server side in ‘server.R’ like all other programming languages. ‘server.R’ consists of the script 
for computation, processing and visualization of data. If the developer wishes, he can take the application to be hosted on 
Shiny server online, so that the users worldwide can utilize the application and make use of it.
