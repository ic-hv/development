#!/bin/sh

#git -C platform reset --hard
#git -C platform pull --rebase

#git -C . pull --rebase

### Ersatz für "./psh.phar install" ###

rm composer.lock
rm vendor/shopware/platform

./psh.phar init-composer # siehe: dev-ops/common/actions/init-composer.sh
./psh.phar init-shopware # siehe: dev-ops/common/actions/init-shopware.sh

# Aktuelle Node Version verwenden (via Node Version Manager -- siehe: https://github.com/nvm-sh/nvm)
NVM_PATH=$(command -v nvm.sh)
if [ "${NVM_PATH}" != "" ] ; then
  . ${NVM_PATH}
fi

# Sämtliche node_modules Caches löschen ...
find . -type d -iname node_modules -exec rm -rf '{}' ';'

./psh.phar administration:init

./psh.phar storefront:install-dependencies

if [ "$1" = "--prod" ] || [ "$(grep "^APP_ENV" .env | sed -e "s/APP_ENV=//")" = "prod" ] ; then
	./psh.phar storefront:build
else
	./psh.phar storefront:dev
fi

# bin/console theme:change IcorpBaseTheme --all