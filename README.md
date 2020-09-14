# README


## For VSCode Remote Development Extension

1. Open in vscode container
2. Go to [Setup Section](#setup-and-run)

  ** If you are try to push to github from within the container you might need to comment out the line for 
  `UseKeychain yes` in /root/.ssh/config


## Other Environment


1. Make sure you have ruby 2.6.6 installed.  
   Example using asdf:  
     `asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git`  
     `asdf install ruby 2.6.6`   
     `asdf local ruby 2.6.6`  
    or rvm with:
    `rvm install "ruby-2.6.6"`


2.  Install yarn
    Ex. `brew install yarn`

3. Install the latest Docker Compose
    https://docs.docker.com/compose/install/


## SETUP and RUN


1. run `make setup`  
    - It installs node modules    
    - Builds both images for the database and server
    - Creates the database and runs the migration

    The database is first initialized with default user/pass of postgres/postgres or taken from env:
    PG_USERNAME and PG_PASSWORD

    The database data directory is created in a docker volume

2. run `make server`  
   Visit http://localhost:8080 in your browser




## Test and Linting

Run test with `make test`  
For Code Linting run `yarn lint`  


## Deployment

- Uses Github Actions
- Builds Docker Image
- Runs Tests
- Runs Linter

You can add "DNB" to your commit message to keep the github action from running (DNB = Do Not Build)



## CLEANUP

To remove the docker containers for the db and web server you can run:  
`make cleanup`  
If you want to remove the database data volume as well you can run:  
`make cleanup volumes`

