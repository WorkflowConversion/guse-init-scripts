#!/bin/bash
. ~/.guserc

DEFAULT_IFACE=`/sbin/ip route | awk '/default/ { print $5 }'`
#IP_ADDR=`/sbin/ip addr show $DEFAULT_IFACE | awk '/inet /{split($2,a,"/");print a[1]}'`
IP_ADDR="knime2guse.fritz.box"
OLD_IP=`cat ~/.prev_init_IP 2> /dev/null`
TOMCAT_ADMIN_PASSWORD="admin"

#if [ "x$OLD_IP" != "x$IP_ADDR" ]; then
#    mysql -u guse --password="guse" guse -e "drop table OPENJPA_SEQUENCE_TABLE, OptionBean, service, servicecomdef, serviceresource, serviceproperties, services_user, servicetype, serviceuser;"
#fi
sed -i -e "s|<property name=\"portal.url\" value=\"http://.*:8080/wspgrade\" />|<property name=\"portal.url\" value=\"http://$IP_ADDR:8080/wspgrade\" />|" "$CATALINA_HOME"/webapps/information/WEB-INF/config/service.xml

# start in debug mode
#"$CATALINA_HOME"/bin/startup.sh
"$CATALINA_HOME"/bin/catalina.sh jpda start
echo "Tomcat is initializing, you can check the log to monitor its progress." 
echo "Please wait, Tomcat initialization takes a few minutes."
while [ 1 ]; do
    ( tail "$CATALINA_HOME"/logs/catalina.out | grep -q "INFO: Server startup in " ) && break
    sleep 5
done

echo "Initializing gUSE services. Please be patient, this will take an extra couple of minutes."
wget -o /dev/null -O /dev/null --http-user=admin --http-password=$TOMCAT_ADMIN_PASSWORD http://$IP_ADDR:8080/information/wizzard?pdriver=org.gjt.mm.mysql.Driver\&pjdbc=jdbc:mysql://localhost:3306/guse\&puser=guse\&ppass=guse
sleep 10
wget -o /dev/null -O /dev/null --http-user=admin --http-password=$TOMCAT_ADMIN_PASSWORD http://$IP_ADDR:8080/information/wizzard?phost=http://$IP_ADDR:8080
sleep 10
wget -o /dev/null -O /dev/null --http-user=admin --http-password=$TOMCAT_ADMIN_PASSWORD http://$IP_ADDR:8080/information/wizzard?pfine=ok
sleep 10
if [ "x$OLD_IP" != "x$IP_ADDR" ]; then
    wget -o /dev/null -O /dev/null --http-user=admin --http-password=$TOMCAT_ADMIN_PASSWORD http://$IP_ADDR:8080/information/wizzard?pwspgrade=http://$IP_ADDR:8080/wspgrade\&pwfs=http://$IP_ADDR:8080/wfs\&presource=http://$IP_ADDR:8080/dci_bridge_service\&pstatvisualizer=http://$IP_ADDR:8080/statvisualizer\&pstorage=http://$IP_ADDR:8080/storage\&pwfi=http://$IP_ADDR:8080/wfi
    sleep 10
fi
wget -o /dev/null -O /dev/null --http-user=admin --http-password=$TOMCAT_ADMIN_PASSWORD http://$IP_ADDR:8080/information/init?service.url=http://$IP_ADDR:8080/information\&resource.id=/services/urn:infoservice\&guse.system.database.driver=com.mysql.jdbc.Driver\&guse.system.database.url=jdbc:mysql://localhost:3306/guse\&guse.system.database.user=guse\&guse.system.database.password=guse
wget -o /dev/null -O /dev/null http://$IP_ADDR:8080/stataggregator

echo "$IP_ADDR" > ~/.prev_init_IP

exit 0
