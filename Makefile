.PHONY: generate lint clean

# Generate Go code from proto files
generate:
	buf generate && \
    cd gen/go && \
    if [ ! -f go.mod ]; then \
        go mod init github.com/andrei-kozel/owly-proto/go; \
    fi && \
    go mod tidy

# Lint proto files
lint:
	buf lint

# Clean generated files
clean:
	rm -rf gen/

# Install required tools
install-tools:
	go install github.com/bufbuild/buf/cmd/buf@latest
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest