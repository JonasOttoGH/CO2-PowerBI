-- Questions to answer: 
--What is the total GHG/C02 responsibility (percentage) for each country?
--Does GDP influence GHG /CO2?
--What is the total yearly CO2 increase/decrease per country?
--What is the amount of GHG/C02 per Capita?

SELECT *
FROM [Climate].[dbo].['Climate Data']


;With CTE1 as (
SELECT country as [Country],
		year as [Year], 
		Continent,
		population as [Population],
		Cast(gdp as float) as [GDP],
		Cast(cement_co2 as float) as [Cement CO2],
		Cast(coal_co2 as float) as [Coal CO2],
		Cast(flaring_co2 as float) as [Flaring CO2], 
		Cast(gas_co2 as float) as [Gas CO2],
		Cast(oil_co2 as float) as [Oil CO2],
		land_use_change_co2 as [Land Use],
		CAST(methane as float) as [Methane], 
		CAST(nitrous_oxide as float) as [Nitrous Oxide],
		CAST(trade_co2 as float) as [Trade C02], 
		CAST(primary_energy_consumption as float) as [Enery Consumption]
FROM [Climate].[dbo].['Climate Data']
),


CTE2 as (
SELECT *, 
		COALESCE([Cement CO2],0) + COALESCE([Coal CO2],0) + COALESCE([Flaring CO2],0) + COALESCE([Gas CO2],0) + COALESCE([Oil CO2],0) as [Total CO2],
		COALESCE([Cement CO2],0) + COALESCE([Coal CO2],0) + COALESCE([Flaring CO2],0) + COALESCE([Gas CO2],0) + COALESCE([Oil CO2],0) + COALESCE([Trade C02],0) + COALESCE([Land Use],0) as [Total CO2 Inc]
FROM CTE1
),


CTE3 as ( 
SELECT *, 
		[Total CO2] + COALESCE([Methane],0) + COALESCE([Nitrous Oxide],0) as [Total GHG],
		[Total CO2 Inc] + COALESCE([Methane],0) + COALESCE([Nitrous Oxide],0) as [Total GHG Inc]	
					
FROM CTE2
),


SUMCTE as ( 
Select [Year] as [Year2], 
			SUM([Total CO2]) as [Global CO2],
			SUM([Methane]) as [Global Methane],
			SUM([Nitrous Oxide]) as [Global Nitrous Oxide],
			SUM([GDP]) as [Global GDP]
FROM CTE3
Group by [Year]
),


CTE4 as ( 
SELECT *,
		Coalesce(SUM([Total CO2]) OVER (partition by country order by year),0) as [Rolling CO2],
		Coalesce(SUM([Total CO2 Inc]) OVER (partition by country order by year),0) as [Rolling CO2 Inc],
		Coalesce(SUM([Total GHG]) OVER (partition by country order by year),0) as [Rolling GHG],
		Coalesce(SUM([Total GHG Inc]) OVER (partition by country order by year),0) as [Rolling GHG Inc],
		LAG([Total CO2]) OVER (partition by country order by year) as [Lagging CO2],
		[Total CO2] - LAG([Total CO2]) OVER (partition by country order by year) as [CO2 Change],
		LAG([Total GHG]) OVER (partition by country order by year) as [Lagging GHG],
		[Total GHG] - LAG([Total GHG]) OVER (partition by country order by year) as [GHG Change],
		([Total CO2]*1000000000)/Population as [CO2 Kg Civilan],
		([Total GHG]*1000000000)/Population as [GHG Kg Civilan],
		([Total CO2]/[Global CO2])*100 as  [CO2 Responsibility],
		(([Total CO2]*1000000000)/[GDP]) as [CO2 Kg Dollar],
		LAG([Global CO2]) OVER (Partition by Country order by [year]) as [Global Lag],
		[Global CO2] - LAG([Global CO2]) OVER (Partition by Country order by [year]) as [Global CO2 Change],
		(([Global CO2] - LAG([Global CO2]) OVER (Partition by Country order by [year]))/[Global CO2]) * 100 as [Global Percent]

from SUMCTE
 join CTE3
on CTE3.[Year] = SUMCTE.[Year2]
)				
SELECT *
FROM CTE4

