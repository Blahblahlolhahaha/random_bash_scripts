echo Please input service,followed by port number
read service
read port
firewall-cmd --remove-service=$service --permanent && firewall-cmd --remove-port=$port/tcp --permanent && firewall-cmd --reload
