

consumerKey <- "xxxxxxxxxxxxxxxxxxx"
consumerSecret <- "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  
accessToken <- "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
accessSecret <- "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

library(twitteR)
setup_twitter_oauth(consumer_key=consumerKey, consumer_secret=consumerSecret,
                    access_token=accessToken, access_secret=accessSecret)

# if setup_twitter_oauth throws error, re-install 'httr' package with dependencies specified true.

## USING LEXICON BASED APPROACH TO CLASSIFY THE EMOTIONS: POSITIVE, NEGATIVE, NEUTRAL.

# The algorithm misses out on the overall context of the tweet because it focuses on individual words. 
# This could be corrected using more complex sentiment scoring algorithms and taking context into account.

# However, for the purpose of performance measure we will determine using positive and negative lexicon lists 

library(twitteR)
some_tweets = searchTwitter("#TheRevenant", n=1500, lang="en")
some_tweets.df <- twListToDF(some_tweets)

library(RJSONIO)
some_tweets.json <- toJSON(some_tweets.df)
write(some_tweets.json,"TheRevenant.json")

lexicon <- read.csv("lexicon.csv", stringsAsFactors=F)
pos.words <- lexicon$word[lexicon$polarity=="positive"]
neg.words <- lexicon$word[lexicon$polarity=="negative"]

library(stringr)

# clean up sentences with R's regex-driven global substitute, gsub()

some_txt = sapply(some_tweets, function(x) x$getText())

some_txt = gsub('(f|ht)tp\\S+\\s*',"", some_txt)

tweets = iconv(some_txt,to="utf-8",sub="")

# remove retweet entities
some_txt = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", tweets)

# remove at people
some_txt = gsub("@\\w+", "", some_txt)

# remove punctuation
some_txt = gsub("[[:punct:]]", "", some_txt)

# remove numbers
some_txt = gsub("[[:digit:]]", "", some_txt)

# remove unnecessary spaces
some_txt = gsub("[ \t]{2,}", "", some_txt)

some_txt = gsub("^\\s+|\\s+$", "", some_txt)

some_txt = tolower(some_txt)

some_txt = iconv(gsub("\\n", " ", some_txt), to="ASCII", sub="")

# split into words: str_split is in the stringr package
word.list = strsplit(some_txt, " ") 
# function "classifier" (for the use of lexicon based approach) is written such that it works only if the 
# words are split

classify <- function(words, pos.words, neg.words){
  # count number of positive and negative word matches
  pos.matches <- sum(words %in% pos.words)
  neg.matches <- sum(words %in% neg.words)
  # return(pos.matches - neg.matches)
}

classifier <- function(text, pos.words, neg.words)
{
  # classifier
  # if score >0 positive, else negative
  scores <- unlist(lapply(text, classify, pos.words, neg.words))
  # no of tweets processed is 'n'
  n <- length(scores)
  # making the variables global "<<-"
  # how many tweets are positive & negative
  positive <<- as.integer(length(which(scores>0)))
  negative <<- as.integer(length(which(scores<0)))
  neutral <<- n - positive - negative
  cat(n, "tweets:", positive, "positive,",
      negative, "negative,", neutral, "neutral")
  
}

# applying classifier function
classifier(word.list, pos.words, neg.words)


critics <- data.frame(
  CRITICS = factor(c("Positive","Negative","Neutral"), levels=c("Positive","Negative","Neutral")), 
  SCORES = c(positive,negative,neutral))

critics$PERCENT = round((critics$SCORES/sum(critics$SCORES)) * 100,2)

# library(devtools)
# install_github("rCharts", "ramnathv")

library(rCharts)
# library(rNVD3)
n3 = nPlot(x = "CRITICS", y = "SCORES", data = critics, type = "pieChart")
n3$chart(tooltipContent = "#! function(key, y, e, graph){return '<h3>' + 'Category: ' + key + '</h3>' + '<p>'+ 'Value ' + y + '<br>' + ' % of value: ' + e.point.PERCENT} !#")
n3$set(width = 800, height = 500) # mk changed width to 800 and height to 500
#n3$chart(color = "#! function(d){ return 'blue'} !#")
#n3$chart(color = c('red', 'blue', 'green'))

n3$save('revenant_emotions_piechart.html', cdn=FALSE)

n3
