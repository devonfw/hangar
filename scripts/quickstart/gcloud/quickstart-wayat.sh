# # https://github.com/devonfw/hangar/tree/master/setup
# docker build -t hangar -f ./setup/Dockerfile .
# docker run --rm -it -v /Users/$env:UserName/AppData/Roaming/gcloud:/root/.config/gcloud -v /Users/$env:UserName/AppData/Roaming/configstore:/root/.config/configstore -v /Users/$env:UserName/.aws:/root/.aws -v /Users/$env:UserName/.azure:/root/.azure -v /Users/$env:UserName/.kube:/root/.kube -v "/Users/$env:UserName/AppData/Roaming/GitHub CLI:/root/.config/gh" -v /Users/$env:UserName/.ssh:/root/.ssh -v /Users/$env:UserName/hangar_workspace:/hangar_workspace -v /Users/$env:UserName/.gitconfig:/root/.gitconfig -v ./scripts:/scripts hangar bash
gcloud auth login
firebase login --no-localhost
echo "Please write the project ID:" && read project_id
description_project="Quickstart Wayat"
region="europe-west6"
zone="europe-west6-a"
firebase_region="europe-west6"
frontendName="Frontend-Flutter"
backendName="Backend-Python"
frontendLanguage="flutter"
frontendLanguage_version=3.3.4
backendLanguage="python"
backendLanguage_version=3.10
echo "Please write your billing account." && read billing_account
workspace_base=/workspace
mkdir -p $workspace_base/$project_id
workspace=$workspace_base/$project_id
sa_name=sa-hangar
# Create project
/scripts/accounts/gcloud/create-project.sh -n "$project_id" -d "$description_project" -b "$billing_account" --firebase
# Create SA
/scripts/accounts/gcloud/setup-principal-account.sh -s "$sa_name" -p "$project_id" -f /scripts/accounts/gcloud/predefined-roles.txt -k "$workspace/key.json"
/scripts/accounts/gcloud/verify-principal-roles-and-permissions.sh -s $sa_name -p "$project_id" -f /scripts/accounts/gcloud/predefined-roles.txt
gcloud auth activate-service-account --key-file="$workspace/key.json"
# Create repos
/scripts/repositories/gcloud/create-repo.sh -a create -s gitflow -p "$project_id" -n "$frontendName" -d "$workspace"
/scripts/repositories/gcloud/create-repo.sh -a create -s gitflow -p "$project_id" -n "$backendName" -d "$workspace"
# Create Sonarqube
mkdir -p $workspace/sonarqube
cd /scripts/sonarqube/gcloud/
./sonarqube.sh apply --state-folder "$workspace/sonarqube" --service_account_file "$workspace/key.json" --project "$project_id" --region "$region" --zone "$zone"
sonarqube_token=$(grep "sonarqube_token" "$workspace/sonarqube/terraform.tfoutput" | cut -d' ' -f 3 | sed 's/^.//;s/.$//')
sonarqube_url=$(grep "sonarqube_url" "$workspace/sonarqube/terraform.tfoutput" | cut -d' ' -f 3 | sed 's/^.//;s/.$//')
cd /scripts
# Get Cloud Run endpoints
/scripts/quickstart/gcloud/init-cloud-run.sh -p "$project_id" -n "${frontendName,,}" -r "$region" -o "$workspace/$frontendName-url.txt"
/scripts/quickstart/gcloud/init-cloud-run.sh -p "$project_id" -n "${backendName,,}" -r "$region" -o "$workspace/$backendName-url.txt"
# Setup firebase
/scripts/accounts/gcloud/setup-firebase.sh -n "$project_id" -o "$workspace" -r "$firebase_region" --enable-maps --setup-ios --setup-android --setup-web
# Quickstart apps
echo "Manual actions required. Read the info of the last command to more information."
echo "Please write the map secret token." && read map_secret
backend_url=$(<"$workspace/$backendName-url.txt")
frontend_url=$(<"$workspace/$frontendName-url.txt")
./quickstart/gcloud/quickstart-wayat-backend.sh -p "$project_id" -w "$workspace" -d "$workspace/$backendName" --storage-bucket "$project_id".appspot.com
./quickstart/gcloud/quickstart-wayat-frontend.sh -p "$project_id" -w "$workspace" -d "$workspace/$frontendName" --keystore "$workspace/keystore.jks" --backend-url $backend_url --frontend-url $frontend_url --maps-static-secret $map_secret
echo "Manual actions required. Read the info of the last command to more information. Press enter to continue..." && read
# Create backend pipelines
/scripts/pipelines/gcloud/pipeline_generator.sh -c /scripts/pipelines/gcloud/templates/build/build-pipeline.cfg -n "${backendName,,}"-build -d "$workspace/$backendName" -l $backendLanguage --language-version $backendLanguage_version -b develop
/scripts/pipelines/gcloud/pipeline_generator.sh -c /scripts/pipelines/gcloud/templates/test/test-pipeline.cfg -n "${backendName,,}"-test -d "$workspace/$backendName" -l $backendLanguage --language-version $backendLanguage_version --build-pipeline-name "${backendName,,}"-build -b develop
/scripts/pipelines/gcloud/pipeline_generator.sh -c /scripts/pipelines/gcloud/templates/quality/quality-pipeline.cfg -n "${backendName,,}"-quality -d "$workspace/$backendName" -l $backendLanguage --language-version $backendLanguage_version --build-pipeline-name "${backendName,,}"-build --test-pipeline-name "${backendName,,}"-test --sonar-url "$sonarqube_url" --sonar-token "$sonarqube_token" -b develop
/scripts/pipelines/gcloud/pipeline_generator.sh -c /scripts/pipelines/gcloud/templates/package/package-pipeline.cfg -i "$region"-docker.pkg.dev/"$project_id"/"${backendName,,}"/"${backendName,,}" -n "${backendName,,}"-package -d "$workspace/$backendName" -l $backendLanguage --language-version $backendLanguage_version --build-pipeline-name "${backendName,,}"-build --quality-pipeline-name "${backendName,,}"-quality -b develop
/scripts/pipelines/gcloud/pipeline_generator.sh -c /scripts/pipelines/gcloud/templates/deploy-cloud-run/deploy-cloud-run-pipeline.cfg -n "${backendName,,}"-deploy -d "$workspace/$backendName" -b develop --service-name "${backendName,,}" --gcloud-region "$region"
# Create frontend web pipelines
/scripts/pipelines/gcloud/pipeline_generator.sh -c /scripts/pipelines/gcloud/templates/build/build-pipeline.cfg -n "${frontendName,,}"-build -d "$workspace/$frontendName" -l "$frontendLanguage" --language-version "$frontendLanguage_version" --registry-location "$region" -b develop -m E2_HIGHCPU_8
/scripts/pipelines/gcloud/pipeline_generator.sh -c /scripts/pipelines/gcloud/templates/test/test-pipeline.cfg -n "${frontendName,,}"-test -d "$workspace/$frontendName" -l "$frontendLanguage" --language-version "$frontendLanguage_version" --registry-location "$region" --build-pipeline-name "${frontendName,,}"-build -b develop -m E2_HIGHCPU_8
/scripts/pipelines/gcloud/pipeline_generator.sh -c /scripts/pipelines/gcloud/templates/quality/quality-pipeline.cfg -n "${frontendName,,}"-quality -d "$workspace/$frontendName" -l "$frontendLanguage" --language-version "$frontendLanguage_version" --registry-location "$region" --build-pipeline-name "${frontendName,,}"-build --test-pipeline-name "${frontendName,,}"-test --sonar-url "$sonarqube_url" --sonar-token "$sonarqube_token" -b develop -m E2_HIGHCPU_8
/scripts/pipelines/gcloud/pipeline_generator.sh -c /scripts/pipelines/gcloud/templates/package/package-pipeline.cfg -i "$region"-docker.pkg.dev/"$project_id"/"${frontendName,,}"/"${frontendName,,}" -n "${frontendName,,}"-web-package -d "$workspace/$frontendName" -l "$frontendLanguage" --language-version "$frontendLanguage_version" --build-pipeline-name "${frontendName,,}"-build --quality-pipeline-name "${frontendName,,}"-quality -b develop --registry-location "$region" --flutter-web-platform --flutter-android-platform canvaskit -m E2_HIGHCPU_8
/scripts/pipelines/gcloud/pipeline_generator.sh -c /scripts/pipelines/gcloud/templates/deploy-cloud-run/deploy-cloud-run-pipeline.cfg -n "${frontendName,,}"-web-deploy -d "$workspace/$frontendName" -b develop --service-name "${frontendName,,}" --gcloud-region "$region" --port 80 -m E2_HIGHCPU_8