library(readxl)

data = read_excel("data/contributors_mapping_results.xlsx")
data$custom_id = NULL

yn_vars =  c("focus_on_pandemic_preparedness_and_response",
             "focus_on_health_systems_strengthening",
             "focus_on_gender",
             "focus_on_climate_change",
             "support_development_of_norms_and_standards",
             "ethics_in_science_and_research",
             "foresight",
             "strengthening_research_ecosystems",
             "translating_science_and_evidence_into_policy_and_action",
             "implementation_research",
             "dissemination_of_scientific_knowledge",
             "equitable_access_to_scientific_information_data_and_publications")



yn_df = apply(data[, yn_vars], 2, function(x){
  
  stringr::str_extract(tolower(x), "^yes|^no|^Yes|^No")

})

colnames(yn_df) = paste0("yn_", yn_vars)

df_new = cbind(data[, !colnames(data) %in% yn_vars], yn_df)


saveRDS(df_new, "shiny_app/contributors_mapping_results_processed.rds")
