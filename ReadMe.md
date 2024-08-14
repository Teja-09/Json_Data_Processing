
# JSON Data Processing Script

This repository contains a Python script that processes a JSON file containing DMCA notices, flattens the nested JSON data, extracts domain information from URLs, resolves the corresponding IP addresses, and saves the final data to a CSV file.

## Prerequisites

Before running the script, ensure you have the following software installed:

- Python 3.x
- Required Python packages (`pandas`, `json`, `multiprocessing`, `socket`, `urllib`)

## Setup

1. **Clone the Repository:**

   Clone the repository to your local machine using:
   ```bash
   git clone https://github.com/your-repository-link.git
   ```

2. **Navigate to the Project Directory:**

   Go to the directory where the script is located:
   ```bash
   cd path-to-your-directory
   ```

3. **Install Required Python Packages:**

   Install the necessary Python packages using `pip`:
   ```bash
   pip install pandas
   ```

   If additional packages are needed:
   ```bash
   pip install [package_name]
   ```

## Usage

1. **Place the JSON File:**

   Ensure your `response.json` file is located in the `Task_1` directory. You can replace the sample JSON file with your actual data.

2. **Run the Script:**

   Execute the script by running:
   ```bash
   python app.py
   ```

   Make sure to replace `app.py` with the actual name of your Python script if it's different.

3. **Output:**

   After running the script, a CSV file named `flattened_with_domain_and_ip.csv` will be generated in the same directory. This file contains the flattened data along with the resolved IP addresses.

## Script Explanation

- **Flatten JSON:** The script begins by flattening the nested JSON structure, iterating over each notice and its associated works and infringing URLs.
- **Extract Domain:** The script extracts the domain name from each infringing URL.
- **Resolve IP Addresses:** The script uses multiprocessing to efficiently resolve the IP addresses for each domain.
- **Save to CSV:** The final data, including notice details, domain, and IP address, is saved to a CSV file.

## Customization

- **Number of Cores:** The script uses 30 cores by default for parallel processing. You can adjust this number by changing the `num_cores` parameter in the `parallelize_ip_resolution` function.
- **File Paths:** Ensure that the file paths in the script are correctly set to your local directories.