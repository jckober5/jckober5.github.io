# By Joshua Kober, Data collected from ourworldindata.org
	#Data Cleaning and Prep 

#Visual Take Aways
	# is Internet usage going up over time
	# is Annual Working hours going down over time
	# is there a correlation between internet usage and working hours
	# what is the GDP over time 
	# is there a correlation between internet usage and GDP
	# average population increase using the internet per year 
	# deaths from Obesity over time 
	# is there a correlation between internet usage and deaths by obesity

create or replace view data_projects.vw_internet_usage_effects as(
	with internet as(
		select 
			iu.Country 
			, iu.Year_Date 
			, p.Population 
			, lag(p.Population,1) over(PARTITION by Country order by Country asc, Year_Date asc) as Population_Last_Year
				#show the previous years' population
			, iu.Population_Percentage/100 as Percentage_Using_Internet 
				#Divide by 100 to change to percentage
			, lag(iu.Population_Percentage/100,1) over(PARTITION by Country order by Country asc, Year_Date asc) as Percentage_Using_Internet_Last_Year
				#show the previous years' internet usage
			, round(p.Population * (iu.Population_Percentage/100),0) as Estimated_Population_Using_Internet
				# Calculate the Estimated Population using the internet
			, lag(round(p.Population * (iu.Population_Percentage/100),0),1) over(PARTITION by Country order by Country asc, Year_Date asc) as Estimated_Population_Using_Internet_Last_Year
				#show the previous years' internet usage est Population
			, awh.Annual_Working_Hours 
			, lag(awh.Annual_Working_Hours,1) over(PARTITION by Country order by Country asc, Year_Date asc) as Annual_Working_Hours_Last_Year
				#show the previous years' internet usage
			, gpc.GDP_Per_Capita 
			, lag(gpc.GDP_Per_Capita,1) over(PARTITION by Country order by Country asc, Year_Date asc) as GDP_Per_Capita_Last_Year
				#show the previous years' internet usage
			, o.Deaths_By_Obesity 
			, lag(o.Deaths_By_Obesity,1) over(PARTITION by Country order by Country asc, Year_Date asc) as Deaths_By_Obesity_Last_Year
				#show the previous years' internet usage
		from 
			data_projects.Internet_Usage iu #5477 rows
		left join data_projects.Population p 
			on iu.Country = p.Country 
			and iu.Year_Date = p.Year_Date 
		left join data_projects.Annual_Work_Hours awh 
			on iu.Country = awh.Country 
			and iu.Year_Date = awh.Year_Date
		left join data_projects.GDP_Per_Capita gpc 
			on iu.Country = gpc.Country 
			and iu.Year_Date = gpc.Year_Date 
		left join data_projects.Obesity o 
			on iu.Country = o.Country 
			and iu.Year_Date = o.Year_Date 
	)
	, increase as (
		select 
			i.Country
			, i.Year_Date 
			, i.Population 
			, i.Population - i.Population_Last_Year as Population_Increase
				#What was the increase in population
			, avg(i.Population - i.Population_Last_Year) over(partition by Country) as Avg_Population_Increase
				#What is the average increase we see in population
			, i.Percentage_Using_Internet
			, i.Percentage_Using_Internet - i.Percentage_Using_Internet_Last_Year as Percentage_Using_Internet_Increase
				#What was the increase in percentage to the population using internet
			, avg(i.Percentage_Using_Internet - i.Percentage_Using_Internet_Last_Year) over(partition by Country) as Avg_Percentage_Using_Internet_Increase
				#What is the average increase we see in countries using the internet
			, i.Estimated_Population_Using_Internet
			, i.Estimated_Population_Using_Internet - i.Estimated_Population_Using_Internet_Last_Year as Estimated_Population_Using_Internet_Increase
				#What was the increase in Estimation to the population using internet
			, avg(i.Estimated_Population_Using_Internet - i.Estimated_Population_Using_Internet_Last_Year) over(partition by Country) as Avg_Estimated_Population_Using_Internet_Increase
				#What is the average increase we see in countries using the internet
			, i.Annual_Working_Hours 
			, i.Annual_Working_Hours - i.Annual_Working_Hours_Last_Year as Annual_Working_Hours_Increase
				#What was the increase in percentage to the population using internet
			, avg(i.Annual_Working_Hours - i.Annual_Working_Hours_Last_Year) over(partition by Country) as Avg_Annual_Working_Hours_Increase
				#What is the average increase we see in countries Annual Work Hours
			, i.GDP_Per_Capita 
			, i.GDP_Per_Capita - i.GDP_Per_Capita_Last_Year as GDP_Per_Capita_Increase
				#What was the increase in percentage to the population using internet
			, avg(i.GDP_Per_Capita - i.GDP_Per_Capita_Last_Year) over(partition by Country) as Avg_GDP_Per_Capita_Increase
				#What is the average increase we see in countries GDP
			, i.Deaths_By_Obesity 
			, i.Deaths_By_Obesity - i.Deaths_By_Obesity_Last_Year as Deaths_By_Obesity_Increase
				#What was the increase in percentage to the population using internet
			, avg(i.Deaths_By_Obesity - i.Deaths_By_Obesity_Last_Year) over(partition by Country) as Avg_Deaths_By_Obesity_Increase
				#What is the average increase we see in countries Death rate from Obesity
		from 
			internet i
	)
	select
		*
	FROM 
		increase
	order by 1,2
)
;
	
	
	
	
