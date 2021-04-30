#!/bin/bash

# Fail fast in case of errors:
set -e

clear
echo ' '
echo "=== Copying current DB structure files into *all* framework Projects ==="
echo ' '
echo "This will keep in synch all the other Project folders with the current DB structure"
echo "of the Main Application. It should be run from Main root folder."
echo "Make sure migrations can be run flawlessly on localhost before running this."
echo ' '
echo "--> This will also DUMP & COPY the test DB into goggles_db (when found) <--"
echo ' '
echo "(Any other DB dump stored in *any* other project will be ignored by commits"
echo " and should only be used as local backup.)"
echo ' '
echo "Press ENTER when ready, or CTRL-C to abort."
read

echo "Making sure migration are run in all environments (this will also update the schema file)..."
RAILS_ENV=test rails db:migrate
rails db:migrate
RAILS_ENV=production rails db:migrate

echo "Saving structure in SQL format..."
rails db:structure:dump

# goggles_db
if [ -d ../goggles_db/db ];
then
  echo "Updating goggles_db..."
  cp ./db/schema.rb ../goggles_db/spec/dummy/db/schema.rb
  cp ./db/structure.sql ../goggles_db/spec/dummy/db/structure.sql
  echo "DB dump..."
  RAILS_ENV=test rails db:dump
  echo "Moving dump to goggles_db..."
  mv ./db/dump/test.sql.bz2 ../goggles_db/spec/dummy/db/dump/test.sql.bz2
  echo "goggles_db updated: changes need a commit."
else
  echo "goggles_db not found, skipping."
fi

# goggles_api
if [ -d ../goggles_api/db ];
then
  echo "Updating goggles_api..."
  cp ./db/schema.rb ../goggles_api/db/schema.rb
  cp ./db/structure.sql ../goggles_api/db/structure.sql
else
  echo "goggles_api not found, skipping."
fi

# goggles_chrono
if [ -d ../goggles_chrono/db ];
then
  echo "Updating goggles_chrono..."
  cp ./db/schema.rb ../goggles_chrono/db/schema.rb
  cp ./db/structure.sql ../goggles_chrono/db/structure.sql
else
  echo "goggles_chrono not found, skipping."
fi

# goggles_admin2
if [ -d ../goggles_admin2/db ];
then
  echo "Updating goggles_admin2..."
  cp ./db/schema.rb ../goggles_admin2/db/schema.rb
  cp ./db/structure.sql ../goggles_admin2/db/structure.sql
else
  echo "goggles_admin2 not found, skipping."
fi

echo ' '
echo "All done!"
