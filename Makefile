.PHONY: generate lint clean

# Generate Go code from proto files
generate:
	buf generate

# Lint proto files
lint:
	buf lint

# Clean generated files
clean:
	rm -rf generated/

# Install required tools
install-tools:
	go install github.com/bufbuild/buf/cmd/buf@latest
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest