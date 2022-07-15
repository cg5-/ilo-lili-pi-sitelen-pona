#!/usr/bin/env sh

# abort on errors
set -e

# build
npm run build

# navigate into the build output directory
cd dist

git init
git checkout gh-pages
git add -A
git commit -m 'deploy'

git push -f https://github.com/cg5-/ilo-lili-pi-sitelen-pona gh-pages

cd -