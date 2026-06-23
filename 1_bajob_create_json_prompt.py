#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Apr 15 10:54:07 2026

@author: mesozoik
"""

import json
from google import genai
import pandas as pd



#%% create the prompt
prompt_template = """"
You are an expert looking for funding to support global health projects.
Search for the given donor organization in the health sector and extract the required parameters into the requested JSON schema.
Do not include any markdown formatting, blocks, or conversational text. Return only raw JSON.
-country_of_organization
-summary_info
-key_areas_of_work
-preparedness_related_funding
-focus_on_pandemic_preparedness_and_response (yes or no)
-focus_on_health_systems_strengthening (yes or no)
-focus_on_gender (yes or no)
-focus_on_climate_change (yes or no)
-focus_on_support_development_of_norms_and_standards (yes or no)
-focus_on_ethics_in_science_and_research (yes or no)
-focus_on_foresight (yes or no)
-focus_on_strengthening_research_ecosystems (yes or no)
-focus_on_translating_science_and_evidence_into_policy_and_action (yes or no)
-focus_on_implementation_research (yes or no)
-focus_on_dissemination_of_scientific_knowledge (yes or no)
-focus_on_equitable_access_to_scientific_information_data_and_publications (yes or no)
-focus_region_or_country
-grant_size
-application_procedure 
-application_procedure_details (if application procedure is not explicitely described)
-application_procedure_contact (email address or website or both)
-website_of_donor_organization
-donor_category (government, foundations, philanthropy, or private entities)


### INSTRUCTIONS:
- For each, provide a few sentences justification.
- Return ONLY valid JSON in this format: 
{"results": [{"donor_name": "...",
              "country_of_organization": "...",
              "summary_info": "...",
              "key_areas_of_work": "...",
              "preparedness_related_funding": "...",
              "focus_on_pandemic_preparedness_and_response": "...",
              "focus_on_health_systems_strengthening": "...",
              "focus_on_gender": "...",
              "focus_on_climate_change": "...",
              "support_development_of_norms_and_standards": "...",
              "ethics_in_science_and_research": "...",
              "foresight": "...",
              "strengthening_research_ecosystems": "...",
              "translating_science_and_evidence_into_policy_and_action": "...",
              "implementation_research": "...",
              "dissemination_of_scientific_knowledge": "...",
              "equitable_access_to_scientific_information_data_and_publications": "...",
              "focus_region_or_country": "...",
              "grant_size": "...",
              "application_procedure": "...",
              "application_procedure_details": "...",
              "application_procedure_contact": "...",
              "website_of_donor_organization": "...",
              "donor_category": "..."}]}
"""



#%% Load donors dataset
data = pd.read_csv('/home/mesozoik/Documents/WHO/margo_donors/data/all_contributors_2426_with_iati.csv')
donors_list = data['donor_name'].unique().tolist()



#%% init model
client = genai.Client() # Assumes API key is in env: GOOGLE_API_KEY
model_name = "gemini-2.5-flash" 

# Generate the OpenAI-compatible JSONL content
json_requests = []
for donor in donors_list:
    req = {
        "custom_id": donor,
        "method": "POST",
        "url": "/v1/chat/completions",
        "body": {
            "model": model_name,
            "messages": [
                {"role": "system", "content": prompt_template},
                {"role": "user", "content": donor}
            ],
            "response_format": { "type": "json_object" }
        }
    }
    json_requests.append(req)

# # Write to file
file_path = "/home/mesozoik/Documents/WHO/margo_donors/data/gemini_batch_input_3.jsonl"
with open(file_path, "w") as f:
    for entry in json_requests:
        f.write(json.dumps(entry) + "\n")