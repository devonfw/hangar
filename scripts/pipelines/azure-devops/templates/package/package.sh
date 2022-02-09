while getopts f:t:c:u:p:r:i: flag
do
    case "${flag}" in
        f) dockerFile=${OPTARG};;
        t) tag=${OPTARG};;
        c) context=${OPTARG};;
        u) username=${OPTARG};;
        p) password=${OPTARG};;
		r) registry=${OPTARG};;
        i) imageName=${OPTARG};;
    esac
done

echo "docker build -f $dockerFile -t $imageName:$tag $context"
docker build -f $dockerFile -t $imageName:$tag $context
echo "docker login -u=$username -p=$password"
docker login -u="$username" -p="$password" $registry
echo "docker push $imageName:$tag"
docker push $imageName:$tag
echo "Also pushing the image as 'latest'"
docker tag $imageName:$tag $imageName:latest
docker push $imageName:latest