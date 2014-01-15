#!/bin/bash

echo "Creating database"
mysql -e 'create database dkan_dataset_test'
echo "Downloading Drupal"
drush --yes core-quick-drupal --profile=testing --no-server --db-url=mysql://root:@localhost/dkan_dataset_test --enable=simpletest dkan_dataset_test

echo "Downloading dkan_dataset"
git clone --branch 7.x-1.x http://git.drupal.org/project/dkan_dataset.git

# copy and enable dkan_dataset in build site
cp -r dkan_dataset dkan_dataset_test/drupal/sites/all/modules/dkan_dataset
cd dkan_dataset_test/drupal
"Downloading modules"
drush make --no-core --yes sites/all/modules/dkan_dataset/dkan_dataset.make
echo "Enabling DKAN Dataset"
drush --yes pm-enable dkan_dataset

# start a web server on port 8080, run in the background; wait for initialization
drush --server=cgi --quiet --yes --root=$PWD runserver :8888 > /dev/null 2>&1 &
sleep 4s

drush test-run 'DKAN Dataset' --uri=http://127.0.0.1:8888
