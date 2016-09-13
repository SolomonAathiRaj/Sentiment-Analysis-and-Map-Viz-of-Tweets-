# Sentiment-Analysis-and-Map-Viz-of-Tweets-
This project “Prognostication of Box Office Talk using Twitter Corpus” predicts the success of the movie using state of mind of the people that could possibly be achieved by sentiment analysis. The analysis is done with Naive Bayes Classifier which is a supervised text classification algorithm attaining 81 percent of F-Score. This work is also incorporated with visualization of data in R language which stands one among the best in representing the analysis in pictorial format and a map visualization that portrays the location of the tweets with the user name where it has come from.

The Bayesian classification is used as a probabilistic learning method (Naive Bayes text classification). Hence, Naive Bayes classifier is one basic algorithm in Machine Learning to classify text documents. It is a simple model for text classification based on ‘Bayes’ theorem’. It is the most efficient and frequently used algorithm for sentiment analysis.

Bayes theorem provides a way of calculating posterior probability P(c|x) from P(c), P(x) and P(x|c). Look at the equation below:

![alt tag](https://github.com/SolomonAathiRaj/Sentiment-Analysis-and-Map-Viz-of-Tweets-/blob/master/images/Bayes_rule.png)
  
* P(c|x) is the posterior probability of class (target) given predictor (attribute).
* P(c) is the prior probability of class.
* P(x|c) is the likelihood which is the probability of predictor given class.
* P(x) is the prior probability of predictor.

I've also analysed the same with **lexicons**.

People who are using the application deployed in shinyapps.io can view the overall state of mind of tweeple and how far the movie has come up good with the help of bar and pie chart. They can also get to know where the tweets of tweeple have originated from, the top most 10 frequency of occurrences of words found in the analysis and the word cloud. 

Proposed system has been designed to suit well with user’s device (either it could be a smartphone or a desktop). 

* Input data of this application would be the search term (with or without hastag), No. of tweets to use for analysis, language and (if the user wishes to see how many tweets been populated in an area) latitude and longitude of the place of tweets and the radius till how far the region should be covered. 
* Output will be in a graphical format with bar chart, pie chart and Open Street Maps (OSM). 

Both input and output have to be given in the shiny application. 

The concept of localization and Internationalization is also possible with the proposed system as the users can limit their region for fetching the tweets to be used in the analysis.  

Pre-processing of data includes tag elimination, splitting the paragraph into words, stop word removal, punctuation, digits, white spaces, stemming, http/ftp elimination, @ and retweet(RT) symbol. Tag elimination eliminates all the html tags in the input data then split the paragraph into separate words. Stop word removal is the process of removing noun, adjective, adverb. Stemming removes suffixes in the words. After pre-processing the raw data redundant words are removed. Proposed system also includes word’s frequency where the no of occurrence of the word is calculated.


![alt tag](https://github.com/SolomonAathiRaj/Sentiment-Analysis-and-Map-Viz-of-Tweets-/blob/master/images/sys_arch.png)
