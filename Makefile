.PHONY: generate lint clean

# Generate Go code from proto files
generate:
	mkdir -p gen/go
	find proto -name '*.proto' | xargs protoc \
		--proto_path=proto \
		--go_out=gen/go --go_opt=paths=source_relative \
		--go-grpc_out=gen/go --go-grpc_opt=paths=source_relative

# Lint proto files
lint:
	buf lint

# Clean generated files
clean:
	rm -rf gen/

# Install required tools
install-tools:
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest