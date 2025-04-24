import pandas as pd
import os
import json

schemas = json.load(open('C:/Users/8216609/OneDrive - Standard Chartered Bank/Documents/VSCode/Project1/Output/schemas.json'))
cdr = "Caller Details"
column_details = schemas[cdr]
column_name = list(map(lambda col: col["column_name"], column_details))

# --- CONFIGURATION ---

# Folder containing .xlsx files
folder_path = os.path.abspath("C:/Users/8216609/OneDrive - Standard Chartered Bank/Desktop/India CDR/2025/Mar'25")  

# Output CSV file path
output_file = os.path.abspath('combined_output.csv')

# How many rows to skip at the beginning
rows_to_skip = 6

# Get all .xlsx files in folder
file_list = [f for f in os.listdir(folder_path) if f.endswith('.xlsx') or f.endswith('.xls')]
 elif ext == ".xls":
            data = pd.read_csv(file_path,skiprows=3,header=None, usecols=[1])
            df_split = data.iloc[:, 0].str.split('\t', expand=True)
            df_split.columns = df_split.iloc[0]
            df = df_split.drop(0).reset_index(drop=True)
if not file_list:
    print("❌ No Excel files found in the folder.")
else:
    print(f"✅ Found {len(file_list)} Excel files.\n")

# Track whether to write header
first_file = True

# Loop through all Excel files
for file in file_list:
    file_path = os.path.join(folder_path, file)
    print(f"📄 Reading: {file}")

    try:
        # Read while skipping metadata/header rows
        df = pd.read_excel(file_path, skiprows=rows_to_skip)

        if not df.empty:
            df['Source File'] = file  # Optional: track origin

            # Append to CSV
            df.to_csv(output_file, mode='a', index=False, header=first_file)
            first_file = False
            print(f"   ✅ Appended to output")

        else:
            print(f"   ⚠️ Skipped empty file: {file}")

    except Exception as e:
        print(f"   ❌ Error reading {file}: {e}")

print(f"\n🎉 All files combined successfully into:\n{output_file}")
