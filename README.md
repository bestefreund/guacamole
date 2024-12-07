# Guacamole

This is a Guacamole Docker Deployment containing Guacamole 1.4.0 on Tomcat 9 with SSL, LDAP-SSL & MySQL 8

```
# Fill in the values to the Variables in the .env-file

# Get this repo
git clone https://github.com/bestefreund/guacamole.git
cd guacamole

# Get Guacamole-Client
git clone --branch 1.5.5 https://github.com/apache/guacamole-client.git

# Configure Guacamole-Client
cp ./server.xml ./guacamolessl-entrypoint.sh ./guacamole-client/
cd ./guacamole-client
sed -i 's/ARG TOMCAT_VERSION=8.5/ARG TOMCAT_VERSION=9/g' Dockerfile
sed -i -e '/EXPOSE 8080/{r ../helpers/dockerfile_content' -e 'd}' Dockerfile
sed -i '/USER guacamole/d' Dockerfile
sed -i 's/<ignoreLicenseErrors>false<\/ignoreLicenseErrors>/<ignoreLicenseErrors>true<\/ignoreLicenseErrors>/g' pom.xml
sed -i 's/exec catalina.sh run/exec /usr/local/tomcat/catalina.sh run/g' ./guacamole-docker/bin/start.sh

# Build custom guacamole image
docker build -t guacamole .

cd ..

# Set sensitive data
LDAP_SEARCH_BIND_PASSWORD=""
MYSQL_PASSWORD="$(echo $RANDOM | md5sum | head -c 20; echo;)"
GUAC_ADM_PASSWORD="$(echo $RANDOM | md5sum | head -c 20; echo;)"

# Adjust the examples or create your own scripts
sed -i "s/GUAC_ADM_PASSWORD/${GUAC_ADM_PASSWORD}/g" ./mysql/2_users_groups.sql

docker-compose up -d
```
