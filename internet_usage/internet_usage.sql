# By Joshua Kober, Data collected from ourworldindata.org

#Visual Take Aways
	# is Internet usage going up over time
	# is Annual Working hours going down over time
	# is there a correlation between internet usage and working hours
	# what is the GDP over time 
	# is there a correlation between internet usage and GDP
	# average population increase using the internet per year 
	# deaths from Obesity over time 
	# is there a correlation between internet usage and deaths by obesity

with internet as(
	select 
		iu.Country 
		, iu.Year_Date 
		, p.Population 
		, iu.Population_Percentage as Percentage_Using_Internet 
		, round(p.Population * iu.Population_Percentage,0) as Estimated_Population_Using_Internet
			# Calculate the Estimated Population using the internet
		, lag(iu.Population_Percentage,1) over(PARTITION by Country order by Country asc, Year_Date asc) as Percentage_Using_Internet_Last_Year
			#show the previous years' internet usage
		, lead(iu.Population_Percentage,1) over(PARTITION by Country order by Country asc, Year_Date asc) as Percentage_Using_Internet_Next_Year
			#show the next years' internet usage
		, awh.Annual_Working_Hours 
		, gpc.GDP_Per_Capita 
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
		, 
	from 
		internet i
)
select
	*
FROM 
	internet
;
	
	
	
	
