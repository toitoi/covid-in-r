library(jsonlite)
library(geojsonio)
library(dplyr)
library(leaflet)
library(imputeMissings)
library(DT)
library(rlang)
library(scales)
library(caret)

# Dataset download from : http://data.okfn.org/data/datasets/geo-boundaries-world-110m
# geoJson intro : https://developer.here.com/blog/an-introduction-to-geojson
# TODO : use realtime data by scraping
# TODO : incorrect US map!!
g_geojson <- geojson_read("countries.geojson", what = "sp")
g_pop_est <-  data.frame("Country" = g_geojson$admin, "Population" = g_geojson$pop_est)

# Read csv file
# TODO : scrape data from https://datahub.io/core/covid-19/r/countries-aggregated.csv
# Field information
# Field Name  Order	Type (Format)
# Date	      1	    date (%Y-%m-%d)	
# Country	    2	    string (default)	
# Confirmed	  3	    integer (default)	
# Recovered	  4	    integer (default)	
# Deaths	    5	    integer (default)
g_covid_data <- read.csv("countries-aggregated.csv",na.strings = NA,fill = NA)
# remove the NA row? why not set to 0
g_covid_data <- impute(g_covid_data)

# ui :
g_option_categories <- names(g_covid_data)[-1:-2]
g_option_dates <- unique(g_covid_data$Date)

g_country_list <-as.character(g_geojson$admin)

g_country_df <- data.frame("Country" = g_country_list)
# names(g_country_df)
# head(g_country_df)
# redundant? default already sorted!
# arrange(g_country_df, g_country_list)

# g_filtered_latest_date <- g_covid_data %>% filter(Date == "2020-03-27") %>% group_by(Country)
# g_country_case_by_date <- left_join(g_country_df, g_filtered_latest_date, by="Country")

