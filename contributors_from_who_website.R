



y24 = read.csv("data/voluntary_contributions_specified_2024.csv")
y26 = read.csv("data/voluntary_contributions_specified_2026.csv")

head(y24)
y24$Amount = gsub("[[:punct:]]", "", y24$Amount)
y24$Amount = gsub("K", "000", y24$Amount)
y24$Amount = as.numeric(y24$Amount)
y24$biennum = rep(2024, nrow(y24))

head(y26)
y26 = y26[, c("Organization", "Amount_USD")]
y26$biennum = rep(2026, nrow(y26))
colnames(y26) = colnames(y24)


con = rbind(y24, y26)
write.csv(con, "data/all_contributors_2426.csv")

unique(con$Contributor)


### import donors from IATI data
donations_iati = readRDS("data/donors_and_yearly_disbursements.rds")

# concat all donors (who and iati) into a single vector
all_donors = c(con$Contributor, donations_iati$donor_name)

# quick and dirty cleaning to remove duplicates
all_donors = gsub("EN[[:punct:]] |FR[[:punct:]] ", "", all_donors)
all_donors = tolower(all_donors)
all_donors = trimws(all_donors)
all_donors = unique(all_donors)

# create dataframe for processing in gemini
all_donors = data.frame(id = seq(1, length(all_donors), 1),
                        donor_name  = all_donors)

write.csv(all_donors, "data/all_contributors_2426_with_iati.csv", row.names = F)
