while getopts f:t:c:u:p:r:i:b: flag
do
    case "${flag}" in
        f) dockerFile=${OPTARG};;
        t) tag=${OPTARG};;
        c) context=${OPTARG};;
        u) username=${OPTARG};;
        p) password=${OPTARG};;
		r) registry=${OPTARG};;
        i) imageName=${OPTARG};;
        b) branch=${OPTARG};;
    esac
done

branch_short=$(echo $branch | awk -F '/' '{ print $NF }')
echo $branch | grep feature && imageName_completed="${imageName}_development" && tag_completed="${tag}_${branch_short}"
echo $branch | grep develop && imageName_completed="${imageName}_test" && tag_completed="${tag}"
(echo $branch | grep master || echo $branch | grep release ) && imageName_completed="${imageName}_production" && tag_completed="${branch_short}"
echo "docker build -f $dockerFile -t $imageName_completed:$tag_completed $context"
docker build -f $dockerFile -t $imageName_completed:$tag_completed $context
echo "docker login -u=$username -p=$password"
docker login -u="$username" -p="$password" $registry
echo "docker push $imageName_completed:$tag_completed"
docker push $imageName_completed:$tag_completed
echo "Also pushing the image as 'latest'"
docker tag $imageName_completed:$tag_completed $imageName_completed:latest
docker push $imageName_completed:latest