import json
import pandas as pd
from urllib.parse import urlparse
import socket
from multiprocessing import Pool

def flatten_json(json_data):
    # Initialize an empty list to store flattened records
    records = []

    # Iterate over each notice
    for notice in json_data['notices']:
        notice_id = notice['id']
        notice_type = notice['type']
        notice_title = notice['title']
        date_sent = notice['date_sent']
        date_received = notice['date_received']
        sender_name = notice['sender_name']
        principal_name = notice['principal_name']
        recipient_name = notice['recipient_name']

        # Iterate over each work
        for work in notice['works']:
            work_description = work['description']

            # Iterate over each infringing URL
            for infringing_url in work['infringing_urls']:
                url = infringing_url['url']
                
                # Add the flattened record to the list
                records.append({
                    'notice_id': notice_id,
                    'notice_type': notice_type,
                    'notice_title': notice_title,
                    'date_sent': date_sent,
                    'date_received': date_received,
                    'sender_name': sender_name,
                    'principal_name': principal_name,
                    'recipient_name': recipient_name,
                    'work_description': work_description,
                    'infringing_url': url
                })

    return records

def get_ip(domain):
    try:
        return socket.gethostbyname(domain)
    except socket.gaierror:
        return 'IP not found'
    except socket.timeout:
        return 'Timeout'

def parallelize_ip_resolution(domains, num_cores=4):
    with Pool(num_cores) as pool:
        ip_addresses = pool.map(get_ip, domains)
    return ip_addresses

if __name__ == '__main__':
    # Load the JSON data
    with open('C:/Users/krishnateja/OneDrive - University of Arizona/MS-Resources/Nikhila/Task_1/response.json', encoding='utf-8') as f:
        data = json.load(f)

    # Flatten the JSON data
    records = flatten_json(data)

    # Convert the list of records to a DataFrame
    df = pd.DataFrame(records)

    # Extract domain from infringing URL
    df['domain'] = df['infringing_url'].apply(lambda x: urlparse(x).netloc)

    # Parallelize the IP resolution using 4 CPUs
    df['ip_address'] = parallelize_ip_resolution(df['domain'].tolist(), num_cores=6)

    # Save the updated DataFrame to a CSV file
    output_csv_path = 'flattened_with_domain_and_ip_python.csv'
    df.to_csv(output_csv_path, index=False)

    print(f"CSV file saved to {output_csv_path}")
