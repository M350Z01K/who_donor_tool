#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 26 19:53:11 2026

@author: mesozoik
"""

from google import genai
import pandas as pd
import sys


#%% init model
client = genai.Client() # Assumes API key is in env: GOOGLE_API_KEY
model_name = "gemini-2.5-flash" 

    

#%% List your last 5 batch jobs to check progress
for job in client.batches.list(config={'page_size': 5}):
    # Accessing the creation timestamp
 
    print(f"Display Name: {job.display_name}")
    print(f"Submitted:    {job.create_time.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"System Name:  {job.name}")
    print(f"Current State: {job.state}")


# 1. Initialize an empty list to store row data
job_data = []

# 2. Iterate through the batches
for job in client.batches.list(config={'page_size': 5}):
    # Create a dictionary for the current job
    row = {
        "Display Name": job.display_name,
        "Submitted": job.create_time.strftime('%Y-%m-%d %H:%M:%S'),
        "System Name": job.name,
        "Current State": job.state
    }
    
    # 3. Append the dictionary to our list
    job_data.append(row)

# 4. Create the DataFrame
df_jobs = pd.DataFrame(job_data)


# filter the dataframe for most recent jobs
df_jobs = df_jobs.sort_values(by='Submitted', ascending=False)
df_jobs = df_jobs.iloc[0,]
df_jobs = df_jobs[df_jobs['Current State'] == "JOB_STATE_SUCCEEDED"]




# convert to list of job ids
job_ids = df_jobs['System Name']
    

# retrieve results for one single job

job = client.batches.get(name=job_ids)
output_file_name = job.dest.file_name 
content_bytes = client.files.download(file=output_file_name)
# 4. Save to your local directory
with open("/home/mesozoik/Documents/WHO/margo_donors/data/contributors_mapping.jsonl", "wb") as f:
    f.write(content_bytes)

