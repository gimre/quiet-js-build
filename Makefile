all: image

image:
	docker build --rm -t quiet-js-build .

publish:
	docker tag quiet-js-build imregabriel/quiet-js-build:latest
	docker push imregabriel/quiet-js-build:latest

test:
	docker run -v ${PWD}/dist:/dist quiet-js-build

.PHONY: image publish test
