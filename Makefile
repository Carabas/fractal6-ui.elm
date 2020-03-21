default: build_root

build_root:
	# webkit !
	@cp -v assets/js/*.js public/
	npm run css_build

setup-css:
	npm install node-sass --save-dev
	npm install bulma --save-dev

generate:
	npm run graphql_build

