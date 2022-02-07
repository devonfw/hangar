while getopts f:t:c:u:p:r: flag
do
    case "${flag}" in
        f) dockerFile=${OPTARG};;
        t) tag=${OPTARG};;
        c) context=${OPTARG};;
        u) username=${OPTARG};;
        p) password=${OPTARG};;
		r) registry=${OPTARG};;
    esac
done

echo "docker build -f $dockerFile -t $tag $context"
docker build -f $dockerFile -t $tag $context
echo "docker login -u=$username -p=$password"
docker login -u="$username" -p="$password" $registry
echo "docker push $tagAndRepo"
docker push $tag