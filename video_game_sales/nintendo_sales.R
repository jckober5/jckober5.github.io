#data from https://www.kaggle.com/datasets/arslanali4343/sales-of-video-games
#This dataset contains a list of video games with sales greater than 100,000 copies. 
#The goal of this analysis is to see Nintendo's top selling games, top selling genres, top selling geographical areas, and if their sales for games launched has decreased over the years 

#Load formating and plotting packages 
library(plotly)
library(stringr)
library(jtools)
library(DT)
vgsales=read.csv(file.choose(),header=T,stringsAsFactors = F)

#Filter to see just games published by nintendo
nintendo = subset(vgsales,Publisher == 'Nintendo')
nintendo$Year = as.numeric(nintendo$Year)
#Plot the Top 10 Selling games
top = 10
top_games = aggregate(Global_Sales ~ Name, data = nintendo, sum) #aggregate total sales per game
top_games = top_games[order(top_games$Global_Sales,decreasing = TRUE),] #sort the games by top selling
top_games = head(top_games, top)

plot_ly(data = top_games,x =~ Name,y =~ Global_Sales,color =~ Name,mode = 'bar')%>%
  layout(title = 'Top Selling Games',
         plot_bgcolor = '#f5425a',
         yaxis = list(title = 'Global Sales'),
         xaxis = list(categoryorder = "total descending"))

#Plot the Top Selling Genres
top = 10
top_genres = aggregate(Global_Sales ~ Genre, data = nintendo, sum) #aggregate total sales per genre
top_genres = top_genres[order(top_genres$Global_Sales,decreasing = TRUE),] #sort the genres by top selling
top_genres = head(top_genres, top)

plot_ly(data = top_genres,x =~ Genre,y =~ Global_Sales,color =~ Genre,mode = 'bar')%>%
  layout(title = 'Top Selling Genres',
         plot_bgcolor = '#f5425a',
         yaxis = list(title = 'Global Sales'),
         xaxis = list(categoryorder = "total descending"))

#Plot the Sales by Region
na_sales = sum(nintendo$NA_Sales)
eu_sales = sum(nintendo$EU_Sales)
jp_sales = sum(nintendo$JP_Sales)
other_sales = sum(nintendo$Other_Sales)

world_sales = data.frame(Area = c('North America', 'Europe', 'Japan', 'Other'),
                         Sales = c(na_sales, eu_sales, jp_sales, other_sales))

plot_ly(data = world_sales,x =~ Area,y =~ Sales,color =~ Area,mode = 'bar')%>%
  layout(title = 'Region Sales',
         plot_bgcolor = '#f5425a',
         yaxis = list(title = 'Region Sales'),
         xaxis = list(categoryorder = "total descending", title = 'Region'))

#Plot the sales over the years per region
na_sales = aggregate(NA_Sales ~ Year, data = nintendo, sum)
eu_sales = aggregate(EU_Sales ~ Year, data = nintendo, sum)
jp_sales = aggregate(JP_Sales ~ Year, data = nintendo, sum)
other_sales = aggregate(Other_Sales ~ Year, data = nintendo, sum)
sales = merge(na_sales, eu_sales, by = 'Year')
sales = merge(sales, jp_sales, by = 'Year')
sales = merge(sales, other_sales, by = 'Year')

plot_ly(sales,x=~Year)%>%
  add_trace(y=~NA_Sales, name = 'North America Sales', mode = 'lines+markers')%>%
  add_trace(y=~EU_Sales, name = 'Europe Sales', mode = 'lines+markers')%>%
  add_trace(y=~JP_Sales, name = 'Japan Sales', mode = 'lines+markers')%>%
  add_trace(y=~Other_Sales, name = 'Other Sales', mode = 'lines+markers')%>%
  layout(title = 'Region Sales by Year',
         plot_bgcolor = '#f5425a')

#Run Regression model on the effects that Region, Genre, and Years has on the Sales of Nintendo's games
na_sales = data.frame(Name = nintendo$Name,
                      Platform = nintendo$Platform,
                      Year = nintendo$Year,
                      Genre = nintendo$Genre, 
                      Region = 'North America',
                      Sales = nintendo$NA_Sales)
eu_sales = data.frame(Name = nintendo$Name,
                      Platform = nintendo$Platform,
                      Year = nintendo$Year,
                      Genre = nintendo$Genre, 
                      Region = 'Europe',
                      Sales = nintendo$EU_Sales)
jp_sales = data.frame(Name = nintendo$Name,
                      Platform = nintendo$Platform,
                      Year = nintendo$Year,
                      Genre = nintendo$Genre,  
                      Region = 'Japan',
                      Sales = nintendo$JP_Sales)
other_sales = data.frame(Name = nintendo$Name,
                         Platform = nintendo$Platform,
                         Year = nintendo$Year,
                         Genre = nintendo$Genre,  
                          Region = 'Other',
                          Sales = nintendo$Other_Sales)
sales = rbind(na_sales, eu_sales, jp_sales, other_sales)
reg = glm(Sales ~ Region + Genre + Year, data = sales)
summ(reg)
#With a Pvalue set to be less than .05 to be significant, we can conclude that the following variables have a significant effect on sales
  #Releasing a game in North America increases sales by $0.57 million on average
  #Releasing a game in any other country outside of Japan, Europe, or North America decreases sales by $0.46 million on average
  #Releasing a game in the Platform Genre increases sales by $0.48 million on average.
  #Releasing a game in the Role Playing Genre increases sales by $0.27 million on average.
  #Releasing a game in the Sports Genre increases sales by $0.51 million on average.
  #Every year in the future is decreasing the estimated amount of sales for a game by $0.01 million on average.

#Has Nintendo stopped publishing Platform, Role Playing, and Sports genre games?
top_genres = subset(nintendo, Genre == 'Role-Playing'|
                      Genre == 'Platform'|
                      Genre == 'Sports')
top_genres$count = rep(1, nrow(top_genres))
top_genres = aggregate(count ~ Genre + Year, data = top_genres, sum)
plot_ly(data = top_genres,x =~ Year,y =~ count,color =~ Genre,mode = 'lines+markers')%>%
  layout(title = 'Top Genres Sales over the Years',
         plot_bgcolor = '#f5425a',
         xaxis = list(categoryorder = "total descending"))
#We have seen a drastic decrease in Sports and Platform Games in the last few years, this could be part of what's contributing to lower sales
  #As we increase released games in these genres we can expect a higher increase in sales by up to $0.51 million per game