#-----------------------------------------------------------+
#
# PCORI Data characterization query in R
# DEMOGRAPHIC TABLE
#
# Version : 0.1
#
# Authors : James C. Estill
# Contact : jaestill@umich.edu
# Started : 02/01/2016
# Updated : 02/02/2016
# License : Apache 2
#
# Description :
# Create data characterization tables for the DEMOGRAPHIC
# table in the PCORNet CDM. Currently a test to create R
# data frames from a fake data file.
#
#-----------------------------------------------------------+
#-----------------------------+
# Vars
#-----------------------------+

# Values below the threshold will be reported as BT
threshold <- 10;               # Placeholder for supression count threshold

#-----------------------------+
# User Defined Functions
#-----------------------------+

# age
# Pulled from
# http://stackoverflow.com/questions/3611314/calculating-ages-in-r
age = function(from, to) {
  from_lt = as.POSIXlt(from)
  to_lt = as.POSIXlt(to)

  age = to_lt$year - from_lt$year

  ifelse(to_lt$mon < from_lt$mon |
         (to_lt$mon == from_lt$mon & to_lt$mday < from_lt$mday),
         age - 1, age)
}


#-----------------------------------------------------------+
# DEMOGRAPHIC
#-----------------------------------------------------------+

# Demographic from CSV file
DEMOGRAPHIC <- read.csv('../fake-data/demographic.csv',
                         sep = ",",
                         header = TRUE,
                         colClasses = c("character", # Patid
                                        "Date",      # birth_date
                                        "character", # birth_time as char
                                        "character", # sex
                                        "character", # hispanic
                                        "character", # race
                                        "character", # biobank_flag
                                        "character", # raw_sex
                                        "character", # raw_hispanic
                                        "character"  # raw_race
                                        ));


# Make headers uppercase to make the implementation case insensitive
names(DEMOGRAPHIC) <- toupper(names(DEMOGRAPHIC));

# Get significant digits based on number of discrete observations
# subtracting 2 since I multiply by 100 below.
dem_sig <- nchar(nrow(DEMOGRAPHIC)) - 2 ;

# Get ages and load to ages
# assuming ages are relative to the current system date
# and do not need to take into account death date.
ages <- age(DEMOGRAPHIC$BIRTH_DATE,
            Sys.Date());

#-----------------------------+
# dem_l3_n
#-----------------------------+

dem_l3_n <- data.frame (dataset = character(1),
                        tag = character(1),
                        all_n = numeric(1),
                        distinct_n = numeric(1),
                        null_n = numeric(1),
                         stringsAsFactors=FALSE);

dem_l3_n [1,1] <- "DEMOGRAPHIC";
dem_l3_n [1,2] <- "PATID";
dem_l3_n [1,3] <- length(DEMOGRAPHIC$PATID);
dem_l3_n [1,4] <- length(unique(DEMOGRAPHIC$PATID));
dem_l3_n [1,5] <- sum(is.na(DEMOGRAPHIC$PATID));

#-----------------------------+
# dem_l3_ageyrsdist1
#-----------------------------+

dem_l3_ageyrsdist1 <- data.frame (STAT = character(6),
                                  record_n = numeric(6),
                                  stringsAsFactors=FALSE);

dem_l3_ageyrsdist1[,1] <- c("MIN", "MEAN", "MEDIAN", "MAX",
                            "N", "Null or mising");

dem_l3_ageyrsdist1[1,2] <- min( ages, na.rm=TRUE );
dem_l3_ageyrsdist1[2,2] <- mean( ages, na.rm=TRUE );
dem_l3_ageyrsdist1[3,2] <- median( ages, na.rm=TRUE );
dem_l3_ageyrsdist1[4,2] <- max( ages, na.rm=TRUE );
dem_l3_ageyrsdist1[5,2] <- sum(!is.na(DEMOGRAPHIC$BIRTH_DATE));
dem_l3_ageyrsdist1[6,2] <- sum( is.na(DEMOGRAPHIC$BIRTH_DATE));

