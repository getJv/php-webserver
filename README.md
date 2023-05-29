# Getjv PHP-WEBSERVER Image for MacOs users

This is my personal PHP webserver Image. Here is all most cool and essential php tool I use in regular projects

## First use

1. Checkout the template project: `git clone https://github.com/getJv/php-webserver.git`
2. Go to project root folder: `cd php-webserver`
3. chose the branch to mac-users `git checkout mac-system` 
3. Build the Image: `docker build -t getjv/php-fpm --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) ..`
4. Turn the containers on: `docker compose up -d`
5. Access the `http://localhost`

## Adding new projects to webserver

1. Create or add your project into workspace folder `aka: workspace/myNewProject2/`
2. inside `/config/nginx` create a new config file with you project name. `aka config/myNewProject2.conf`
   (tip: copy and paste from the default example)
3. now edit the content of your new config file to map your needs like the `server_name` and the `root` folder of your project
   ```bash
   # config/myNewProject2.conf
   
   #others configs[...]
   server_name my-new-project-2.test
   
   root var/www/html/myNewProject2/public
   #others configs[...]
   ```
   > info: Projects like Laravel or Symfony have their root (documentRoot) in their public folder

## Set a custom local DNS for each project

1. For each `.conf` file into your `config/nginx/` will exist a server_name entry and each of those should have a match into your system `/etc/hosts` file
2. So every time you add a new project to your server ensure you update that file, run:
   `sudo nano /etc/hosts` add your new entry (aka. 127.0.0.1 my-new-project-2.test) and save.
   This is exemple how it should like:
   ```bash
   # /etc/hosts
   ```

## Set X-Debug int VS Code

1. First, do all steps from `First use Section`
2. The original Dockerfile image already have all xdebug config out of the box.
3. (vscode users only) Felix xdebug extention: `https://marketplace.visualstudio.com/items?itemName=felixfbecker.php-debug`
4. Install the xdebug extension in your browse: `https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc`
5. (vscode users only) Now in the VSCODE Replace the original launch.json with the following:
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

## Useful commands
- Access as dev user: `docker exec -it --user dev php sh `
- Help to find the host/docker ip for xdebug: `netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}'`
- Xdebug.log: `docker exec php tail -f /tmp/xdebug.log`
- Bundle shortcut for Dockerfile tests: `docker compose down && docker rmi getjv/php-fpm && docker build -t getjv/php-fpm --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) . && docker compose up -d`

# Source links:
 - https://medium.com/4yousee/infraestrutura-em-ambiente-de-desenvolvimento-com-docker-parte-1-eb28507d5eca
 - Help to mimic current user into container for mac: https://stackoverflow.com/questions/41807026/cant-add-a-user-with-a-high-uid-in-docker-alpine and  http://stackoverflow.com/a/1094354/535203
 - install gnu-libiconv and set LD_PRELOAD env to make iconv work fully on Alpine image. https://github.com/docker-library/php/issues/240#issuecomment-763112749
 - xdebug: https://stackoverflow.com/questions/31583646/cannot-find-autoconf-please-check-your-autoconf-installation-xampp-in-centos

## License

The source code for the site is licensed under the MIT license, which you can find in
the MIT-LICENSE.txt file.

All graphical assets are licensed under the
[Creative Commons Attribution 3.0 Unported License](https://creativecommons.org/licenses/by/3.0/).