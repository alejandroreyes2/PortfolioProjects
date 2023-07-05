# 2019 Flight Data Exploratory Data Analysis in Python

This EDA project was created in an effort to expand and improve my utilization of Python as a tool for data analysis. The 6.4 million record data set is titled "2019 Airline Delays w/Weather and Airport Detail". It contains information such as the date and time of flight, whether or not a flight was delayed, the number of seats in the plane, the age of the plane, the airline carrier, the location of the departing airport, and weather conditions on the day of departure. The dataset can be found using the following link:

https://www.kaggle.com/datasets/threnjen/2019-airline-delays-and-cancellations?select=full_data_flightdelay.csv

## Libraries Used:
- pandas
- numpy
- matplotlib and seaborn (data visualizations)
- folium (heatmaps)

## Applied Skills:
- Data Manipulation in Python: data cleaning, transforming, and filtering
- Data Visualizations: heatmaps (some were on a geographical map of the world), scatterplots, boxplots, pair plots, histograms, strip plots, and boxplots
- Exploratory Data Analysis Techniques: descriptive statistics, correlation analysis, feature analysis, feature importance

## The general workflow of the project is as follows:
1. Data Preparation and Cleaning
  a. Understand the columns
  b. Clean the column names and decode column values
  c. Check for and correct nulls
2. Feature analysis
  a. Univariate analysis
  b. Bivariate analysis with the target variable
  c. Multivariate analysis with target variable and other selected features
  d. Visualizations were present throughout a-c
3. Answering any remaining questions after going through steps 1 and 2.

## Favorite insight from the project:
I use a tour company to book trips abroad, and they usually book my flights for me. However, I do have the option to pick my flights if I so choose. Therefore, I wanted to see how prevalent flight delays were on the airlines that I have been booked with (American Airlines, Delta Airlines, United Airlines) compared to the rest of the airlines in the data set. As of 2019, American Airlines had the second most delayed flights in the US, Delta Airlines had the third most, and United Airlines had the fourth most. I might want to start booking my own flights!
