# Check if dependencies are installed
# Dependencies: docker, kind, terraform

# Define colors, red, blue and green
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'
YELLOW='\033[1;33m'


# Check if docker is installed
echo -e "${BLUE}Checking if docker is installed...${NC}"
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install docker."
    echo "You can install Docker by following the instructions at: https://docs.docker.com/get-docker/"
    exit 1
else
    echo -e "${GREEN}Docker is installed.${NC}"
fi

# Check if kind OR orbstack is installed.

echo -e "${BLUE}Checking if kind is installed...${NC}"
kind_installed=true
if ! command -v kind &> /dev/null; then
    echo -e "${RED}Kind is not installed.${NC}"
    kind_installed=false
else
    echo -e "${GREEN}Kind is installed.${NC}"
fi

echo -e "${BLUE}Checking if orbstack is installed...${NC}"
orbstack_installed=true
if ! command -v orb &> /dev/null; then
    echo -e "${YELLOW}Orbstack is not installed.${NC}"
    orbstack_installed=false
else
    echo -e "${GREEN}Orbstack is installed.${NC}"
fi

if [ "$kind_installed" = false ] && [ "$orbstack_installed" = false ]; then
    echo -e "${RED}Neither kind nor orbstack is installed. Please install at least one of them.${NC}"
    echo "You can install kind by following the instructions at: https://kind.sigs.k8s.io/docs/user/quick-start/"
    echo "You can install orbstack by following the instructions at: https://docs.orbstack.dev/"
    exit 1
fi

# Check if terraform is installed
echo -e "${BLUE}Checking if terraform is installed...${NC}"
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Terraform is not installed. Please install terraform.${NC}"
    echo "You can install Terraform by following the instructions at: https://learn.hashicorp.com/terraform/getting-started/install.html"
    exit 1
else
    echo -e "${GREEN}Terraform is installed.${NC}"
fi

# Check if gh cli is installed
echo -e "${BLUE}Checking if GitHub CLI is installed...${NC}"
if ! command -v gh &> /dev/null; then
    echo -e "${RED}GitHub CLI is not installed. Please install GitHub CLI.${NC}"
    echo "You can install GitHub CLI by following the instructions at: https://cli.github.com/"
    exit 1
else
    echo -e "${GREEN}GitHub CLI is installed.${NC}"
fi

echo -e "${GREEN}All dependencies are installed.${NC}"