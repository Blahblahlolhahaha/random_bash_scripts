while [ true ];
do 
    clear # Clear the screen after each operation
    # main menu
    echo what do you want to do today? 1\)Configure Apache 2\)Configure logging 3\)User control 4\)Forward Zone 5\)Reverse Zone 6\)Firewall add 7\) Firewall Remove 8\)Exit
    read choice
    if [ $choice = "1" ];
    then
        echo 1\)edit config 2\)create new config 3\)create new file 4\)htpasswd 5\)Exit
		read apache
		if [ $apache = "1" ]; then 
			vim /etc/httpd/conf/httpd.conf
		elif [ $apache = "2" ];
		then
			echo filename:
			read new
			vim /etc/httpd/conf.d/$new.conf
		elif [ $apache = "3" ];
		then
			echo filename:
			read new
			mkdir /var/www/$new
			vim /var/www/$new/$new.html
		elif [ $apache = "4" ];
		then 
			echo username:
			read username
			echo filename:
			read filename
			echo 1\)bcrypt 2\)md5
			read cipher
			echo first time 1\)Yes 2\)No?
			read first
			if [ $cipher = "1 " ];
			then
				if [ $first = "1" ];
				then
					htpasswd -c -B /etc/httpd/conf/$filename $username	
				else
					htpasswd -B /etc/httpd/conf/$filename $username
				fi
			elif [ $cipher = "2" ];
			then
				if [ $first = "1" ];
				then
					htpasswd -c -m /etc/httpd/conf/$filename $username
				else
					htpasswd -m /etc/httpd/conf/$filename $username
				fi
			fi
        elif [ $apache = "5" ];
        then
            continue
        systemctl restart httpd
		fi
    elif [ $choice = "2" ];
    then
        echo 1\)Edit logging 2\)Resolve Apache 3\)Swatch 4\)Exit
        read log
        if [ $log = "1" ];
        then
            vim /etc/rsyslog.conf
            systemctl restart rsyslog
        elif [ $log = "2" ];
        then
            echo Insert ABSOLUTE PATH of file here:
            read filename
            echo Insert ABSOLUTE PATH of dst file here:
            read dst
            logresolve < $filename > dst
        elif [ $log = "3" ];
        then
            echo Filename:
            read filename
            vim /etc/swatch/$filename
            swatch -c /etc/swatch/$filename -t /var/log/secure

        fi
    elif [ $choice = "3" ];
    then
        echo 1\)Set maxlogins 2\)Set process limit 3\)Login 4\)System Authentication 5\)Time 6\) Exit
        read boom
        if [ $boom = "1" ];
        then
            echo Username:
            read user
            echo 1.hard 2.soft:
            read hardness
            echo number of logins:
            read num
            if [ $hardness = "1"];
            then
                echo $user  hard    maxlogins   $num >> /etc/security/limits.conf
            elif [ $hardness = "2" ];
            then
                echo $user  soft   maxlogins   $num >> /etc/security/limits.conf
            else
                echo Please enter a valid option!
            fi
        elif [ $boom = "2" ];
        then
            echo Username:
            read user
            echo 1.hard 2.soft:
            read hardness
            echo number of process:
            read num
            if [ $hardness = "1" ];
            then
                echo $user  hard    nproc   $num >> /etc/security/limits.conf
            elif [ $hardness = "2" ];
            then
                echo $user  soft   nproc   $num >> /etc/security/limits.conf
            else
                echo Please enter a valid option!
            fi
        elif [ $boom = "3" ];
        then
            vim /etc/pam.d/login
        elif [ $boom = "4" ];
        then
            vim /etc/pam.d/system-auth
        elif [ $boom = "5" ];
        then
            vim /etc/security/time.conf
        fi
    elif [ $choice = "4" ];
    then
        echo Enter zone name:
        read zone
        echo -e "Please copy the following:
zone \"$zone\" IN {\n
    type master;\n
    file \"$zone.zone\";\n
};\n"
        echo press enter to continue:
        read accept
        vim /etc/named.conf
        echo "Copy the following again. Press enter once you are done (CHANGE THE VALUE LATER HOR!)"
        echo -e "\$TTL 86400
$zone.       IN SOA server root (
                    42   ; serial
                    3H   ; refresh
                    15M  ; retry
                    1W   ; expiry
                    1D ) ; minimum
$zone.     	IN   NS server

server			IN A 172.16.108.88
client			IN A 172.16.108.128
testpc          	IN A 172.16.108.99"
        read accept
        vim /var/named/$zone.zone
    elif [ $choice = "5" ];
    then
        echo Enter zone name: 
        read zone
        echo Enter first three octets of your ip: 
        read ip
        echo Enter reversed three octets of your ip: 
        read reverse
        echo -e "Please copy the following:
zone \"$reverse.in-addr.arpa\" IN {
	type master;
        file \"$ip.zone\";
};"
        echo press enter to continue:
        read accept
        vim /etc/named.conf
        echo "Copy the following again. Press enter once you are done (CHANGE THE VALUE LATER HOR!)"
        echo -e "\$TTL 86400\n
@       IN SOA server.$zone. root.server.$zone. (
                42   ; serial
               	28800   ; refresh
                14400  ; retry
                3600000   ; expiry
                86400) ; minimum
        IN   NS server.$zone.
 
88 IN PTR
128 IN PTR
99  IN PTR" 
        read accept
        vim /var/named/$ip.zone
    elif [ $choice = "6" ];
    then
        echo Please input service,followed by port number if port is not needed, press 0
        read service
        read port
        if [ $port = "0" ];
        then
            firewall-cmd --add-service=$service --permanent && firewall-cmd --reload
        else
            firewall-cmd --add-service=$service --permanent && firewall-cmd --add-port=$port/tcp --permanent && firewall-cmd --reload
        fi
    elif [ $choice = "7" ];
    then
        echo Please input service,followed by port number if port is not needed, press 0
        read service
        read port
        if [ $port = "0" ];
        then
            firewall-cmd --remove-service=$service --permanent && firewall-cmd --reload
            
        else
            firewall-cmd --remove-service=$service --permanent && firewall-cmd --remove-port=$port/tcp --permanent && firewall-cmd --reload
        fi
    elif [ $choice = "8" ];
    then
        break
    fi
done
