#Read in the data from Kaggle https://www.kaggle.com/datasets/sefercanapaydn/mission-launches
library(ggplot2)
library(plotly)
library(stringr)
df=read.csv(file.choose(),header=T,stringsAsFactors = F)

#Clean and Build our Explanatory variables (Country, Year, Weekday, Price)
df$count = rep(1,nrow(df))

df$Country = word(df$Location,-1) #Grab the last word from the Location
ggplotly(ggplot(data = aggregate(count~Country,df,sum), aes(x=count, y=Country)) 
         + geom_col(fill='firebrick3', color = 'black')) #Filter any data from countries that had less than 30 launches

df$Year = as.numeric(substr(df$Date,13,16)) #Grab the Year from the date fields
ggplotly(ggplot(data = aggregate(count~Year,df,sum), aes(x=Year, y=count)) 
         + geom_line(color = 'black', size = 1.5)) #There isn't significant amount of data for years before 1960

df$Weekday = word(df$Date,1) #Grab the first word from the Date field
ggplotly(ggplot(data = aggregate(count~Weekday,df,sum), aes(x=count, y=Weekday)) 
         + geom_col(fill='firebrick3', color = 'black')) #There is over 200 Launches per weekday to gauge statistical significance

df$Price = as.numeric(df$Price)*1000000 #adjust the price to be in millions

#Build our Response Variable as Binary
df$Launch_Successful = ifelse(df$Mission_Status == 'Success', 1, 0)

#Build our Decision Tree
library(rpart)
library(rpart.plot)

# Predict a successful Launch/Mission based on Country, Year, Weekday, Price
space_tree = rpart(Launch_Successful ~ (Country + Year + Weekday + Price), 
                   data = df)
prp(space_tree,
    space = 4,
    nn.border.col = 0)
