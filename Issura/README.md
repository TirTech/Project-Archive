# Issura - Issue Management System
_Authors: Brandon Franklin, Shawn Norrie_

## Running Tests:
cUrl tests can be found in api/cUrl. All tests can be run at once using all.sh, or individual tests may be run by first running `source ./setup.sh` then executing the appropriate script. Please note that the scripts were written in BASH. The test will clean up created resources and as such some requests (specifically to user deletes) will 403 due to the user not owning the new resource.

## Setting Up the Database
To set up the database, run `python3 utils/generate_db.py`. This will compile the database files into a single master file in the sql folder called `db.sql`. Running this will drop existing resources and recreate procedures and tables.

## NOTE ##
cert.pem, key.pem, and settings.py are not included in this repository for security reasons. Certs will need to be generated and settings configured in order to launch the app.