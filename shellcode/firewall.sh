echo Please input service,followed by port number
read service
read port
firewall-cmd --add-service=$service --permanent && firewall-cmd --add-port=$port/tcp --permanent && firewall-cmd --reload
