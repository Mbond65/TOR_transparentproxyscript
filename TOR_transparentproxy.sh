#!/bin/sh

#apt-get update
#apt-get upgrade -y

echo "Does this system have a static IP [Y/N]?"
read STATICIPSET;

if [ "$STATICIPSET" != "Y" ] && [ "$STATICIPSET" != "N" ] ; then
        echo "You didn't enter Y or N"
        exit
fi

if [ "$STATICIPSET" =  "N" ]; then
        echo "This system must have STATIC IP settings, please configure a static IP and try again"
        exit
fi

#apt-get install tor -y

echo "TOR has been installed"
echo "Please enter the IP address for this host"

read STATICIP;

#echo Log notice file /var/log/tor/notices.log >> /etc/tor/torrc
#echo VirtualAddrNetwork 10.192.0.0/10 >> /etc/tor/torrc
#echo AutomapHostsSuffixes .onion,.exit >> /etc/tor/torrc
#echo AutomapHostsOnResolve 1 >> /etc/tor/torrc
#echo TransPort 9040 >> /etc/tor/torrc
#echo TransListenAddress $STATICIP >> /etc/tor/torrc
#echo DNSPort 53 >> /etc/tor/torrc
#echo DNSListenAddress $STATICIP >> /etc/tor/torrc

/etc/init.d/tor start
update-rc.d tor enable

iptables -F
iptables -t nat -F

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 22 -j REDIRECT --to-ports 22
iptables -t nat -A PREROUTING -i eth0 -p udp --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -A PREROUTING -i eth0 -p tcp --syn -j REDIRECT --to-ports 9040

sh -c "iptables-save > /etc/iptables.rules"
echo "#!/bin/bash" >> /etc/network/if-pre-up.d/iptables
echo "/sbin/iptables-restore < /etc/iptables.rules" >>  /etc/network/if-pre-up.d/iptables

chmod +x /etc/network/if-pre-up.d/iptables
