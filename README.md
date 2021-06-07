# Avis
Text Mining and Sentiment Analysis

*Harvesting tweets from Twitter for Samsung Galaxy and Apple iPhone from four cities-- London, Los Angeles, Delhi and New York. Perform opinion scoring and make stastical inferences.*

<strong> R </strong> <br>
<ul>
<li> Using OAuth for R-Twitter Handshake
<li> Scraping twitter using searchTwitter() in the twitteR package.
<li> Obtaining the text content of the tweets from the status class
<li> Text cleaning using regular expression with GSUB (removing URL, punctuation, control characters, digits and hashes)
<li> Opinion/Sentiment lexicon for matching each word against
<li> Bing Liu sentiment lexicon for scoring each hit. +1 for positive and -1 for negative
  <li> Identify copied subsequent tweets and create a dataframe.
<li> Format the dataframe and export it as a csv.
  </ul>
  
  
<br>
<strong> Tableau </strong> <br>
<ul>
<li> Import csv to Tableau
<li> Visualize (Screenshots in "Images")
<\ul> 
  
 <strong> Issues </strong> <br>
  <ul>
<li> Limited dataset because of Twitter's 14 days only scraping policy, therefore bias is possible.
<li> Text cleaning process may have removed keywords.
  <li> Does't accurately score questions, cynical and sarcastic tweets.
<\ul> 

