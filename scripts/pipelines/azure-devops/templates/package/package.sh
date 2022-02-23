while getopts f:c:u:p:r:i:b:t: flag
do
    case "${flag}" in
        f) dockerFile=${OPTARG};;
        c) context=${OPTARG};;
        u) username=${OPTARG};;
        p) password=${OPTARG};;
	r) registry=${OPTARG};;
        i) imageName=${OPTARG};;
        b) branch=${OPTARG};;
	t) pomPath=${OPTARG};;
    esac
done
tag=$(grep version ${pomPath} | grep -v -e '<?xml'| head -n 1 | sed 's/[[:space:]]//g' | sed -E 's/<.{0,1}version>//g' | awk '{print $1}')
branch_short=$(echo $branch | awk -F '/' '{ print $NF }')

echo $branch | grep release && tag_completed="${tag}"
echo $branch | grep release || tag_completed="${tag}_${branch_short}"
echo "docker build -f $dockerFile -t $imageName:$tag_completed $context"
docker build -f $dockerFile -t $imageName:$tag_completed $context
echo "docker login -u=$username -p=$password"
docker login -u="$username" -p="$password" $registry
echo "docker push $imageName:$tag_completed"
docker push $imageName:$tag_completed
if echo $branch | grep release
then
	echo "Also pushing the image as 'latest' if this is a release"
	docker tag $imageName:$tag_completed $imageName:latest
	docker push $imageName:latest
fi