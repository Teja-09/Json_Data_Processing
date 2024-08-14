library(jsonlite)
library(dplyr)
library(urltools)  # Ensure this is loaded in the main process
library(digest)
library(parallel)

# Load the JSON file without flattening
json_data <- fromJSON("response.json", flatten = FALSE)

# Function to resolve IP address from domain
resolve_ip <- function(domain) {
  ip <- tryCatch({
    ip_output <- suppressWarnings(system(paste("nslookup -type=A", domain), intern = TRUE))
    ip_lines <- grep("Addresses|Address", ip_output, value = TRUE)[2]
    ip <- gsub("\\bAddress(es)?:\\s*", "", ip_lines) # Matches "Addresses: " or "Address: " and removes it
    return(ip)
  }, error = function(e) {
    return(NA)
  })
  return(ip)
}

# Function to process each notice and resolve IP addresses
process_notice <- function(i, json_data) {
  # Load the urltools package within each worker
  library(urltools)
  
  notice <- json_data$notices[i, ]
  
  notice_id <- notice$id
  notice_type <- notice$type
  notice_title <- notice$title
  date_sent <- notice$date_sent
  date_received <- notice$date_received
  sender_name <- notice$sender_name
  principal_name <- notice$principal_name
  recipient_name <- notice$recipient_name
  
  works <- notice$works[[1]]
  
  record_list <- list()
  
  for (j in 1:nrow(works)) {
    work_description <- works$description[j]
    infringing_urls <- works$infringing_urls[[j]]
    
    for (k in 1:nrow(infringing_urls)) {
      infringing_url <- infringing_urls$url[k]
      domain <- domain(infringing_url)
      
      # Resolve the IP address for the domain
      ip_address <- resolve_ip(domain)
      
      record_list[[length(record_list) + 1]] <- data.frame(
        notice_id = notice_id,
        notice_type = notice_type,
        notice_title = notice_title,
        date_sent = date_sent,
        date_received = date_received,
        sender_name = sender_name,
        principal_name = principal_name,
        recipient_name = recipient_name,
        work_description = work_description,
        infringing_url = infringing_url,
        domain = domain,
        ip_address = ip_address,
        stringsAsFactors = FALSE
      )
    }
  }
  
  return(record_list)
}

# Detect the number of cores and use 4 cores for parallel processing
num_cores <- min(20, detectCores())

# Create a cluster for parallel processing
cl <- makeCluster(num_cores)

# Export necessary variables and functions to the cluster
clusterExport(cl, list("json_data", "resolve_ip", "process_notice"))

# Load the urltools package in each worker
clusterEvalQ(cl, library(urltools))

# Process notices in parallel
results <- parLapply(cl, 1:nrow(json_data$notices), process_notice, json_data = json_data)

# Stop the cluster
stopCluster(cl)

# Combine results into a single data frame
flattened_data <- bind_rows(do.call(c, results))

# Write the flattened data to a CSV file
write.csv(flattened_data, "flattened_data_with_domains_ip_r.csv", row.names = FALSE)

# Confirmation message
print("The JSON data has been flattened, domains and IP addresses resolved, and saved to flattened_data_with_domains_ip_r.csv")
