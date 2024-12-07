#!/bin/bash

random1="$(echo $RANDOM | md5sum | head -c 20; echo;)"
random2="$(echo $RANDOM | md5sum | head -c 20; echo;)"


JAVA_HOME_SLASH="$(echo "${JAVA_HOME}" | sed 's/\//\\\//g')"
random1_SLASH="$(echo "${random1}" | sed 's/\//\\\//g')"

security_path="${JAVA_HOME}/jre/lib/security"

if [ -f "${security_path}/ssl.keystore" ]; then
  echo "Found SSL-keystore. Continuing..."
else
  echo "Setting config..."
  sed -i "s/HOST_NAME/${HOST_NAME}/g" "${CATALINA_HOME}"/conf/server.xml
  sed -i "s/JAVA_HOME/${JAVA_HOME_SLASH}/g" "${CATALINA_HOME}"/conf/server.xml
  sed -i "s/JAVA_CERT_PW/${random1_SLASH}/g" "${CATALINA_HOME}"/conf/server.xml

  echo "Creating keystore..."
  keytool -genkey -keyalg RSA \
    -keystore "${security_path}/ssl.keystore" \
    -storepass "${random1}" \
    -dname "${LDAP_CERT_DN}" \
    -storetype pkcs12 > /dev/null
fi

if [ -f "${security_path}/ldap.cert" ]; then
  echo "Found LDAP-Cert. Continuing..."
else
  echo "Downloading LDAP-cert..."
  echo "" | openssl s_client \
    -starttls ldap \
    -connect "${LDAP_HOSTNAME}:${LDAP_PORT}" \
    -showcerts 2> /dev/null \
    | sed -n "/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p" \
    > "${security_path}/ldap.cert"

  echo "Importing LDAP-cert..."
  keytool -storepasswd \
    -new "${random2}" \
    -keystore "${security_path}/cacerts" \
    -storepass "${random1}"

  echo "yes" | keytool -importcert \
    -alias ldap \
    -file  "${security_path}/ldap.cert" \
    -trustcacerts \
    -keystore "${security_path}/cacerts" \
    -storetype JKS \
    -storepass "${random2}" > /dev/null
fi

catalina_dest_path="/usr/local/tomcat/bin/catalina.sh"
catalina_run_path="/usr/local/tomcat/catalina.sh"
if [ ! -f "${catalina_run_path}" ]; then
  ln -s \
    "${catalina_dest_path}" \
    "${catalina_run_path}"
    
fi

su -s /bin/bash -c "$@" guacamole
