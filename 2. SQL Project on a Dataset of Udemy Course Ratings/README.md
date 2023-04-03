# SQL Project on a Dataset of Udemy Course Ratings

This a SQL Exploratory Data Analysis project that uses a dataset containing course comments and course information from the website Udemy. The `Comments` dataset is over 1 million records while the `CourseInfo` dataset is over 200k records. `Comments` contains information such as when a comment was published, to what course it was published to, and the rating that the user gave the course. `CourseInfo` records course id, title, if it is free or requires a subscription, price (if applicable), rating, number of reviews and more.

I created a hypothetical client briefing where two dashboards were required as the end products. The dashboard specifications can be seen in the `ClientBriefing` file. Tableau was used to create the dashboards after using the outputs generated from individual SQL queries.

The Tableau Visualizations for this project can be viewed using the following link:
https://public.tableau.com/app/profile/alejandro7163/viz/SQLProjectVisualizationsonUdemyCourseRatingsDataset/UdemysSitewideCustomerFeedback

## Applied Skills:
SQL Skills: CTEs, Aggregate Functions, Window Functions, Conditions, Joins, Temp Tables, and Subqueries, Table Creation, Conditional Formatting, Updating Tables, String Manipulations, and Null Identification and Correction.  
Tableau Skills: Dashboard Creation, Line Graph, Pie Chart, Box and Whisker Plot, Informational Pop-Outs, Aggregate Functions

## The general workflow of the project is as follows:
1. The datasets were first mapped to their respective tables that were created in sequel
2. Both sets of data were then cleaned
3. Individual queries were created to sufficiently inform the prompts given in the "client briefing"
4. The data was then exported to Tableau where the proper visualizations were created on individual worksheets for each query
5. The visualizations and other information were then compiled into a Tableau Dashboard

## Favorite piece of SQL code from the project:

The information being generated from the query is a breakdown of revenue between courses that have been updated since 2019 vs those that haven't been. The below temp table takes in desired columns from the original dataset and adds a new column `course_revenue`. I created a temp table because it was used in multiple queries.

```
Drop Table if exists #RevenuePerCourse
Create Table #RevenuePerCourse (
	id int,
	title varchar(255),
	year_published int,
	last_update_date date,
	price float,
	num_subscribers int,
	course_revenue float
)

Insert into #RevenuePerCourse
Select
	id,
	title,
	Year(date_published) as year_published,
	last_update_date,
	price,
	num_subscribers,
	Convert(decimal(12, 2), (price * num_subscribers)) as course_revenue
From UdemyCourseDataAnalysis..CourseInfo

With updated as
(
	Select
		*,
		Case When last_update_date > Cast('2018-12-31' as date)
			 Then 'Yes'
			 Else 'No'
			 End as updated_since_2019
	From #RevenuePerCourse
)
Select
	updated_since_2019,
	Sum(course_revenue) as course_revenue,
	Count(*) as course_count
From updated
Group By updated_since_2019
Order By 2
```
