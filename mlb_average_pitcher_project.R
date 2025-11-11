######### MLB Average Pitcher Value Project ########

############## Loading Libraries Function ####################

load_libraries <- function(packages) {
  # Check for missing packages
  missing_packages <- packages[!(packages %in% installed.packages()[, "Package"])]
  
  # install missing packages
  if(length(missing_packages) > 0) {
    install.packages(missing_packages)
  }
  
  # Load all packages
  lapply(packages, library, character.only = TRUE)
  
  cat("All packages are loaded succesfully.\n")
}


# Loading necessary libraries
load_libraries(c("tidyverse", "lubridate", "stats", "ggplot2", "corrplot", "stringr", "stringi",
                 "tidymodels", "modeldata", "themis", "vip", "baguette", "purrr", "rvest",
                 "yardstick", "gsheet", "caret", "randomForest", "here", "tibble", "dplyr", "ISAR", 
                 "tidyr", "mgcv", "teamcolors", "baseballr", "Lahman", "remotes", "ggcorrplot", "broom", 
                 "readr", "glmnet", "xgboost", "Matrix"))

# Load only the necessary functions from 'car'
library(car, exclude = "select")

# Turning off warning messages
options(warnings = 0)


######## Scraping pitcher data from 2021 to 2025 #######################

# Below are all the urls for the pitcher data from 2021-2025

# Pitcher data for 2025
pitch_url_25 <- "https://www.baseball-reference.com/leagues/majors/2025-standard-pitching.shtml"

# Pitcher data for 2024
pitch_url_24 <- "https://www.baseball-reference.com/leagues/majors/2024-standard-pitching.shtml"

# Pitcher data for 2023
pitch_url_23 <- "https://www.baseball-reference.com/leagues/majors/2023-standard-pitching.shtml"

# Pitcher data for 2022
pitch_url_22 <- "https://www.baseball-reference.com/leagues/majors/2022-standard-pitching.shtml"

# Pitcher data for 2021
pitch_url_21 <- "https://www.baseball-reference.com/leagues/majors/2021-standard-pitching.shtml"


# Below code is to scrape the data for each year from the urls given above

# Pitcher dataset for 2025
pitch_data_25 <- pitch_url_25 %>%
  read_html() %>%
  html_table() %>%
  .[[2]] %>%
  janitor::clean_names()

# Adding the year to the dataset
pitch_data_25 <- pitch_data_25 %>% 
  mutate(year = 2025)

# Removing the rank column
pitch_data_25 <- pitch_data_25 %>% 
  select(-rk)

# Pitcher dataset for 2024
pitch_data_24 <- pitch_url_24 %>%
  read_html() %>%
  html_table() %>%
  .[[2]] %>%
  janitor::clean_names()

# Adding the year to the dataset
pitch_data_24 <- pitch_data_24 %>% 
  mutate(year = 2024)

# Removing the rank column
pitch_data_24 <- pitch_data_24 %>% 
  select(-rk)

# Pitcher dataset for 2023
pitch_data_23 <- pitch_url_23 %>%
  read_html() %>%
  html_table() %>%
  .[[2]] %>%
  janitor::clean_names()

# Adding the year to the dataset
pitch_data_23 <- pitch_data_23 %>% 
  mutate(year = 2023)

# Removing the rank column
pitch_data_23 <- pitch_data_23 %>% 
  select(-rk)

# Pitcher dataset for 2022
pitch_data_22 <- pitch_url_22 %>%
  read_html() %>%
  html_table() %>%
  .[[2]] %>%
  janitor::clean_names()

# Adding the year to the dataset
pitch_data_22 <- pitch_data_22 %>% 
  mutate(year = 2022)

# Removing the rank column
pitch_data_22 <- pitch_data_22 %>% 
  select(-rk)

# Pitcher dataset for 2021
pitch_data_21 <- pitch_url_21 %>%
  read_html() %>%
  html_table() %>%
  .[[2]] %>%
  janitor::clean_names()

# Adding the year to the dataset
pitch_data_21 <- pitch_data_21 %>% 
  mutate(year = 2021)

# Removing the rank column
pitch_data_21 <- pitch_data_21 %>% 
  select(-rk)

# Combining all the pitcher data for each year into one dataset.
all_pitchers <- bind_rows(pitch_data_21, pitch_data_22, pitch_data_23, pitch_data_24, pitch_data_25)

