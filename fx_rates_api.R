# API call for USD currencies
install.packages(c("httr", "jsonlite"))
library(httr)
library(jsonlite)

filename <- 'ds_salaries.csv'
sal <- read.csv(filename)

d <- GET('https://fxdata.foorilla.com/api/currencies/CAD/?yearly_average=2021')
dat <- fromJSON(rawToChar(d$content))

getCurrRate <- function(curr='USD', year='2021') {
    # API URL
    URL <- paste0('https://fxdata.foorilla.com/api/currencies/',
                  curr,
                  '/?yearly_average=', 
                  as.character(year))
    
    # retrieve and store data from API
    temp_raw <- GET(URL)
    temp_list <- fromJSON(rawToChar(temp_raw$content))
    
    rate <- temp_list$avg_usdrate
    return(rate)
    
}

curr_list <- unique(sal$salary_currency)
years <- 2020:2022

curr_rates <- list()
for (i in 1:length(years)) {
    Rates <- sapply(curr_list, function(x) getCurrRate(x, years[i]))
    Rates <- as.data.frame(Rates)
    Rates$Currency <- row.names(Rates)
    row.names(Rates) <- NULL
    Rates$Year <- years[i]
    curr_rates[[as.character(years[i])]] <- Rates
}
# rate_table = do.call(rbind, curr_rates)
# rate_table <- dplyr::bind_rows(curr_rates)
rate_table <- data.table::rbindlist(curr_rates)

    