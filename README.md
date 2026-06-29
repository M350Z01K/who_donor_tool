# WHO Donor Tool


This tool is intended to facilitate the identification of contributors susceptible of funding WHO projects. 

## Data

### IATI

Download the zip file under the [IATI website](https://tables.iatistandard.org/). The script `extract_donors_yearly_donations.R` generates a file `donors_and_yearly_disbursements.rds`

### WHO contributor data

Download the extracted data (voluntary contributions for the 2024-25 and 2026-27 biennums) from the [WHO budget portal](https://open.who.int/2024-25/contributors/by-fund-types/vcs) under the following [link](https://drive.google.com/drive/folders/1pPfzelrKjnVDcWoRwQ2hje0o-jyJezyU?usp=sharing). The script `contributors_from_who_website.R` organizes WHO and IATI data and makes it ready for the next step. 


## LLM Magic

Be aware that you will need to get an [API key](https://ai.google.dev/gemini-api/docs/api-key) to run the following scripts.

The following scripts form the LLM pipeline that extract the data specified by the hardcoded prompt 

- `1_bajob_create_json_prompt.py` (contains the prompt)
- `2_bajob_submit_job.py` (batch submission to gemini)
- `3_bajob_download_results.py` (check and download the results if ready)
- `4_bajob_results_extraction.py` (conversion of the results in human-friendly form)


## Visualization via Shiny application

- the script `process_mapping_results.R` cleans up the data for visualization. The script `shiny_app/shiny_app.R` builds the visualization tool.

The results can be visualized in form of filterable table under the following url: https://mesozoik.shinyapps.io/who_contrib_search_tool/

## Future improvements

Bear in mind that the present tool is a proof-of-concept and future iterations should focus on:
- validation of the LLM results
- prompt improvement
- visualization improvement