#-----------------------------+
# dem_l3_ageyrsdist2
#-----------------------------+

# Empty data frame with 13 rows
dem_l3_ageyrsdist2 <- data.frame (age_group = character(13),
                                  record_n = numeric(13),
                                  record_pct = numeric(13),
                                  stringsAsFactors=FALSE);


# Add labels to the first column
dem_l3_ageyrsdist2[,1] <- c ("<0 yrs", "0-1 yrs", "2-4 yrs", "5-9 yrs",
                             "10-14 yrs","15-18 yrs", "19-21 yrs", "22-44 yrs",
                             "45-64 yrs", "65-74 yrs",  "75-110 yrs",
                             ">110 yrs", "NULL or missing");

# First get the counts
dem_l3_ageyrsdist2[1,2] <- length (which(ages < 0));
dem_l3_ageyrsdist2[2,2] <- length (which(ages >= 0  & ages <= 1));
dem_l3_ageyrsdist2[3,2] <- length (which(ages >= 2  & ages <= 4));
dem_l3_ageyrsdist2[4,2] <- length (which(ages >= 5  & ages <= 9));
dem_l3_ageyrsdist2[5,2] <- length (which(ages >= 10  & ages <= 14));
dem_l3_ageyrsdist2[6,2] <- length (which(ages >= 15  & ages <= 18));
dem_l3_ageyrsdist2[7,2] <- length (which(ages >= 19  & ages <= 21));
dem_l3_ageyrsdist2[8,2] <- length (which(ages >= 22  & ages <= 44));
dem_l3_ageyrsdist2[9,2] <- length (which(ages >= 45  & ages <= 64));
dem_l3_ageyrsdist2[10,2] <- length (which(ages >= 65  & ages <= 74));
dem_l3_ageyrsdist2[11,2] <- length (which(ages >= 75  & ages <= 110));
dem_l3_ageyrsdist2[12,2] <- length (which(ages > 110));
dem_l3_ageyrsdist2[13,2] <- sum(is.na(DEMOGRAPHIC$BIRTH_DATE));

# Calculate percent for third colum
dem_l3_ageyrsdist2 [,3] <- round(100*(dem_l3_ageyrsdist2[,2]/
                                      sum(dem_l3_ageyrsdist2[,2]) ),
                                 digits = dem_sig);

#-----------------------------+
# dem_l3_hispdist
#-----------------------------+

# Create empty data frame with 8 rows
dem_l3_hispdist <- data.frame ( HISPANIC = character(8),
                               record_n = numeric(8),
                               record_pct = numeric(8),
                               Stringsasfactors=FALSE);

# Add the labels to the first column
dem_l3_hispdist[,1] = c ("N","R","Y","NI","UN","OT","Null or missing",
                          "VALUES outside of CDM specifications");
                          
# Calculate the values
dem_l3_hispdist [1,2] <- length ( (which(DEMOGRAPHIC$HISPANIC=="N")) );
dem_l3_hispdist [2,2] <- length ( (which(DEMOGRAPHIC$HISPANIC=="R")) );
dem_l3_hispdist [3,2] <- length ( (which(DEMOGRAPHIC$HISPANIC=="Y"))  );
dem_l3_hispdist [4,2] <- length ( (which(DEMOGRAPHIC$HISPANIC=="NI")) );
dem_l3_hispdist [5,2] <- length ( (which(DEMOGRAPHIC$HISPANIC=="UN")) );
dem_l3_hispdist [6,2] <- length ( (which(DEMOGRAPHIC$HISPANIC=="OT")) );
dem_l3_hispdist [7,2] <- sum(is.na(DEMOGRAPHIC$HISPANIC));
# the following is not good logic
dem_l3_hispdist [8,2] <- nrow(DEMOGRAPHIC) - sum(dem_l3_hispdist[1:7,2]);

