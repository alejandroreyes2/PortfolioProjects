/*

Dashboard Queries

Skills Used: CTEs, Aggregate Functions, Window Functions, Conditions, Joins,
						 Temp Tables, and Subqueries

*/

/*

Dashboard #1: A dashboard that focuses on customer satisfaction

*/

--	1. Overall net promoter score (% promoters - % detractors) assuming promoters
--  gave a score of 4 or higher and detractors gave a score less than 3.

-- The CTE intializes a table with the counts of detractors, promoters, and
-- total reviewers.
With ratings_tally as
(
	Select
		Count(Case When rate < 3 Then 1 End) as detractor_ct,
		Count(Case When rate >= 4 Then 1 End) as promoter_ct,
		Count(*) as total_ct
	From UdemyCourseDataAnalysis..Comments
)
Select
	(Convert(float, promoter_ct)/Convert(float, total_ct) -
	Convert(float, detractor_ct)/Convert(float, total_ct))*100 as net_promoter_score
From ratings_tally



-- 	2. The yearly trend of the overall net promoter score.

-- The CTE and query below do the same as 1 except group by year
With yearly_ratings_tally as
(
	Select
		Year(date) as year,
		Count(Case When rate < 3 Then 1 End) as detractor_ct,
		Count(Case When rate >= 4 Then 1 End) as promoter_ct,
		Count(*) as total_ct
	From UdemyCourseDataAnalysis..Comments
	Group By Year(date)
	-- Order By 1
)
Select
	year,
	(Convert(float, promoter_ct)/Convert(float, total_ct) -
	Convert(float, detractor_ct)/Convert(float, total_ct))*100 as net_promoter_score
From yearly_ratings_tally
Order By 1



--	3. Average ratings left by customers each year.
Select
	Year(date_posted) as year,
	Avg(rate) as avg_rating
From UdemyCourseDataAnalysis..Comments
Group By Year(date_posted)
Order By 1



-- 	4. Show how the positive and negative ratings have changed over time. Assume a
--  positive rating is above or equal to 2.5 and a negative rating is below a 2.5.

-- Creates a CTE with ratings, attitude (positive if rating is above 2.5 and
-- negative otherwise), and year.
-- The main query groups by attitude and counts the number of positive attitudes
-- and negative attitudes per year.
With attitudes as
(
	Select
		rate,
		attitude = Case When rate >= 2.5
						Then 'Positive'
						Else 'Negative'
						End,
		Year(date_posted) as year_posted
	From UdemyCourseDataAnalysis..Comments
)
Select
	year_posted,
	attitude,
	Count(*) as count
From attitudes
Group By
	year_posted,
	attitude
Order By 1



/*

Dashboard #2: A dashboard that focuses on the trends of customer engagement with
feedback channels

*/

--	1. Number of comments left each year, sitewide.
Select
	Year(date_posted) as year,
	Count(*) as comments_per_year
From UdemyCourseDataAnalysis..Comments
Group By
	Year(date_posted)
Order By 1

-- 	2. For the courses that have comments, provide the average amount of days it takes
--  for a course to receive its first comments after its publication date. In addition,
--  summarize the distribution the days it takes a course to recieve its first comments,
--	sitewide.

-- Performs the aggregate functions found in the five number summary in addition
-- to the average on the days between the date of course publication and
-- the date a comment was posted across the entire dataset.
Select Top 1
	Avg(days_between) Over () as avg_days,
	Min(days_between) Over () as min_days,
	Percentile_disc(0.25) Within Group (Order By days_between) Over () as first_quartile,
	Percentile_disc(0.5) Within Group (Order By days_between) Over () as median,
	Percentile_disc(0.75) Within Group (Order By days_between) Over () as third_quartile,
	Max(days_between) Over () as max_days
From (
-- This subquery determines the days between the date of course publication and
-- the date a comment was posted.
Select
	cs.id,
	cs.course_id,
	cs.date_posted,
	ci.date_published,
	Datediff(day, ci.date_published, cs.date_posted) as days_between
From UdemyCourseDataAnalysis..Comments cs  -- Joins to data set with comment history
Left Join UdemyCourseDataAnalysis..CourseInfo ci
	On cs.course_id = ci.id
) as t1



-- 	3. A quantitative breakdown of the categories responsible for generating the
--	 most customer feedback (reviews + comments).

-- The CTE determines the sum of all feedback counts per class category and then
-- creates a new column with the total feedback count (sum of all feedback
-- counts per class category) via a window function
With cat_feedback_counts as
(
	Select
		category,
		Sum(num_reviews + num_comments) as feedback_counts,
		Cast(Sum(Sum(num_reviews + num_comments)) Over () as float) as total_feedback_count
	From UdemyCourseDataAnalysis..CourseInfo
	Group By category
)
Select
	category,
	Cast((feedback_counts/total_feedback_count)* 100 as decimal(20, 2)) as percent_total_feedback
From cat_feedback_counts



--	4. Provide the average, sitewide conversion rate for subscribers to give any sort
--  of feedback action (review or comment) after taking a course.

-- The below subquery determines the conversion rate for each course if the
-- subscriber count is above 0.
Select Cast(Avg(conversion_rate) as decimal(20, 2)) as avg_conversion_rate
From (Select
		id,
		title,
		(num_reviews + num_comments) as num_actions,
		num_subscribers as num_interactions,
		conversion_rate = Case When num_subscribers > 0
							   Then ((num_reviews + num_comments) / Cast(num_subscribers as float)) * 100
							   Else 0  -- Prevent divide by zero error for courses with no subscribers
							   End
	From UdemyCourseDataAnalysis..CourseInfo) as t1




/*

 Extra queries without a corresponding visualization

*/


-- The below temp table takes in desired columns from the original dataset
-- and adds a new column `course_revenue`
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

-- Sum of `course_revenue` using above temp table
Select sum(course_revenue) From #RevenuePerCourse


Select
	Cast(Avg(course_revenue) as decimal(10,2)) as avg_revenue
From #RevenuePerCourse

--	2. A breakdown of revenue between courses that have been updated since 2019
-- 	vs those that haven't been.
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

--	3. Compare the revenue of products that were published at different times to see
--  if there is a correlation between publication date and revenue
Select
	Year(date_published) as year_published,
	Sum(price * num_subscribers) as course_revenue
From UdemyCourseDataAnalysis..CourseInfo
Group By Year(date_published)
Order By 1
-- The most revenue was generated by products that were published in the year 2020,
-- the height of covid

-- 	4. Break down the average pricing of courses and its influence on the number of
--	conversions to the site by publication year
Select
	year(date_published) as year_published,
	Avg(price) as avg_course_price,
	Sum(num_subscribers) as total_subscribers
From UdemyCourseDataAnalysis..CourseInfo
Group By Year(date_published)
Order By 1

--  5. Provide a list of all the categories with their respective total revenue generated
--	and total number of subscribers
Select
	category,
	Sum(num_subscribers) as total_subs,
	Cast(Sum(price * num_subscribers) as decimal(20,2)) as course_revenue
From UdemyCourseDataAnalysis..CourseInfo
Group By
	category
Order By 3 Desc
