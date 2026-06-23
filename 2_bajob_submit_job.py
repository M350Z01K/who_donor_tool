#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed May 27 15:48:25 2026

@author: mesozoik
"""

from google import genai

client = genai.Client()

# 1. Upload your newly generated input file
uploaded_file = client.files.upload(file="/home/mesozoik/Documents/WHO/margo_donors/data/gemini_batch_input_3.jsonl", config={'mime_type': 'text/plain'})

# 2. Kick off the batch job
batch_job = client.batches.create(
    model="gemini-2.5-flash",
    src=uploaded_file.name,
    config={"display_name": "donor-info-extraction_3rd_iteration"}
)

print(f"Batch job submitted successfully. Job ID: {batch_job.name}")

