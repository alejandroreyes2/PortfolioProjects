# Music Store SQL Project

This SQL project analyzes data from a music store database to answer the following questions: What is the most popular artist’s number of sales by country? What playlist has the highest total sales from its songs? In what year did Iron Maiden sell the most songs? What percentage of the largest total priced invoice did each of its tracks occupy?

## Applied Skills:
SQL: CTE, Joins, Subqueries, Aggregate Functions, Converting Datetime to String, Calculated Columns  
Excel: Exported query results from SQL to compose relevant data visualizations  
Microsoft PowerPoint: Used to aggregate and display the findings informatively and intuitively

## The general workflow of the project is as follows:
1. Composed four questions to be answered using the music store database
2. Answered each question using their own respective queries in SQL
3. Exported the results from SQL to Excel to create appropriate data visualizations
4. Compiled all visualizations into a PowerPoint along with a description of the findings to answer the question

## Favorite query from the project:
```
WITH num_songs_sold_by_artist AS (
  SELECT
    r.name,
    COUNT(l.trackid) num_sold
  FROM
    invoiceline l
    JOIN track t ON l.trackid = t.trackid
    JOIN album a ON t.albumid = a.albumid
    JOIN artist r ON a.artistid = r.artistid
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1
)
SELECT
  c.country,
  COUNT(c.customerid) AS "Number of Sales"
FROM
  customer c
  JOIN invoice i ON c.customerid = i.customerid
  JOIN invoiceline l ON i.invoiceid = l.invoiceid
  JOIN track t ON l.trackid = t.trackid
  JOIN album a ON t.albumid = a.albumid
  JOIN artist r ON a.artistid = r.artistid
  JOIN num_songs_sold_by_artist n ON r.name = n.name
GROUP BY 1
ORDER BY 2 DESC
```

The above code uses a CTE to group number of tracks sold by artist and then selects the top artist. The rest of the data is then filtered by joining the original data set to CTE.
