#!/bin/bash
url=http://1.2.3.4:9000
login=6ce6663b63fc02881c6ea4c7cBa6563b8247a04e
mvn sonar:sonar -Dsonar.host.url=$url -Dsonar.login=$login -Dsonar.java.binaries=$1/target/classes
