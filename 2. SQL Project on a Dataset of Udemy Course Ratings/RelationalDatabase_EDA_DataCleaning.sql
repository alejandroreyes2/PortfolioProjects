/*

Relational Database, Exploratory Data Analysis, and Data Cleaning

Skills used: Window functions, table creation, conditional formatting,
             updating tables, string manipulations, and null identification and
             correction.

*/

/*

The below code creates two tables to map the original source data to. It
specifies the primary key for each table and also identifies the foreign key
that connects the two tables for future joins.

*/

Drop Table if exists UdemyCourseDataAnalysis..CourseInfo
Create Table UdemyCourseDataAnalysis..CourseInfo (
    id int not null,
    title varchar(255) null,
    is_paid varchar(20) null,
    price float null,
    headline varchar(255) null,
    num_subscribers int null,
    avg_rating float null,
    num_reviews int null,
    num_comments int null,
    num_lectures int null,
    content_length_min int null,
    published_time varchar(255) null,
    last_update_date datetime null,
    category varchar(255) null,
    subcategory varchar(255) null,
    topic varchar(255) null,
    language varchar(255) null,
    course_url varchar(255) null,
    instructor_name varchar(255) null,
    instructor_url varchar(255) null,
    Constraint PK_CourseInfo Primary Key Clustered (
        id ASC
    )
)

Drop Table if exists UdemyCourseDataAnalysis..Comments
Create Table UdemyCourseDataAnalysis..Comments (
    id int not null,
    course_id int null, -- foreign key
    rate float null,
    date nvarchar(255) null,
    display_name nvarchar(255) null,
    Constraint PK_Comments Primary Key Clustered (
        id ASC
    )
)


/*

Let's clean the CourseInfo data set

*/

Select * From UdemyCourseDataAnalysis..CourseInfo

-- It looks like the publish time and last update date are both stored as datetime
-- format with characters as delimiters. But there are nulls in the 'last_update_date'
-- column. So we need to first populate these nulls and then convert them to the
-- proper format.

Select	-- Check that we update properly before overwriting data
	published_time,
	last_update_date,
	Case When last_update_date is null
		 Then Convert(date, published_time)
		 Else Convert(date, last_update_date)
		 End as last_update_date
From UdemyCourseDataAnalysis..CourseInfo

Update UdemyCourseDataAnalysis..CourseInfo  -- Populate nulls
Set
	last_update_date = Case When last_update_date is null
							Then Convert(date, published_time)
							Else Convert(date, last_update_date)
							End

-- Convert data type of last_update_date to date
Alter Table UdemyCourseDataAnalysis..CourseInfo
Alter Column last_update_date date

-- Add two new columns to data set
Alter Table UdemyCourseDataAnalysis..CourseInfo
Add
	date_published date,
	time_published time

-- Populate new columns and convert data types
Update UdemyCourseDataAnalysis..CourseInfo
Set
	date_published = Convert(date, published_time),
	time_published = Convert(time, published_time)
From UdemyCourseDataAnalysis..CourseInfo

Select * from UdemyCourseDataAnalysis..CourseInfo

-- Look's good. We can drop the published_time column if we wanted to with the below code.
-- However, I'm not going to.

--Alter Table UdemyCourseDataAnalysis..CourseInfo
--Drop Column published_time

-- Let's look at the nulls in the headline column

Select
	title,
	headline,
	category,
	subcategory,
	topic
From UdemyCourseDataAnalysis..CourseInfo
Where headline is null

-- There appears to be 27 rows with nulls in the headlines column.
-- Since I do not know the scope of the courses, let's fill it with
-- the value of 'No headline given'

Select headline = 'No headline given'  -- pre-update check
From UdemyCourseDataAnalysis..CourseInfo
Where headline is null

Update  UdemyCourseDataAnalysis..CourseInfo  -- update values
Set headline = 'No headline given'
Where headline is null

-- Let's look at the nulls in the topic column

Select
	title,
	headline,
	category,
	subcategory,
	topic
From UdemyCourseDataAnalysis..CourseInfo
Where topic is null

Select
	title,
	category,
	subcategory,
	topic,
	count(topic) Over (Partition By topic)
