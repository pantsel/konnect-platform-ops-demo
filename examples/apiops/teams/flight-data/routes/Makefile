check-dependencies:
	@$(call check-dependency,go)

test: check-dependencies
	go test -v ./...

build: check-dependencies
	go build -o ${file}

run: check-dependencies build
ifeq ($(nohup),true)
	nohup ./${file} ${port} > /tmp/${file}.log 2>&1 &
else
	./${file} ${port}
endif
