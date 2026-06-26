#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar  3 05:17:03 2026

@author: mesozoik
"""

import pandas as pd
import json
import openpyxl
from datetime import date




data = []

with open('/home/mesozoik/Documents/WHO/margo_donors/data/contributors_mapping_2.jsonl', 'r') as f:
    for line in f:
        record = json.loads(line)
        
        # 1. Extract the metadata
        custom_id = record.get("custom_id")
        body = record.get("response", {}).get("body", {})
        usage = body.get("usage", {})
        
        # 2. Parse the internal stringified JSON in 'content'
        content_str = body.get("choices", [{}])[0].get("message", {}).get("content", "{}")
        try:
            content_data = json.loads(content_str)
            mappings = content_data.get("results", [])
        except json.JSONDecodeError:
            mappings = []

        # 3. Flatten the structure
        for mapping in mappings:
            data.append({
                "custom_id": mapping.get("custom_id"),
                "donor_name": mapping.get("donor_name"),
                "country_of_organization": mapping.get("country_of_organization"),
                "summary_info": mapping.get("summary_info"),
                "key_areas_of_work": mapping.get("key_areas_of_work"),
                "preparedness_related_funding": mapping.get("preparedness_related_funding"),
                "focus_on_pandemic_preparedness_and_response": mapping.get("focus_on_pandemic_preparedness_and_response"),
                "focus_on_health_systems_strengthening": mapping.get("focus_on_health_systems_strengthening"),
                "focus_on_gender": mapping.get("focus_on_gender"),
                "focus_on_climate_change": mapping.get("focus_on_climate_change"),
                "support_development_of_norms_and_standards": mapping.get("support_development_of_norms_and_standards"),
                "ethics_in_science_and_research": mapping.get("ethics_in_science_and_research"),
                "foresight": mapping.get("foresight"),
                "strengthening_research_ecosystems": mapping.get("strengthening_research_ecosystems"),
                "translating_science_and_evidence_into_policy_and_action": mapping.get("translating_science_and_evidence_into_policy_and_action"),
                "implementation_research": mapping.get("implementation_research"),
                "dissemination_of_scientific_knowledge": mapping.get("dissemination_of_scientific_knowledge"),
                "equitable_access_to_scientific_information_data_and_publications": mapping.get("equitable_access_to_scientific_information_data_and_publications"),
                "focus_region_or_country": mapping.get("focus_region_or_country"),
                "grant_size": mapping.get("grant_size"),
                "application_procedure": mapping.get("application_procedure"),
                "application_procedure_details": mapping.get("application_procedure_details"),
                "application_procedure_contact": mapping.get("application_procedure_contact"), 
                "website_of_donor_organization": mapping.get("website_of_donor_organization"),
                "donor_category": mapping.get("donor_category")
            })

# 4. Create the DataFrame
df = pd.DataFrame(data)


   
# Save the DataFrame to an Excel file without the row numbers (index)
df.to_excel("/home/mesozoik/Documents/WHO/margo_donors/data/contributors_mapping_results.xlsx",
                index=False,
                engine='openpyxl')
    
    
 