From UdemyCourseDataAnalysis..CourseInfo
Order By
	category,
	subcategory,
	topic

-- There are 958 rows with no topic data provided. There doesn't appear to be a
-- methodology on how they determine the topic label so let's fill that with
-- 'No topic given'

Select topic = 'No topic given'  -- pre-update check
From UdemyCourseDataAnalysis..CourseInfo
Where topic is null

Update  UdemyCourseDataAnalysis..CourseInfo  -- update values
Set topic = 'No topic given'
Where topic is null

-- Finally, the last of the nulls are in the instructor name and instructor url.

Select
	instructor_name,
	instructor_url
From UdemyCourseDataAnalysis..CourseInfo
Where
	instructor_name is null or
	instructor_url is null
Order by instructor_name

-- There are 427 rows where the instructor url is null and 5 where the name is
-- null. It looks like whenever a name is null then the url is null. Let's look
-- to see if there is a distinct pattern in how the instructor url is labelled
-- with respect to the instructor name.

Select
	instructor_name,
	instructor_url
From UdemyCourseDataAnalysis..CourseInfo
Order by instructor_name

-- Again, there does not appear to be a pattern. But it appears that there is
-- two more cases where no name was given: '#NAME?' and '--'. Let's populate
-- these cases, along with the null case, with 'No name given' and the null case
-- for the url with 'No url given'.

Select instructor_name = Case When instructor_name is null or
								   instructor_name = '--' or
								   instructor_name = '#NAME?'
							  Then 'No name given'
							  Else instructor_name
							  End,
	   instructor_url =  Case When instructor_url is null
							  Then 'No url given'
							  Else  instructor_url
							  End
From UdemyCourseDataAnalysis..CourseInfo
Where instructor_name is null or instructor_url is null

Update  UdemyCourseDataAnalysis..CourseInfo  -- update values
Set
	instructor_name = Case When instructor_name is null or
								   instructor_name = '--' or
								   instructor_name = '#NAME?'
							  Then 'No name given'
							  Else instructor_name
							  End,
	   instructor_url =  Case When instructor_url is null
							  Then 'No url given'
							  Else  instructor_url
							  End
Where instructor_name is null or instructor_url is null

/*

Let's clean the Comments data set

*/

Select * From UdemyCourseDataAnalysis..Comments Order By 1

-- It looks like the date and the time is formatted the same way as above. (This
-- is a very roundabout way to fix this issue. I'm just showcasing string
-- functions)

Select   -- Check that we update properly before overwriting data
	date,
	ParseName(Replace(date, 'T', '.'), 2) as date_posted,
	ParseName(Replace(date, 'T', '.'), 1) as time_posted_untrimmed,
	Substring(ParseName(Replace(date, 'T', '.'), 1), 1, CharIndex('-', ParseName(Replace(date, 'T', '.'), 1)) - 1) as time_posted_trimmed
From UdemyCourseDataAnalysis..Comments

Alter Table UdemyCourseDataAnalysis..Comments  -- Add two new columns to data set
Add
	time_posted time,
	date_posted date

Update UdemyCourseDataAnalysis..Comments  -- Populate new columns
Set
	date_posted = Convert(date, ParseName(Replace(date, 'T', '.'), 2)),
	time_posted = Convert(time, Substring(ParseName(Replace(date, 'T', '.'), 1), 1, CharIndex('-', ParseName(Replace(date, 'T', '.'), 1)) - 1), 2)

Select Top 10 * From UdemyCourseDataAnalysis..Comments

-- I'm not going to drop the date column but I could with the following code

--Alter Table UdemyCourseDataAnalysis..Comments
--Drop Column date

-- The last thing we need to look for in the Ratings table is nulls.
-- It looks like there are some nulls in the display name

Select * from UdemyCourseDataAnalysis..Comments Where display_name is null

-- Let's populate those with 'No_Name'

Select display_name = 'No name given'
From UdemyCourseDataAnalysis..Comments
Where display_name is null

Update UdemyCourseDataAnalysis..Comments
Set display_name = 'No name given'
Where display_name is null

-- Select * from UdemyCourseDataAnalysis..Comments Where display_name is null
