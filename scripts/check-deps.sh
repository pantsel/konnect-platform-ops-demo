# Check if dependencies are installed
# Dependencies: docker, kind

# Define colors, red, blue and green
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'


# Check if docker is installed
echo -e "${BLUE}Checking if docker is installed...${NC}"
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install docker."
    echo "You can install Docker by following the instructions at: https://docs.docker.com/get-docker/"
    exit 1
else
    echo -e "${GREEN}Docker is installed.${NC}"
fi

# Check if kind is installed
echo -e "${BLUE}Checking if kind is installed...${NC}"
if ! command -v kind &> /dev/null; then
    echo "Kind is not installed. Please install kind."
    echo "You can install Kind by following the instructions at: https://kind.sigs.k8s.io/docs/user/quick-start/"
    exit 1
else
     echo -e "${GREEN}Kind is installed.${NC}"
fi

echo -e "${GREEN}All dependencies are installed.${NC}"