# Exporting all pitchers data into a csv file
write.csv(all_pitchers, "all_pitchers_data.csv", row.names = FALSE)


#######


# Filter: 30+ starts, 5+ innings/start (IP/GS >= 5)
pitch_filtered <- all_pitchers %>%
  mutate(ip_per_start = ip / gs) %>%
  filter(gs >= 30, ip_per_start >= 5)

# Looking at the dataset to make sure everything looks good
view(pitch_filtered)

# Getting the summary of the dataset to try to find what the statistics look like for an average pitcher. 
# Pitchers that will never have unusually strong or weak game-to-game performance.
summary(pitch_filtered)

# Looking at the distribution of innings pitched
ggplot(pitch_filtered, aes(x = ip)) +
  geom_histogram(binwidth = 10, fill = "blue", alpha = 0.7) +
  labs(title = "Distribution of Innings Pitched", x = "Innings Pitched (IP)", y = "Count") +
  theme_bw()


# Looking at the summary and distribution of innings pitched, we can point out that we have to filter the pitchers even more.
# The first quartile is at 171 innings pitched and that would be more than 5 innings per start.
# We want pitchers that would pitch around 150 innings or so.
# So, we will concentrate on pitchers between the min. and 1st quartile for this year.

# Filtering data between min and 1st quartile for 2024 season.
pitch_filtered <- pitch_filtered %>% 
  filter(ip <= 171)

# Looking at the dataset we have now
view(pitch_filtered)

# Looking at the summary for this new filtered dataset
summary(pitch_filtered)

# List of new variables to filter by.
  # war - Win above replacement is a good variable to find average pitchers. Pitchers who have high war are really good and vice versa.
  # era - Earned runs allowed is another good metric because this is solely on the pitcher.
  # ERA is not influenced by how your team performs and it's focus on the pitcher.

# We will be taking the middle half of the data in WAR and ERA.
# So we are going to filter by the first and third quartile on these variables.

# Getting the quartiles for war
war_q1 <- quantile(pitch_filtered$war, 0.25, na.rm = TRUE)
war_q3 <- quantile(pitch_filtered$war, 0.75, na.rm = TRUE)

# Getting the quartiles for era
era_q1 <- quantile(pitch_filtered$era, 0.25, na.rm = TRUE)
era_q3 <- quantile(pitch_filtered$era, 0.75, na.rm = TRUE)

# Filtering dataset based on these quartiles.
pitch_filtered_avg <- pitch_filtered_avg %>%
  filter(era >= era_q1, era <= era_q3, war >= war_q1, war <= war_q3)

# Loading the salary data for the resulting pitchers in pitch_filtered_avg
salary_data <- gsheet2tbl("https://docs.google.com/spreadsheets/d/1DpPK4FVFk4awtxDq1IW-gbQMpkryxCDjT8XROB_x1pk/edit?gid=1271641651#gid=1271641651")

# Cleaning the pitch_filtered_avg player names in order to join with salary_data
pitch_filtered_avg <- pitch_filtered_avg %>%
  mutate(player = player %>%
           # remove asterisks, punctuation
           str_replace_all("\\*", "") %>%
           # remove accents (e.g., José → Jose)
           stri_trans_general("Latin-ASCII") %>%
           # trim whitespace
           str_trim()
  )

# Joining salary data with pitch_filtered_avg
pitch_with_salary <- pitch_filtered_avg %>%
  left_join(salary_data, by = c("player", "year"))

# Looking at the summary of the salaries
pitch_with_salary %>%
  summarise(
    mean_salary = mean(salary, na.rm = TRUE),
    median_salary = median(salary, na.rm = TRUE),
    mean_war = mean(war, na.rm = TRUE),
    mean_era = mean(era, na.rm = TRUE)
  )

# Looking at the overall summary of the salary
summary(pitch_with_salary$salary)

# Distribution of salary
ggplot(pitch_with_salary, aes(x = salary / 1e6)) +
  geom_histogram(binwidth = 2, fill = "steelblue", color = "white") +
  labs(
    title = "Salary Distribution of League-Average Pitchers (Approx. 150IP)",
    x = "Salary (Millions USD)",
    y = "Number of Pitchers"
  )





