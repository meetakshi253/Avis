library(twitteR)
library(httr)
library(RCurl)
library(ROAuth)
library(stringr)
library(plyr)
library(dplyr)

##From the Twitter Developers account

key = "uVUrPVgppvaJcembajqnCZevS"
secret = "64JBfqZhdHrJscnFqhPGcwDzDsOx4rJuDyoG9O09dpMJTRE1ck"
atoken = "1400938977532600325-GZBLFQM2FVIajWvIntpz5ElVKfk8FV"
asecret = "KpKFFQp6xVSeVNGfLBY2eoN13gke8MNvnzW8252lXov70"

setup_twitter_oauth(key, secret, atoken, asecret)

HarvestTweets = function(geocodee, city, country, searchterm, product, filename)
{
  
  tweets = searchTwitter(searchterm, n=2000, lan="en", geocode = geocodee)
  
  tweettext = sapply(tweets, function(tweets) tweets$getText())  #extract tweet text from the status class object "tweets".
  
  #text cleaning
  
  tweettext = lapply(tweettext, function(x) iconv(x, "latin1", "ASCII", sub="")) #replace all non-recognized symbols with ''
  tweettext = lapply(tweettext, function(x) gsub("?(f|ht)tp(s?)://(.*)[.][a-z]+","",x)) #remove all URLs (http/ftp/https) gsub()-global substitution
  tweettext = lapply(tweettext, function(x) gsub("[A-Za-z]{1,5}[.][A-Za-z]{2,3}/[A-Za-z0-9]+\\b","",x)) #tiny urls
  tweettext = lapply(tweettext, function(x) gsub("#","",x))  #remove all hashes 
  tweettext = lapply(tweettext, function(x) gsub("[\r\n]", " ", x))
  tweettext = lapply(tweettext, function(x) gsub(",","",x))
  
  #the sentiment lexicon from the working directory:
  
  positiveLexicon = readLines("opinion-lexicon-English/positive-words.txt")
  negativeLexicon = readLines("opinion-lexicon-English/negative-words.txt")
  
  tweetdate = lapply(tweets, function(x) x$getCreated())
  tweetdate = sapply(tweetdate, function(x) strftime(x, format="%Y-%m-%d %H:%M:%S", tz="UTC")) #format the dates
  isretweet = sapply(tweets, function(x) x$getIsRetweet())
  retweetcount = sapply(tweets, function(x) x$getRetweetCount())
  #likecount = sapply(tweets, function(x) x$getFavouriteCount())
  
  dataf = sentimentScoring(tweettext, positiveLexicon, negativeLexicon)
  #print(dataf)
  
  finaldf = as.data.frame(cbind(Tweet=tweettext, Date=tweetdate, Isretweet=isretweet, Retweets=retweetcount, Score=dataf$score, Product=product, City=city, Country=country)) #column bind and create dataframe
  #remove duplicates
  #finaldf %>% distinct(tweet)
  
  #duplicates = duplicated(finaldf$tweet)
  duplicates = duplicated(finaldf[,1])
  finaldf$duplicate = duplicates
  print(as.matrix(finaldf))
  
  #now create a csv file
  write.csv(as.matrix(finaldf), filename, quote = c(1,2))
  #finaldf <- apply(finaldf,2,as.character)
  #write.csv(finaldf, file=filename,row.names = FALSE)
}

sentimentScoring = function(tweets, positiveLexicon, negativeLexicon, .progress="none")
{
  tweetscore = laply(tweets, function(tweet, positiveLexicon, negativeLexicon) 
    {
    tweet = gsub("[[:cntrl:]]", "", tweet)  #remove control chr
    #tweet = gsub("[^[:alnum:]]", "",tweet)  
    tweet = gsub("//d", "",tweet) 
    tweet = gsub("[[:punct:]]","", tweet)   #remove punctuation
    tweet = convertToLowerCase(tweet)
    tweet = sapply(tweet, convertToLowerCase)
    wordslist = str_split(tweet, "\\s+")  
    extractedText =unlist(wordslist)
    print(extractedText)
    
    positiveMatches = !is.na(match(extractedText, positiveLexicon))
    negativeMatches = !is.na(match(extractedText, negativeLexicon))
    
    score = sum(positiveMatches)-sum(negativeMatches)
    return(score)
    }, positiveLexicon, negativeLexicon, .progress=.progress)
  
  sentimentscores.df = data.frame(text=tweets, score=tweetscore)
  return(sentimentscores.df)
}

convertToLowerCase = function(tweet)    #since there can be many unrecognised characters, we needed try catch to ensure theek se conversion
{
  lo = NA
  trye = tryCatch(tolower(tweet), error=function(e)e)
  if(!inherits(trye, "error"))
  {
    lo = tolower(tweet)
  }
  return (lo)
}


HarvestTweets("34.1,-118.2,240km", "LA", "USA", "apple+iphone", "Apple iPhone", "iphoneLA.csv")
HarvestTweets("34.1,-118.2,240km", "LA", "USA", "samsung+galaxy", "Samsung Galaxy", "galaxyLA.csv")
HarvestTweets("40.712776,-74.005974,240km", "NYC", "USA", "apple+iphone", "Apple iPhone", "iphoneNY.csv")
HarvestTweets("40.712776,-74.005974,240km", "NYC", "USA", "samsung+galaxy", "Samsung Galaxy", "galaxyNY.csv")
HarvestTweets("28.704060,77.102493,240km", "Delhi", "India", "apple+iphone", "Apple iPhone", "iphoneDelhi.csv")
HarvestTweets("28.704060,77.102493,240km", "Delhi", "India", "samsung+galaxy", "Samsung Galaxy", "galaxyDelhi.csv")
HarvestTweets("51.507351,-0.127758,240km", "London", "UK", "apple+iphone", "Apple iPhone", "iphoneLondon.csv")
HarvestTweets("51.507351,-0.127758,240km", "London", "UK", "samsung+galaxy", "Samsung Galaxy", "galaxyLondon.csv")
HarvestTweets("43.653225,-79.383186,240km", "Toronto", "Canada", "apple+iphone", "Apple iPhone", "iphoneToronto.csv")
HarvestTweets("43.653225,-79.383186,240km", "Toronto", "Canada", "samsung+galaxy", "Samsung Galaxy", "galaxyToronto.csv")

#tweets = searchTwitter("apple+iphone", n=2000, lan="en", geocode = ) #Toronto
#tweets = searchTwitter("apple+iphone", n=2000, lan="en", geocode = ) #Delhi
#tweets = searchTwitter("apple+iphone", n=2000, lan="en", geocode = "51.507351,-0.127758,240km") #London
#tweets = searchTwitter("samsung+galaxy", n=2000, lan="en", geocode = "34.1,-118.2,240km") #LA
#tweets = searchTwitter("samsung+galaxy", n=2000, lan="en", geocode = "43.653225,-79.383186.2,240km") #Toronto
#tweets = searchTwitter("samsung+galaxy", n=2000, lan="en", geocode = "28.704060,77.102493,240km") #Delhi
#tweets = searchTwitter("samsung+galaxy", n=2000, lan="en", geocode = "51.507351,-0.127758,240km") #London




