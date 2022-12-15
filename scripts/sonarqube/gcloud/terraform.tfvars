#Service account credentials file
service_account_file = "key.json"
#The ID of the project in which the resource belongs
project = "hangar"
#GCloud region code of the location where the resources will be created
region = "europe-southwest1"
#The zone inside the region that the machine should be created in
zone = "europe-southwest1-a"
#The range of internal addresses that are owned by this subnetwork. Ranges must be unique and non-overlapping within a network
subnet_cidr_block = "10.0.1.0/29"
#Machine Instance type
instance_type = "e2-medium"
