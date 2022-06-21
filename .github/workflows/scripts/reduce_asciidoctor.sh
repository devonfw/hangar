#!/bin/bash
for i in $(find documentation/src -type f -name "*asciidoc" -not -path "*common_templates*")
do
  asciidoctor-reducer -o "${i//src\//}" "$i"
done