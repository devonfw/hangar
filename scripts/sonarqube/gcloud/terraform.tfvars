#service account credentials file
service_account_file = ".secrets/key.json"
#The ID of the project in which the resource belongs
project = "test-jorge-367510"
#GCloud region code of the location where the resources will be created
region = "europe-southwest1"
#The zone inside the region that the machine should be created in
zone = "europe-southwest1-a"
#The range of internal addresses that are owned by this subnetwork. Ranges must be unique and non-overlapping within a network
subnet_cidr_block = "10.0.1.0/24"
#Machine Instance type
instance_type = "e2-medium"
#Password to connect with sonarqube, this password is to read from sonarqube, not to replace the password value.
sonarqube_password = "admin"