# Calculate percent for third column
# Assuming this is reporting a percent and not a ratio

dem_l3_hispdist [,3] <- round(100*( dem_l3_hispdist[,2]/
                                   sum(dem_l3_hispdist[,2]) ),
                              digits = dem_sig);


#-----------------------------+
# dem_l3_racedist
#-----------------------------+

# Create empty data frame with 12 rows
dem_l3_racedist <- data.frame (RACE = character(12),
                              record_n = numeric(12),
                              record_pct = numeric(12),
                              stringsAsFactors=FALSE);

dem_l3_racedist[,1] <- c ("01", "02", "03", "04", "05", "06", "07",
                          "NI", "UN", "OT", "NULL or missing",
                          "Values outside of CDM specifications");


dem_l3_racedist[1,2] <- length ( (which(DEMOGRAPHIC$RACE=="01")) );
dem_l3_racedist[2,2] <- length ( (which(DEMOGRAPHIC$RACE=="02")) );
dem_l3_racedist[3,2] <- length ( (which(DEMOGRAPHIC$RACE=="03")) );
dem_l3_racedist[4,2] <- length ( (which(DEMOGRAPHIC$RACE=="04")) );
dem_l3_racedist[5,2] <- length ( (which(DEMOGRAPHIC$RACE=="05")) );
dem_l3_racedist[6,2] <- length ( (which(DEMOGRAPHIC$RACE=="06")) );
dem_l3_racedist[7,2] <- length ( (which(DEMOGRAPHIC$RACE=="07")) );
dem_l3_racedist[8,2] <- length ( (which(DEMOGRAPHIC$RACE=="NI")) );
dem_l3_racedist[9,2] <- length ( (which(DEMOGRAPHIC$RACE=="UN")) );
dem_l3_racedist[10,2] <- length ( (which(DEMOGRAPHIC$RACE=="OT")) );
dem_l3_racedist[11,2] <- sum(is.na(DEMOGRAPHIC$RACE));
# The following is not good logic
dem_l3_racedist[12,2] <- nrow(DEMOGRAPHIC) - sum( dem_l3_racedist[1:11,2]);

# Calculate percent
dem_l3_racedist [,3] <- round(100*(dem_l3_racedist[,2]/
                                   sum(dem_l3_racedist[,2]) ),
                              digits = dem_sig);

#-----------------------------+
# dem_l3_sexdist
#-----------------------------+

dem_l3_sexdist <- data.frame (SEX = character(8),
                              record_n= numeric(8),
                              record_pct = numeric(8),
                              stringsAsFactors=FALSE);

dem_l3_sexdist[,1] <- c ("A", "F", "M", "NI", "UN", "OT",
                         "Null or missing",
                         "Values outside of CDM specifications");

dem_l3_sexdist[1,2] <- length( (which(DEMOGRAPHIC$SEX=="A")) );
dem_l3_sexdist[2,2] <- length( (which(DEMOGRAPHIC$SEX=="F")) );
dem_l3_sexdist[3,2] <- length( (which(DEMOGRAPHIC$SEX=="M")) );
dem_l3_sexdist[4,2] <- length( (which(DEMOGRAPHIC$SEX=="NI")) );
dem_l3_sexdist[5,2] <- length( (which(DEMOGRAPHIC$SEX=="UN")) );
dem_l3_sexdist[6,2] <- length( (which(DEMOGRAPHIC$SEX=="OT")) );
dem_l3_sexdist[7,2] <- sum(is.na(DEMOGRAPHIC$SEX));
# The following may need to be fixed
dem_l3_sexdist[8,2] <- nrow(DEMOGRAPHIC) - sum(dem_l3_sexdist[1:7,2]);

# Calculate percent
dem_l3_sexdist [,3] <- round(100*(dem_l3_sexdist[,2]/
                                  sum(dem_l3_sexdist[,2]) ),
                             digits = dem_sig);
