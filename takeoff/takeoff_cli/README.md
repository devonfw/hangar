== devonfw Takeoff CLI

This is a simpler and user-friendly interface for creating and managing projects using CLI command line.

== Requirements
:url-get-docker:  https://docs.docker.com/get-docker/
:url-hangar-setup:  https://github.com/devonfw/hangar/blob/master/setup/README.asciidoc

For using TakeOff need to be installed:

* Docker       (just follow the docker official docs {url-get-docker}[Get Docker])
* Hangar image (just follow the hangar docs {url-hangar-setup}[How to setup and use the image])

== How to use TakeOff CLI

```
takeoff <command> <subcommand> [arguments]
```

== Commands
```
  aws         (using AWS Cloud Services)
  azure       (using Azure Cloud Services)
  gc          (using Google Cloud Services)
  quickstart
```

== Subcommands
```
  init --account [account]
  create [arguments]
  run --project [projectId]
  list
  web --project [projectId] [arguments]
  clean --id [projectId]
```

== Create arguments
```
  -h, --help 
  -n, --name [projectName]             
  -a, --billing-account [billingAccount]   
  -b, --backend-language  [node, python, quarkus, quarkus-jvm]
      --backend-version
  -f, --frontend-language [angular, flutter]
      --frontend-version
  -r, --region [region]
```

== Web arguments
```
  -h, --help 
  -p, --project [projectId]
  -r, --resource [ide, pipeline, fe-repo, be-repo]
```

== QuickStart commands
```
  viplane   Automatically creates and deploys all the necessary services and resources to have VipLane on the cloud
  wayat     Automatically creates and deploys all the necessary services and resources to have Wayat on the cloud.
```