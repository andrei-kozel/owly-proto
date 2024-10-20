set -e # Exit on any error

SERVICES=$1 # Accept a list of services as a parameter (comma-separated string)
RELEASE_VERSION=$2

# Debug: Initial parameters
echo "::group::Debug: Parameters"
echo "SERVICES: $SERVICES"
echo "RELEASE_VERSION: $RELEASE_VERSION"
echo "::endgroup::"

# Install necessary dependencies
echo "::group::Installing dependencies"
sudo apt-get install -y protobuf-compiler golang-goprotobuf-dev
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
echo "Installed dependencies"
echo "::endgroup::"

# Split the services string into an array (assuming it's comma-separated)
IFS=',' read -r -a SERVICE_ARRAY <<< "$SERVICES"

for SERVICE_NAME in "${SERVICE_ARRAY[@]}"; do
    # Compile the .proto files for each service
    echo "::group::Compiling .proto files for ${SERVICE_NAME}"

    if [ ! -d "golang" ]; then
        mkdir golang
    fi

    protoc --go_out=./golang --go_opt=paths=source_relative \
        --go-grpc_out=./golang --go-grpc_opt=paths=source_relative \
        ./${SERVICE_NAME}/*.proto
    echo "Compiled proto files for service: ${SERVICE_NAME}"
    echo "::endgroup::"

    # Ensure the service directory exists
    echo "::group::Checking service directory for ${SERVICE_NAME}"
    if [ ! -d "golang/${SERVICE_NAME}" ]; then
        echo "::error::Directory golang/${SERVICE_NAME} does not exist"
        exit 1
    fi
    echo "Service directory exists: golang/${SERVICE_NAME}"
    echo "::endgroup::"

    # Initialize and tidy the Go module for each service
    echo "::group::Go mod init and tidy for ${SERVICE_NAME}"
    cd golang/${SERVICE_NAME}
    go mod init github.com/andrei-kozel/owly-proto/golang/${SERVICE_NAME} || true
    go mod tidy
    echo "Go module initialized and tidied for ${SERVICE_NAME}"
    cd ../..
    echo "::endgroup::"

    # Commit changes
    echo "::group::Committing changes"
    git config --global user.email "kozel.andrei.94@gmail.com"
    git config --global user.name "Andrei Kozel"
    git add .
    git commit -am "proto update" || true
    echo "Committed changes"
    echo "::endgroup::"

    # Create a single tag for all services
    echo "::group::Creating single tag"
    git tag -fa golang/${SERVICE_NAME}/${RELEASE_VERSION} -m "Release ${RELEASE_VERSION}"
    git push origin --tags
    echo "Created and pushed tag golang/${SERVICE_NAME}/${RELEASE_VERSION}"
    echo "::endgroup::"
done


