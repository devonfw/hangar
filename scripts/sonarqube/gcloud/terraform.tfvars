#service account credentials file
service_account_file = ".key-secrets/sonarqube-gcloud.json"
#The ID of the project in which the resource belongs
project = "sonarqube-gcloud"
#GCloud region code of the location where the resources will be created
region = "europe-southwest1"
#The zone inside the region that the machine should be created in
zone = "europe-southwest1-a"
#The range of internal addresses that are owned by this subnetwork. Ranges must be unique and non-overlapping within a network
subnet_cidr_range = "10.0.1.0/24"
#Machine Instance type
machine_type = "e2-medium"
