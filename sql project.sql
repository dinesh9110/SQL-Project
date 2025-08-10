SELECT
*
FROM
NETFLIX;

SELECT
COUNT(*) AS TOTAL_CONTENT
FROM
NETFLIX;

-- 1.count the number of moives vs tv shows;
SELECT
TYPE,
COUNT(TYPE) AS TOTAL_CONTENT
FROM
NETFLIX
GROUP BY
TYPE;

-- 2.find the most common rating foR movies and tv shows
SELECT
RATING,
COUNT(*) AS COMMON_RATING
FROM
NETFLIX
GROUP BY
RATING
ORDER BY
COMMON_RATING DESC
LIMIT
1;

--  or
SELECT
TYPE,
RATING
FROM
(
SELECT
	TYPE,
	RATING,
	COUNT(*),
	DENSE_RANK() OVER (
		PARTITION BY
			TYPE
		ORDER BY
			COUNT(*) DESC
	) AS RANKING
FROM
	NETFLIX
GROUP BY
	1,
	2
) AS TL
WHERE
RANKING = 1;

--3. list all movies released in a specific year
SELECT
*
FROM
NETFLIX
WHERE
RELEASE_YEAR = 2020
AND TYPE = 'Movie';

-- 4.find the top 5 countries with most content on netflix
SELECT
COUNTRY,
COUNT(SHOW_ID)
FROM
NETFLIX
GROUP BY
COUNTRY
ORDER BY
COUNT(SHOW_ID) DESC
LIMIT
5;

-- or
SELECT
UNNEST(STRING_TO_ARRAY(COUNTRY, ',')) AS NEW_COUNTRY,
COUNT(SHOW_ID) AS TOTAL_CONTENT
FROM
NETFLIX
GROUP BY
1
ORDER BY
2 DESC
LIMIT
5;

-- 5.identify the longest movie
SELECT
*
FROM
NETFLIX
WHERE
TYPE = 'Movie'
AND DURATION = (
SELECT
	MAX(DURATION)
FROM
	NETFLIX
)
-- 6.find th content added in the last 5 years
SELECT
*
FROM
NETFLIX
WHERE
TO_DATE(DATE_ADDED, 'month dd yyyy') >= CURRENT_DATE - INTERVAL '5 years';

-- 7.find all the movies/tv shows by  director 'rajiv chilaka'
SELECT
*
FROM
NETFLIX
WHERE
DIRECTOR LIKE '%Rajiv Chilaka%';

-- 8. list all TV Shows with more than 5 seasons
SELECT
*
FROM
NETFLIX
WHERE
TYPE = 'TV Show'
AND SPLIT_PART(DURATION, ' ', 1)::NUMERIC > 5;

-- 9. count the number of content items in each genre
SELECT
UNNEST(STRING_TO_ARRAY(LISTED_IN, ',')),
COUNT(SHOW_ID)
FROM
NETFLIX
GROUP BY
1
-- 10. find each year and the average numbers of content relesed 
-- in India on netflix return top 5 year with higest content relesed
SELECT
EXTRACT(
YEAR
FROM
	TO_DATE(DATE_ADDED, 'Month DD,YYYY')
) AS YEAR,
COUNT(*) AS YEARLY_CONTENT,
ROUND(
COUNT(*)::NUMERIC / (
	SELECT
		COUNT(*)
	FROM
		NETFLIX
	WHERE
		COUNTRY = 'India'
)::NUMERIC * 100,
2
) AS AVG_CO_PER_YEAR
FROM
NETFLIX
WHERE
COUNTRY = 'India'
GROUP BY
1;

-- 11. list all movies all documentaries
SELECT
*
FROM
NETFLIX
WHERE
TYPE = 'Movie'
AND LISTED_IN LIKE '%Documentaries%';

-- 12. find all content without director 
SELECT
*
FROM
NETFLIX
WHERE
DIRECTOR IS NULL;

-- 13.find how many movies actor 'salman khan ' appeared in last 10 years
SELECT
*
FROM
NETFLIX
WHERE
CASTS ILIKE '%salman khan%'
AND RELEASE_YEAR > EXTRACT(
YEAR
FROM
	CURRENT_DATE
) -10
-- 14. find the top 10 actors who have appeared in the highest number of movies produced in india 
SELECT
UNNEST(STRING_TO_ARRAY(CASTS, ',')) AS NEW_CASTS,
COUNT(*)
FROM
NETFLIX
WHERE
COUNTRY ILIKE '%india%'
GROUP BY
NEW_CASTS
ORDER BY
2 DESC
LIMIT
10;

-- 15. categorize the content based on the presence of the keywords 'kill' and 'voilence' in the derscription field.label content containing these keywords as 'bad' and all other content as 'good'.count how many times fall into each category
WITH
NEW_TABLE AS (
SELECT
	*,
	CASE
		WHEN DESCRIPTION ILIKE '%kill%'
		OR DESCRIPTION ILIKE '%violence%' THEN 'bad_content'
		ELSE 'good content'
	END CATEGORY
FROM
	NETFLIX
)
SELECT
CATEGORY,
COUNT(*) AS TOTAL_CONTENT
FROM
NEW_TABLE
GROUP BY
1