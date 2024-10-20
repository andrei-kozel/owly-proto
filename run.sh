set -e # Exit on any error

SERVICE_NAME=$1
RELEASE_VERSION=$2

# Debug: Initial parameters
echo "::group::Debug: Parameters"
echo "SERVICE_NAME: $SERVICE_NAME"
echo "RELEASE_VERSION: $RELEASE_VERSION"
echo "::endgroup::"

# Install necessary dependencies
echo "::group::Installing dependencies"
sudo apt-get install -y protobuf-compiler golang-goprotobuf-dev
echo "Installed protobuf-compiler and golang-goprotobuf-dev"
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
echo "Installed protoc-gen-go and protoc-gen-go-grpc"
echo "::endgroup::"

# Compile the .proto files
echo "::group::Compiling .proto files"

# Check if folder exists
# If not, create it
if [ ! -d "golang" ]; then
    mkdir golang
fi

protoc --go_out=./golang --go_opt=paths=source_relative \
    --go-grpc_out=./golang --go-grpc_opt=paths=source_relative \
    ./${SERVICE_NAME}/*.proto
echo "Compiled proto files for service: ${SERVICE_NAME}"
echo "::endgroup::"

# Ensure the directory exists
echo "::group::Checking service directory"
if [ ! -d "golang/${SERVICE_NAME}" ]; then
    echo "::error::Directory golang/${SERVICE_NAME} does not exist"
    exit 1
fi
echo "Service directory exists: golang/${SERVICE_NAME}"
echo "::endgroup::"

# Initialize the Go module inside the service directory
echo "::group::Go mod init and tidy"
cd golang
echo "Current directory: $(pwd)"
ls -la
go mod init github.com/andrei-kozel/owly-proto/golang|| true
go mod tidy
echo "Go module initialized and tidied for service: ${SERVICE_NAME}"
echo "::endgroup::"

# Commit and push the changes
echo "::group::Committing and tagging"
echo "Current directory: $(pwd)"
cd ..
echo "Current directory: $(pwd)"
git config --global user.email "kozel.andrei.94@gmail.com"
git config --global user.name "Andrei Kozel"
git add .
git commit -am "proto update" || true
git tag -fa golang/${SERVICE_NAME}/${RELEASE_VERSION} -m "golang/${SERVICE_NAME}/${RELEASE_VERSION}"
git push origin refs/tags/golang/${SERVICE_NAME}/${RELEASE_VERSION}
echo "Committed and pushed tag ${RELEASE_VERSION}"
echo "::endgroup::"
