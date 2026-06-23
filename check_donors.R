donations = readRDS("data/donors_and_yearly_disbursements.rds")


donations[donations$donor_id == "US-USAGOV",]

# clean up donor_name field
trimws(gsub("EN:|DE:", "", donations$donor_name[1:10]))
# TODO
# double check whether donators are in template file
# double check whether donators are in eswatini file
# check official developmental assistance -> governmental assistance -> https://www.oecd.org/en/topics/sub-issues/oda-trends-and-statistics.html 20 top donators 
# 
# import oecd ODA data ----
oda = read.csv("data/OECD.DCD.FSD,DSD_DAC1@DF_DAC1,1.2+DAC+AUS+AUT+BEL+CAN+CZE+DNK+EST+FIN+FRA+DEU+GRC+HUN+ISL+IRL+ITA+JPN+KOR+LTU+LUX+NLD+NZL+NOR+POL+PRT+SVK+SVN+ESP+SWE+CHE+GBR+USA.1010..1140+1160.PT_B5G+USD.Q..csv")

# get top 30 contributors in 2023
cols_to_keep = c("Donor", "OBS_VALUE")

oda = oda[oda$TIME_PERIOD == 2023 & oda$Flow.type == "Disbursements, net", cols_to_keep]

top_30 = oda[order(oda$OBS_VALUE, decreasing = T), ]
top_30 = top_30[2:31, ]
top_30
