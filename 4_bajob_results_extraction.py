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

with open('/home/mesozoik/Documents/WHO/margo_donors/data/contributors_mapping.jsonl', 'r') as f:
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
                "focus_region_or_country": mapping.get("focus_region_or_country"),
                "grant_size": mapping.get("grant_size"),
                "application_procedure": mapping.get("application_procedure")
            })

# 4. Create the DataFrame
df = pd.DataFrame(data)



   
# Save the DataFrame to an Excel file without the row numbers (index)
df.to_excel("/home/mesozoik/Documents/WHO/margo_donors/data/contributors_mapping_results.xlsx",
                index=False,
                engine='openpyxl')
    
    
    



