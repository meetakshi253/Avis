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

#searchTwitter("Samsung+Galaxy", from="user:name" n=2000, lan="en", until="YYYY-MM-DD", since="YYYY-MM-DD", geocode="latitude, longitude, radius", resultType="recent/popular/null(without quotes, mix of both)"); cannot exceed 14 days

tweets = searchTwitter("apple+iphone", n=2000, lan="en", geocode = "34.1,-118.2,250km") #LA

tweettext = sapply(tweets, function(tweets) tweets$getText())  #extract tweet text from the status class object "tweets".

#text cleaning

#1. convert from latin1 to ascii

tweettext = lapply(tweettext, function(x) iconv(x, "latin1", "ASCII", sub="")) #replace all non-recognized symbols with ''
tweettext = lapply(tweettext, function(x) gsub("?(f|ht)tp(s?)://(.*)[.][a-z]+","",x)) #remove all URLs (http/ftp/https) gsub()-global substitution
tweettext = lapply(tweettext, function(x) gsub("[A-Za-z]{1,5}[.][A-Za-z]{2,3}/[A-Za-z0-9]+\\b","",x)) #tiny urls
tweettext = lapply(tweettext, function(x) gsub("#","",x))  #remove all hashes  

#str = "Just bought a new apple iphone! check out http://www.apple.in and grab one 2day!"
#str = gsub("?(f|ht)tp(s?)://(.*)[.][a-z]+","",str)

#the sentiment lexicon from the working directory:

positiveLexicon = readLines("opinion-lexicon-English/positive-words.txt")
negativeLexicon = readLines("opinion-lexicon-English/negative-words.txt")

tweetdate = lapply(tweets, function(x) x$getCreated())
tweetdate = sapply(tweetdate, function(x) strftime(x, format="%Y-%m-%d %H-%M-%S", tz="UTC")) #format the dates
isretweet = sapply(tweets, function(x) x$getIsRetweet())
retweetcount = sapply(tweets, function(x) x$getRetweetCount())
#likecount = sapply(tweets, function(x) x$getFavouriteCount())

dataf = sentimentScoring(tweettext, positiveLexicon, negativeLexicon)
print(dataf)

finaldf = as.data.frame(cbind(tweet=tweettext, date=tweetdate, isretweet=isretweet, retweets=retweetcount, score=dataf$score, product="Apple iPhone", city="LA", country="USA")) #column bind and create dataframe
#remove duplicates
#finaldf %>% distinct(tweet)

duplicates = duplicated(finaldf$tweet)
finaldf$duplicated = duplicates
#print(finaldf)

#now create a csv file
write.csv(as.matrix(finaldf), "iphone_LA.csv")

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







