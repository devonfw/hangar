for i in $(find documentation/src -type f -name "*asciidoc")
do
  asciidoctor-reducer -o "${i//src\//}" "$i"
done