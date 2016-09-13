
shinyServer(function(input, output, session) {
  
  
  library(twitteR)
  library(ROAuth)
  
  library(httr)
  
  
  consumerKey <- "xxxxxxxxxxxxxxxxxx"
  consumerSecret <- "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"    
  accessToken <- "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  accessSecret <- "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  requestURL <- "https://api.twitter.com/oauth/request_token"
  accessURL <- "https://api.twitter.com/oauth/access_token"
  authURL <- "https://api.twitter.com/oauth/authorize"
  
  options(httr_oauth_cache = TRUE) 
  setup_twitter_oauth(consumer_key = consumerKey, consumer_secret = consumerSecret, access_token = accessToken, access_secret = accessSecret)
  
  output$n1Text <- renderText({ 
    paste("Topic of the analysis:", input$searchkw)
  })
  
 
   TweetFrame<-function(searchTerm, maxTweets,language)
   { 
      
    twtList <- searchTwitter(searchTerm, n=maxTweets, lang = "en")
   
    twtList.df <- twListToDF(twtList)
    twtListText = sapply(twtList, function(x) x$getText())
    return(twtListText)
    
  }
  
  entity1<- eventReactive(input$actb, {
    
    progress <- shiny::Progress$new(session, min=1, max=15)
         on.exit(progress$close())
     
         progress$set(message = 'Cleaning the tweets')
         
     
         for (i in 1:15) {
           progress$set(value = i)
           Sys.sleep(0.5)
         }
    
    entity1<-TweetFrame(input$searchkw, input$nt, lang = "en")
    
    entity1
      })
  
  
  CleanTweets<-function(some_txt)
  {
    
    
    # clean up sentences with R's regex-driven global substitute, gsub()
    some_txt = gsub('(f|ht)tp\\S+\\s*',"", some_txt)
    
    some_txt = iconv(some_txt,to="utf-8",sub="")
    
    # remove retweet entities
    some_txt = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", some_txt)
    
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
    
    # remove NAs in some_txt
    some_txt = some_txt[!is.na(some_txt)]
    names(some_txt) = NULL
   
    return(some_txt)
    
  }
  
  entity2 <- eventReactive(input$actb, {
 
    progress <- shiny::Progress$new(session, min=1, max=15)
    on.exit(progress$close())
    
    progress$set(message = 'Fetching the requested no. of tweets')
    
    for (i in 1:15) {
      progress$set(value = i)
      Sys.sleep(0.5)
    }
    entity2 <- CleanTweets(entity1())
    
    entity2
  })
  
  RecentTweetFrame1 <- function(searchTerm, maxTweets,language)
  { 
    
    twtList <- searchTwitter(searchTerm, n=maxTweets, lang = "en")
    
    twtList.df <- twListToDF(twtList)
    
    return(twtList.df)
    
  }
  
  rtEntity1 <- eventReactive(input$actb,{
    
    rtEntity1<- RecentTweetFrame1(input$searchkw, input$nt, lang = "en")
    
    rtEntity1
  })
  
  tw_top5_entry_01 <- eventReactive(input$actb,{
    
    
      tw_top5 <- rtEntity1()
#       x <- c()
#       
#       for(i in seq(from=1, to=input$nt, by=1))
#       {
#         
#         if((twt_top5[i,12])!=0)
#         {
#           twtT <- twt_top5[i,1]
#           twtU <- twt_top5[i,11]
#           twt <- cbind(twtU,twtT)
#           colnames(twt) <- c("User Name","Tweets")
#           twts <- rbind(twt,x)
#           x <- twts
#         }
#         
#       }
#       
#       print(twts)
#       return(twts)
      
      tw_top5 <-  tw_top5[ order(-tw_top5[,12]), ] #descending order
      tw_top5 <- unique( tw_top5[ , 1:16 ] )
      
      tw_top5u <- as.data.frame(head(tw_top5[,11]))
      tw_top5t <- as.data.frame(head(tw_top5[,1]))
      tw_top5rt <- as.data.frame(head(tw_top5[,12]))
      
      tw_top5 <- cbind(tw_top5u,tw_top5t,tw_top5rt)
      colnames(tw_top5) <- c("User Name","Tweets", "Retweet Count")
      tw_top5
      
    
  })
  
  output$recentTweets1 <- renderTable(tw_top5_entry_01())
  
  create_matrix <- function(textColumns, language="english", minDocFreq=1, minWordLength=3, removeNumbers=TRUE, removePunctuation=TRUE, removeSparseTerms=0, removeStopwords=TRUE, stemWords=FALSE, stripWhitespace=TRUE, toLower=TRUE, weighting=weightTf) {
    
    stem_words <- function(x) {
      split <- strsplit(x," ")
      return(wordStem(split[[1]],language=language))
    }
    
    control <- list(language=language,tolower=toLower,removeNumbers=removeNumbers,removePunctuation=removePunctuation,stripWhitespace=stripWhitespace,minWordLength=minWordLength,stopwords=removeStopwords,minDocFreq=minDocFreq,weighting=weighting)
    
    if (stemWords == TRUE) control <- append(control,list(stemming=stem_words),after=6)
    
    trainingColumn <- apply(as.matrix(textColumns),1,paste,collapse=" ")
    trainingColumn <- sapply(as.vector(trainingColumn,mode="character"),iconv,to="UTF8",sub="byte")
    
    corpus <- Corpus(VectorSource(trainingColumn),readerControl=list(language=language))
    matrix <- DocumentTermMatrix(corpus,control=control);
    if (removeSparseTerms > 0) matrix <- removeSparseTerms(matrix,removeSparseTerms)
    
    gc()
    return(matrix)
  }
  
  classify_emotion <- function(textColumns,algorithm="bayes",prior=1.0,verbose=FALSE,...) {
    matrix <- create_matrix(textColumns,...)
    lexicon <- read.csv("emotions.csv",header=FALSE)
    
    counts <- list(anger=length(which(lexicon[,2]=="anger")),disgust=length(which(lexicon[,2]=="disgust")),fear=length(which(lexicon[,2]=="fear")),joy=length(which(lexicon[,2]=="joy")),sadness=length(which(lexicon[,2]=="sadness")),surprise=length(which(lexicon[,2]=="surprise")),total=nrow(lexicon))
    documents <- c()
    
    for (i in 1:nrow(matrix)) {
      if (verbose) print(paste("DOCUMENT",i))
      scores <- list(anger=0,disgust=0,fear=0,joy=0,sadness=0,surprise=0)
      doc <- matrix[i,]
      words <- findFreqTerms(doc,lowfreq=1)
      
      for (word in words) {
        for (key in names(scores)) {
          emotions <- lexicon[which(lexicon[,2]==key),]
          index <- pmatch(word,emotions[,1],nomatch=0)
          if (index > 0) {
            entry <- emotions[index,]
            
            category <- as.character(entry[[2]])
            count <- counts[[category]]
            
            score <- 1.0
            if (algorithm=="bayes") score <- abs(log(score*prior/count))
            
            if (verbose) {
              print(paste("WORD:",word,"CAT:",category,"SCORE:",score))
            }
            
            scores[[category]] <- scores[[category]]+score
          }
        }
      }
      
      if (algorithm=="bayes") {
        for (key in names(scores)) {
          count <- counts[[key]]
          total <- counts[["total"]]
          score <- abs(log(count/total))
          scores[[key]] <- scores[[key]]+score
        }
      } else {
        for (key in names(scores)) {
          scores[[key]] <- scores[[key]]+0.000001
        }
      }
      
      best_fit <- names(scores)[which.max(unlist(scores))]
      if (best_fit == "disgust" && as.numeric(unlist(scores[2]))-3.09234 < .01) best_fit <- NA
      documents <- rbind(documents,c(scores$anger,scores$disgust,scores$fear,scores$joy,scores$sadness,scores$surprise,best_fit))
    }
    
    colnames(documents) <- c("ANGER","DISGUST","FEAR","JOY","SADNESS","SURPRISE","BEST_FIT")
    return(documents)
  }
  
  
  ClassifyEmotion <- function(CleanedTweets)
    
  {
      ## USING SENTIMENT PACKAGE
      # classify emotion
      class_emo = classify_emotion(CleanedTweets, algorithm="bayes", prior=1.0)
      # get emotion best fit
      emotion = class_emo[,7]
      # substitute NA's by "unknown"
      emotion[is.na(emotion)] = "no sentiments"
    
      return(emotion)
      
  }
  
  entity3 <- eventReactive(input$actb, {
    
    progress <- shiny::Progress$new(session, min=1, max=15)
    on.exit(progress$close())
    
    progress$set(message = 'Categorizing the emotions')
    
    for (i in 1:15) {
      progress$set(value = i)
      Sys.sleep(0.5)
    }
    
    entity3 <- ClassifyEmotion(entity2())
    
    entity3
    
  })
  
  classify_polarity <- function(textColumns,algorithm="bayes",pstrong=0.5,pweak=1.0,prior=1.0,verbose=FALSE,...) {
    matrix <- create_matrix(textColumns,...)
    lexicon <- read.csv("subjectivity.csv",header=FALSE)
    
    counts <- list(positive=length(which(lexicon[,3]=="positive")),negative=length(which(lexicon[,3]=="negative")),total=nrow(lexicon))
    documents <- c()
    
    for (i in 1:nrow(matrix)) {
      if (verbose) print(paste("DOCUMENT",i))
      scores <- list(positive=0,negative=0)
      doc <- matrix[i,]
      words <- findFreqTerms(doc,lowfreq=1)
      
      for (word in words) {
        index <- pmatch(word,lexicon[,1],nomatch=0)
        if (index > 0) {
          entry <- lexicon[index,]
          
          polarity <- as.character(entry[[2]])
          category <- as.character(entry[[3]])
          count <- counts[[category]]
          
          score <- pweak
          if (polarity == "strongsubj") score <- pstrong
          if (algorithm=="bayes") score <- abs(log(score*prior/count))
          
          if (verbose) {
            print(paste("WORD:",word,"CAT:",category,"POL:",polarity,"SCORE:",score))
          }
          
          scores[[category]] <- scores[[category]]+score
        }		
      }
      
      if (algorithm=="bayes") {
        for (key in names(scores)) {
          count <- counts[[key]]
          total <- counts[["total"]]
          score <- abs(log(count/total))
          scores[[key]] <- scores[[key]]+score
        }
      } else {
        for (key in names(scores)) {
          scores[[key]] <- scores[[key]]+0.000001
        }
      }
      
      best_fit <- names(scores)[which.max(unlist(scores))]
      ratio <- as.integer(abs(scores$positive/scores$negative))
      if (ratio==1) best_fit <- "neutral"
      documents <- rbind(documents,c(scores$positive,scores$negative,abs(scores$positive/scores$negative),best_fit))
      if (verbose) {
        print(paste("POS:",scores$positive,"NEG:",scores$negative,"RATIO:",abs(scores$positive/scores$negative)))
        cat("\n")
      }
    }
    
    colnames(documents) <- c("POS","NEG","POS/NEG","BEST_FIT")
    return(documents)
  }
  
  ClassifyPolarity <- function(CleanedTweets)
    
  {
      # classify polarity
      class_pol = classify_polarity(CleanedTweets, algorithm="bayes")
      # get polarity best fit
      polarity = class_pol[,4]
  
      return(polarity)
      
    
  } 
  
  entity4 <- eventReactive(input$actb, {
 
    progress <- shiny::Progress$new(session, min=1, max=15)
    on.exit(progress$close())
    
    progress$set(message = 'Rendering the sentiment plot')
    
    for (i in 1:15) {
      progress$set(value = i)
      Sys.sleep(0.5)
    }
    
    entity4 <- ClassifyPolarity(entity2())
    
    entity4
  })
  
  SentDf <- function(cleanedText,ClassifiedEmo,ClassifiedPol)
  {
   
      snt_df = data.frame(text=cleanedText, emotion=ClassifiedEmo,
                          polarity=ClassifiedPol, stringsAsFactors=FALSE)
      
      return(snt_df)
  
  }
  
  entity5<- eventReactive(input$actb, {
  
    entity5 <- SentDf(entity2(),entity3(),entity4())
    entity5
    
  })
  
  
  PartitionSent1 <- function(sentdf)
  {
      sent_df <- sentdf
      
     
      table(sent_df$emotion)
      total.processed <- sum(table(sent_df$emotion))
      
      
      num_uk <- table(sent_df$emotion == 'no sentiments')['TRUE']
      num_joy <- table(sent_df$emotion == 'joy')['TRUE']
      num_anger <- table(sent_df$emotion == 'anger')['TRUE']
      num_sad <- table(sent_df$emotion == 'sadness')['TRUE']
      num_surp <- table(sent_df$emotion == 'surprise')['TRUE']
      num_fear <- table(sent_df$emotion == 'fear')['TRUE']
      num_disgust <- table(sent_df$emotion == 'disgust')['TRUE']
      
      
      no_uk <- as.vector(num_uk)
      no_joy <- as.vector(num_joy)
      no_anger <- as.vector(num_anger)
      no_sad <- as.vector(num_sad)
      no_surp <- as.vector(num_surp)
      no_fear <- as.vector(num_fear)
      no_disgust <- as.vector(num_disgust)
      
      
      final_df <-  data.frame(
        Emotion = factor(c("Joy","Anger","Sadness","Surprise","Fear","Disgust"), levels=c("Joy","Anger","Sadness","Surprise","Fear","Disgust")),
        No.of.Tweets.Processed = c(no_joy,no_anger,no_sad,no_surp,no_fear,no_disgust)
      )
      print(final_df)
      return(final_df)
      
  }
  
  entity6 <- eventReactive(input$actb, {
    
    entity6<- PartitionSent1(entity5())
    
    entity6
  })
  
  PartitionSent2 <- function(sentdf){
    
    sent_df <- sentdf
    
    table(sent_df$polarity)
    num_pos <- table(sent_df$polarity == 'positive')['TRUE']
    num_neg <- table(sent_df$polarity == 'negative')['TRUE']
    num_neu <- table(sent_df$polarity == 'neutral')['TRUE']
    
    
    no_pos <- as.vector(num_pos)
    no_neg<- as.vector(num_neg)
    no_neu <- as.vector(num_neu)
    
    final_df_critics <-  data.frame(
      critics = factor(c("Positive","Negative","Neutral"), levels=c("Positive","Negative","Neutral")), 
      No.of.Tweets.Processed = c(no_pos,no_neg,no_neu)
    )
    
    return(final_df_critics)
    
  }
  
  entity7 <- eventReactive(input$actb, {
    
    entity7<- PartitionSent2(entity5())
    entity7
  })
  
  
  twtWithSentiment <- function(sentdf){
    
    sent_df <- sentdf
    table(sent_df$emotion)
    total.processed <- sum(table(sent_df$emotion))
    num_uk <- table(sent_df$emotion == 'no sentiments')['TRUE']
    no_uk <- as.vector(num_uk)
    twtWithSent <- (total.processed - no_uk)
    
    
    
    return(twtWithSent)
  }
  
  entity8<- eventReactive(input$actb,{
    entity8 <- twtWithSentiment(entity5())
    entity8
  })
  
  
  
  output$n2Text <- renderText({
    paste0("Tweets with sentiments (in fetched):", entity8())
  })
  
  output$Chart1 <- renderChart2({
    
   dbc <- nPlot(
      x = "Emotion", y = "No.of.Tweets.Processed", data = entity6(),
      type = "discreteBarChart", width = 700
    )
    
     
    
    # adding style to the chart - not necessary
    dbc$xAxis(axisLabel = "Emotion Categories")
    dbc$yAxis(axisLabel = "No of tweets with sentiments")
  
    
    return(dbc)
    
  })  
  
  output$Chart2 <- renderChart2({
    
    pc <- nPlot(
      x = "critics", y = "No.of.Tweets.Processed", data = entity7(),
      type = "pieChart", width = 600
    )
    
    pc
    
    
  })
  
  wcfunc <- function(cleanedTweets)
  {
    
    some_txt <- cleanedTweets
    
    docs <- Corpus(VectorSource(some_txt))
    
    # Corpus is a list of a document (in our case, we only have one document).
    # VectorSource() function creates a corpus of character vectors
    
    # Remove english common stopwords
    docs <- tm_map(docs, removeWords, stopwords("english"))
    
    # Eliminate extra white spaces
    docs <- tm_map(docs, stripWhitespace)
    
    # Text stemming
    #<- tm_map(docs, stemDocument)
    
    dtm <- TermDocumentMatrix(docs)
    m <- as.matrix(dtm)
    v <- sort(rowSums(m),decreasing=TRUE)
    d <- data.frame(word = names(v),freq=v)
    #head(d, 10)
    
    set.seed(1) #everytime while running the code, the position of words in the wc changes. To reproduce
    #the same, use set.seed()
    #wordcloud(d$word, d$freq, max.words = 200, random.order=FALSE, 
    #          colors=brewer.pal(8, "Dark2"))

    return (d)
    
    
  }
  
  entity9 <- eventReactive(input$actb,{
    
    entity9 <- wcfunc(entity2())
    entity9
    
  })
  
  output$plotwc <- renderPlot({
    
    wordcloud(entity9()$word,entity9()$freq,c(8,0.3),input$minf,input$maxnw,TRUE,0.15,use.r.layout=FALSE,colors=brewer.pal(8, "Dark2"))
    
  })

  
  freqOccfunc1 <- function(cleanedTweets)
  {
    
    some_txt <- cleanedTweets
    
    docs <- Corpus(VectorSource(some_txt))
    
    # Corpus is a list of a document (in our case, we only have one document).
    # VectorSource() function creates a corpus of character vectors
    
    # Remove english common stopwords
    docs <- tm_map(docs, removeWords, stopwords("english"))
    
    # Eliminate extra white spaces
    docs <- tm_map(docs, stripWhitespace)
    
    # Text stemming
    #<- tm_map(docs, stemDocument)
    
    dtm <- TermDocumentMatrix(docs)
    m <- as.matrix(dtm)
    v <- sort(rowSums(m),decreasing=TRUE)
    d <- data.frame(word = names(v),freq=v)
    #head(d, 10)
    
    set.seed(1) #everytime while running the code, the position of words in the wc changes. To reproduce
    #the same, use set.seed()
    #wordcloud(d$word, d$freq, max.words = 200, random.order=FALSE, 
    #          colors=brewer.pal(8, "Dark2"))
    
    return (d[1:10,]$word)
    }
  
  entity10 <- eventReactive(input$actb,{
    entity10 <- freqOccfunc1(entity2())
    entity10
  })
  
  freqOccfunc2 <- function(cleanedTweets)
  {
    
    some_txt <- cleanedTweets
    
    docs <- Corpus(VectorSource(some_txt))
    
    # Corpus is a list of a document (in our case, we only have one document).
    # VectorSource() function creates a corpus of character vectors
    
    # Remove english common stopwords
    docs <- tm_map(docs, removeWords, stopwords("english"))
    
    # Eliminate extra white spaces
    docs <- tm_map(docs, stripWhitespace)
    
    # Text stemming
    #<- tm_map(docs, stemDocument)
    
    dtm <- TermDocumentMatrix(docs)
    m <- as.matrix(dtm)
    v <- sort(rowSums(m),decreasing=TRUE)
    d <- data.frame(word = names(v),freq=v)
    #head(d, 10)
    
    set.seed(1) #everytime while running the code, the position of words in the wc changes. To reproduce
    #the same, use set.seed()
    #wordcloud(d$word, d$freq, max.words = 200, random.order=FALSE, 
    #          colors=brewer.pal(8, "Dark2"))
    
    return (d[1:10,]$freq)
  }
  
  entity11 <- eventReactive(input$actb,{
    entity11 <- freqOccfunc2(entity2())
    entity11
  })
  
  freqOccDF <- function(wrd,freq)
  {
    word_df <- data.frame(Words = wrd , Occurence=freq)
    return(word_df)
  }
  
  entity12 <- eventReactive(input$actb,{
    
    entity12 <- freqOccDF(entity10(),entity11())
    entity12
  })
    
  output$Chart3 <- renderChart2({
    
    
    dbc <- nPlot(
      x = "Words", y = "Occurence", data = entity12(),
      type = "discreteBarChart", width = 1000
    )
    
    
    # adding style to the chart - not necessary
    dbc$xAxis( axisLabel = "Top 10 occurrences of the words")
    dbc$yAxis( axisLabel = "Frequency of Occurrence")
    
    dbc
  })

    mapPlot <- eventReactive(input$mapit,{
      
      progress <- shiny::Progress$new(session, min=1, max=15)
      on.exit(progress$close())
      
      progress$set(message = 'Rendering the leaflet map to visualize')
      
      for (i in 1:15) {
        progress$set(value = i)
        Sys.sleep(0.5)
      }
      
      searchTerm <- input$k
      maxTweets <- input$n
      lat <- input$lat
      long <- input$long
      rad <- input$rad
      
      mapTweets <- searchTwitteR(searchString =  searchTerm, 
                                 n = maxTweets, 
                                 lang = "en", 
                                 geocode = paste(lat, long, paste0(rad, "mi"),sep=","))
      
      mapTweets.df <- twListToDF(mapTweets)
      
      return(mapTweets.df)
      
    })

    output$mymap <- renderLeaflet({
        
        entity13 <- mapPlot()
        ## Remove NAs
        entity13 <- entity13[!is.na(entity13$longitude), ]
        
        leaflet() %>% 
          addTiles() %>%
          addMarkers(data = entity13, lng = entity13$longitude, lat = entity13$latitude, popup = entity13$screenName) %>%
          setView(lng = input$long, lat = input$lat , zoom = 4)
        
    })

  
}) 
  

  


