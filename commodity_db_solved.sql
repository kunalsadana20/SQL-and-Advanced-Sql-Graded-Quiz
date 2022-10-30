use commodity_db;

/**
Get the common commodities between the TOP 10 costliest commodities of 2019 and 2020
**/
WITH TOP10_2019 AS
(
	SELECT commodity_id,
			MAX(Retail_price) as Max_price,
			Year(Date) as Year_purchase
	FROM price_details
	WHERE Year(Date)=2019
    GROUP BY commodity_id
	ORDER BY Max_price DESC
	LIMIT 10
),
TOP10_2020 AS
(
	SELECT commodity_id,
			MAX(Retail_price) as Max_price,
			Year(Date) as Year_purchase
	FROM price_details
	WHERE Year(Date)=2020
    GROUP BY commodity_id
	ORDER BY Max_price DESC
	LIMIT 10
)
SELECT DISTINCT c.commodity as common_list
FROM TOP10_2019 t1
	INNER JOIN TOP10_2020 t2 
		ON t1.commodity_id=t2.commodity_id
	INNER JOIN commodities_info c
		ON t1.commodity_id=c.Id;
        
-- given soln
WITH year1_summary AS
(
SELECT 
commodity_id, 
MAX(retail_price) as price
FROM price_details
WHERE YEAR(date)=2019
GROUP BY commodity_id
ORDER BY price DESC
LIMIT 10
),
year2_summary AS
(
SELECT 
commodity_id, 
MAX(retail_price) as price
FROM price_details
WHERE YEAR(date)=2020
GROUP BY commodity_id
ORDER BY price DESC
LIMIT 10
),
common_commodities AS
(
SELECT y1.commodity_id
FROM 
year1_summary AS y1
INNER JOIN
year2_summary AS y2
ON y1.commodity_id=y2.commodity_id
)
SELECT DISTINCT ci.commodity AS common_commodity_list
FROM
common_commodities as cc
JOIN
commodities_info as ci
ON cc.commodity_id=ci.id;


/**
What is the max difference between the prices of a commodity at one place v another
for the month of June, 2020? Which commodity was it?
**/
SELECT p.Commodity_Id,
		c.Commodity,
		MAX(p.Retail_price)-MIN(p.Retail_price) as price_diff
FROM price_details p
	INNER JOIN commodities_info c
		ON p.commodity_id=c.id
WHERE MONTHNAME(Date)='June'
	AND YEAR(Date)=2020
GROUP BY Commodity_Id
ORDER BY price_diff DESC;
	
-- given soln
WITH june_prices AS
(
SELECT commodity_id, 
MIN(retail_price) AS Min_price,
MAX(retail_price) AS Max_price
FROM price_details
WHERE date BETWEEN '2020-06-01' AND '2020-06-30'
GROUP BY commodity_id
)
SELECT ci.commodity,
Max_price-Min_price AS price_difference
FROM
june_prices as jp
JOIN
commodities_info as ci
ON jp.commodity_id=ci.id
ORDER BY price_difference DESC
LIMIT 1; 

/**
Arrange the commodities in order based on the number of varities in which they are available,
with the highest one shown at the top. Which is the 3rd commodity in the list?
**/
SELECT commodity,
		COUNT(Variety) AS count_variety
FROM commodities_info
GROUP BY commodity
ORDER BY count_variety DESC,
			commodity;
            
/**
In the state with the least number of data points available,
Which commodity has the highest number of data points available?
**/
WITH join_tbl AS
(
	SELECT Commodity,
			State
	FROM price_details p
		INNER JOIN region_info r
			ON p.region_id=r.id
		INNER JOIN commodities_info c
			ON p.commodity_id=c.id
)
SELECT State,
		Commodity,
        COUNT(Commodity) as data_points
FROM join_tbl
WHERE State = (
				SELECT State
				FROM join_tbl
				GROUP BY State
				ORDER BY COUNT(commodity)
				LIMIT 1 
				)
GROUP BY State,
		commodity
ORDER BY COUNT(Commodity) DESC;

-- given soln
WITH raw_data AS
(
SELECT 
pd.id, pd.commodity_id, ri.state
FROM
price_details as pd
LEFT JOIN
region_info as ri
ON pd.region_id = ri.id
),
state_rec_count AS
(
SELECT state, 
COUNT(id) as state_wise_datapoints
FROM raw_data
GROUP BY state
ORDER BY state_wise_datapoints
LIMIT 1
),
commodity_list AS
(
SELECT 
commodity_id,
COUNT(id) AS record_count
FROM 
raw_data
WHERE state IN (SELECT DISTINCT state FROM state_rec_count)
GROUP BY commodity_id
ORDER BY record_count DESC
)
SELECT 
commodity,
SUM(record_count) AS record_count
FROM
commodity_list AS cl
LEFT JOIN
commodities_info AS ci
ON cl.commodity_id = ci.id
GROUP BY commodity
ORDER BY record_count DESC
LIMIT 1;

/**
What is the price variation of commodities for each city from Jan 2019 to Dec 2019.
Which commodity has seen the highest price variation and in which city?
**/
WITH jan_2019 AS
(
		SELECT *
	FROM price_details
	WHERE year(Date)=2019 
		AND month(Date)=01
),
dec_2020 AS
(
	SELECT *
	FROM price_details
	WHERE year(Date)=2020 
		AND month(Date)=12
),
price_diff_data AS
(
	SELECT t1.commodity_id,
			t1.region_id,
			t1.retail_price AS jan_2019_price,
			t2.retail_price AS dec_2020_price,
			abs(t1.retail_price-t2.retail_price) AS price_diff,
			round(abs(t1.retail_price-t2.retail_price)/t1.retail_price*100,2) as price_diff_perc
	FROM jan_2019 t1
		INNER JOIN dec_2020 t2
			ON t1.commodity_id=t2.commodity_id
			AND t1.region_id=t2.region_id
	ORDER BY price_diff_perc DESC
    LIMIT 1
)
SELECT c.commodity,
		r.Centre as Region,
        p.price_diff,
        p.price_diff_perc
FROM price_diff_data p
	LEFT JOIN region_info r
		ON p.region_id=r.id
	LEFT JOIN commodities_info c
		ON p.commodity_id=c.id;

-- given soln
WITH jan_2019_data AS
(
SELECT * 
FROM 
price_details
WHERE date BETWEEN '2019-01-01' AND '2019-01-31'
),
dec_2020_data AS
(
SELECT * 
FROM 
price_details
WHERE date BETWEEN '2020-12-01' AND '2020-12-31'
),
price_variation AS
(
SELECT j.region_id,
j.commodity_id,
j.retail_price AS start_price,
d.retail_price AS end_price,
d.retail_price-j.retail_price AS variation,
round((d.retail_price-j.retail_price)/j.retail_price*100,2) AS variation_percentage
FROM 
jan_2019_data as j
INNER JOIN
dec_2020_data as d
ON j.region_id = d.region_id
AND j.commodity_id=d.commodity_id
ORDER BY variation_percentage DESC
LIMIT 1
)
SELECT 
r.centre AS City,
c.commodity AS Commodity_name,
start_price,
end_price,
variation,
variation_percentage 
FROM price_variation AS p
JOIN
region_info r
ON p.region_id=r.id
JOIN
commodities_info c
ON p.commodity_id=c.id;