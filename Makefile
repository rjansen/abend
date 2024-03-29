include Makefile.vars

.PHONY: ci
ci: vet coverage.text bench

.PHONY: clean
clean:
	@echo "$(REPO) clean"
	-rm $(NAME)*coverage* > /dev/null 2>&1
	-rm *.test > /dev/null 2>&1
	-rm *.pprof > /dev/null 2>&1

.PHONY: clearcache
clearcache:
	@echo "$(REPO) clearcache"
	-rm -Rf $(BASE_DIR)/on > /dev/null 2>&1
	-rm -Rf $(BASE_DIR)/vendor > /dev/null 2>&1

.PHONY: vendor
vendor:
	@echo "$(REPO) vendor"
	go mod vendor
	go mod verify

.PHONY: fmt
fmt:
	@echo "$(REPO) fmt"
	go fmt $(PKGS)

.PHONY: vet
vet:
	@echo "$(REPO) vet"
	go vet $(PKGS)

.PHONY: debug
debug:
	@echo "$(REPO) debug"
	dlv debug $(REPO)

.PHONY: debugtest
debugtest:
	@echo "$(REPO) debugtest"
	dlv test --build-flags='$(TEST_PKGS)' -- -test.run $(TESTS)

.PHONY: test
test:
	@echo "$(REPO) test"
	gotestsum -f short-verbose -- -v -race -run $(TESTS) $(TEST_PKGS)

.PHONY: itest
itest:
	@echo "$(REPO) itest"
	gotestsum -f short-verbose -- -tags=integration -v -race -run $(TESTS) $(TEST_PKGS)

.PHONY: bench
bench:
	@echo "$(REPO) bench"
	gotestsum -f short-verbose -- -bench=. -run="^$$" -benchmem $(TEST_PKGS)

.PHONY: coverage
coverage:
	@echo "$(REPO) coverage"
	@touch $(COVERAGE_FILE)
	gotestsum -f short-verbose -- -tags=integration -v -run $(TESTS) \
			  -covermode=atomic -coverpkg=./... -coverprofile=$(COVERAGE_FILE) $(TEST_PKGS)

.PHONY: coverage.text
coverage.text: coverage
	@echo "$(REPO) coverage.text"
	go tool cover -func=$(COVERAGE_FILE)

.PHONY: coverage.html
coverage.html: coverage
	@echo "$(REPO) coverage.html"
	go tool cover -html=$(COVERAGE_FILE) -o $(COVERAGE_HTML)
	@open $(COVERAGE_HTML) || google-chrome $(COVERAGE_HTML) || google-chrome-stable $(COVERAGE_HTML)

.PHONY: coverage.push
coverage.push:
	@echo "$(REPO) coverage.push"
	@#download codecov script and push report with oneline cmd
	@#curl -sL https://codecov.io/bash | bash -s - -f $(COVERAGE_FILE)$(if $(CODECOV_TOKEN), -t $(CODECOV_TOKEN),)
	@codecov -f $(COVERAGE_FILE)$(if $(CODECOV_TOKEN), -t $(CODECOV_TOKEN),)

.PHONY: docker
docker.build:
	@echo "$(REPO)@$(BUILD) docker"
	docker build --build-arg APP=$(NAME) --build-arg UID=$(shell id -u) --build-arg GID=$(shell id -g) \
		         -t $(DOCKER_NAME) -t $(DOCKER_NAME):$(VERSION) .

.PHONY: docker.bash
docker.bash:
	@echo "$(REPO)@$(BUILD) docker.bash"
	docker run --rm --name $(NAME)-bash --entrypoint bash -it -u $(shell id -u):$(shell id -g) \
			   -v `pwd`:/app/$(NAME) $(DOCKER_NAME)

docker.%:
	@echo "$(REPO)@$(BUILD) docker.$*"
	@docker run --rm --name $(NAME)-run -u $(shell id -u):$(shell id -g) \
    		    -v `pwd`:/app/$(NAME) $(DOCKER_NAME) $*
