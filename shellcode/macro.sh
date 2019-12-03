while true
clear
do
	echo What do you want to edit today? 1\)ssh 2\)vsftpd 3\)chroot_list 4\)tftp 5\)httpd 6\)hosts 7\)squid
	read choice
	if [ $choice = "1" ];
	then
		vim /etc/ssh/sshd_config
		echo Did you change the port? 1\) Yes 2\) No
		read port
		if [ $port = "1" ];
		then
			echo which port?
			read number
			semanage port -a -t ssh_port_t -p tcp $number
			firewall-cmd --add-port=$number/tcp --permanent
			firewall-cmd --reload
		fi
	elif  [ $choice = "2" ];
	then
		vim /etc/vsftpd/vsftpd.conf
		systemctl restart vsftpd
	elif [ $choice = "3" ];
	then
		echo username to add to chroot?
		read username
	        echo $username >> /etc/vsftpd/chroot_list
		vim /etc/vsftpd/vsftpd.conf
		setsebool -P ftpd_full_access on
		systemctl restart vsftpd	
	elif [ $choice = "4" ];
	then
		vim /etc/xinetd.d/tftp
		systemctl restart xinetd
		firewall-cmd --add-service=tftp --permanent
		firewall-cmd --reload
	elif [ $choice = "5" ];
	then
		echo 1\)edit config 2\)create new config 3\)create new file 4\)htpasswd
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
		fi
	elif [ $choice = "6" ]; then
		echo Current hostname: 
		hostnamectl
		echo Enter new hostname: 
		read $newhostname
		hostnamectl -set-hostname $newhostname
		echo ${newhostname} set
		
	elif [ $choice = "7" ];
	then
		vim /etc/squid/squid.conf
		systemctl restart squid
	fi

				
done