# Getjv PHP-WEBSERVER Image

This is my personal PHP webserver Image. Here is all most cool and essential php tool I use in regular projects

## First use

1. Checkout the template project: `git clone https://github.com/getJv/php-webserver.git`
2. Go to project root folder: `cd php-webserver`
3. Build the Image: `docker build -t getjv/php-fpm --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) .`
4. Turn the containers on: `docker compose up -d`
5. Access the `http://localhost`  
6. By default the webserver bring two default projects configurated. BUT you should edit you vhost file to add the alias to `http://project1.local` or `http://project2.local`
   ```bash
   # [... lines omitted]
   # Example of /etc/hosts or vhost file on Windows system.
   127.0.0.1       localhost
   127.0.0.1       project1.local
   127.0.0.1       project2.local
   # [... lines omitted]
   ```

## Multiple hosts webserver

This Ngnix Webserver were build to suport multiples project.
To add a new project you only need to add a new config file under `/config/nginx` mapping the root location folder. And you project foldr should be under `/workspace`.


## Set X-Debug int VS Code

1. First, do all steps from `First use Section`
2. The original Dockerfile image already have all xdebug config out of the box.
3. Felix xdebug extention: `https://marketplace.visualstudio.com/items?itemName=felixfbecker.php-debug`
4. Install the xdebug extension in your browse: `https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc`
5. Now in the VSCODE Replace the original launch.json with the following:
   ```json
   {
     "version": "0.2.0",
     "configurations": [
       {
         "name": "Listen for XDebug",
         "type": "php",
         "request": "launch",
         "hostname": "0.0.0.0",
         "port": 9003,
         "log": true,
         "pathMappings": {
           "/var/www/html": "${workspaceFolder}/workspace"
         },
         "ignore": ["**/vendor/**/*.php"],
         "xdebugSettings": {
           "max_children": 10000,
           "max_data": 10000,
           "show_hidden": 1
         }
       }
     ]
   }
   ```
6. Add your break points and be happy!

## Laravel use or removal

Laravel is my prefered PHP framework, so I already have it build in in the image.
If you wish to remove it just comment or remove the following from Docker build image before build it:

```yml
#Laravel Installation
USER dev
RUN composer global require laravel/installer && \
echo "alias laravel='~/.composer/vendor/bin/laravel'" >> ~/.bashrc && \
alias laravel='~/.composer/vendor/bin/laravel'
USER root
```

## Usage for New Laravel Projects

1. to start a fresh laravel project make sure you have the containers turned on
2. Go inside the php container as dev user: `docker exec -it --user dev php sh`
3. Remove the default public folder: `rm -Rf public`
4. Do a laravel fresh installation: `laravel new fresh_project`
5. Bring all laravel file to html folder: `mv fresh_project/* fresh_project/.[!.]* .`
6. Remove the fresh_project folder: `rm -Rf fresh_project`

## Usage for New Laravel Projects

1. to add a laravel project make sure you have the containers turned on
2. Remove the default public folder: `docker exec --user dev php rm -Rf public`
3. Clone your project at `workspace folder`
4. Move your project files from you project folder to the `workspace` folder: `mv <YOUR_FOLDER_NAME>/* <YOUR_FOLDER_NAME>/.[!.]* .`
5. Remove the fresh_project folder: `rm -Rf <YOUR_FOLDER_NAME>`
6. Code something amazing.

## Useful commands

- Access as dev user: `docker exec -it --user dev php sh `
- Help to find the host/docker ip for xdebug: `netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}'`
- Xdebug.log: `docker exec php tail -f /tmp/xdebug.log`
- Bundle shortcut for Dockerfile tests: `docker compose down && docker rmi getjv/php-fpm && docker build -t getjv/php-fpm --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) . && docker compose up -d`

## License

The source code for the site is licensed under the MIT license, which you can find in
the MIT-LICENSE.txt file.

All graphical assets are licensed under the
[Creative Commons Attribution 3.0 Unported License](https://creativecommons.org/licenses/by/3.0/).
