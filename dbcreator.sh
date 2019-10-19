#!/bin/bash
# usage:  wget -O createdb https://raw.githubusercontent.com/debihard/dbcreator/master/dbcreator.sh && chmod +x createdb
# Install, Configure and Optimize MySQL
install_secure_mysql(){
    clear
    
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing, Configuring and Optimizing MySQL"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    apt -y install mysql-server
    echo ""
    echo -n " configuring MySQL............ "

apt -y install pwgen
apt -y install gpw    
NEW_MYSQL_PASSWORD=mysql_root_"$(pwgen 12 1)"

    #echo -n " Type the new root password: "; read -s NEW_MYSQL_PASSWORD
    
    # Usage:
#  Setup mysql root password:  ./mysql_secure.sh 'your_new_root_password'
#  Change mysql root password: ./mysql_secure.sh 'your_old_root_password' 'your_new_root_password'"
#

# Delete package expect when script is done
# 0 - No; 
# 1 - Yes.
#PURGE_EXPECT_WHEN_DONE=0

#
# Check the bash shell script is being run by root
#
#if [[ $EUID -ne 0 ]]; then
#   echo "This script must be run as root" 1>&2
#   exit 1
#fi

#
# Check input params
#
#if [ -n "${1}" -a -z "${2}" ]; then
    # Setup root password
#    CURRENT_MYSQL_PASSWORD=''
#    NEW_MYSQL_PASSWORD="${1}"
#elif [ -n "${1}" -a -n "${2}" ]; then
    # Change existens root password
#    CURRENT_MYSQL_PASSWORD="${1}"
 #   NEW_MYSQL_PASSWORD="${2}"
#else
#    echo "Usage:"
#    echo "  Setup mysql root password: ${0} 'your_new_root_password'"
#    echo "  Change mysql root password: ${0} 'your_old_root_password' 'your_new_root_password'"
#    exit 1
#fi

#
# Check is expect package installed
#
if [ $(dpkg-query -W -f='${Status}' expect 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    echo "Can't find expect. Trying install it..."
    apt -y install expect --no-install-recommends

fi

SECURE_MYSQL=$(expect -c "
set timeout 3
spawn mysql_secure_installation
expect \"Press y|Y for Yes, any other key for No :\"
send \"n\r\"
expect \"New password:\"
send \"$NEW_MYSQL_PASSWORD\r\"
expect \"Re-enter new password:\"
send \"$NEW_MYSQL_PASSWORD\r\"
expect \"Remove anonymous users? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect eof
")

#
# Execution mysql_secure_installation
#
echo "${SECURE_MYSQL}"

#if [ "${PURGE_EXPECT_WHEN_DONE}" -eq 1 ]; then
    # Uninstalling expect package
#    aptitude -y purge expect
#fi

    
    
    #mysql_secure_installation
    service mysql restart
    
}

create_mysql_user_db(){
    clear

    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Create MySQL user and database"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""

apt -y install pwgen
apt -y install gpw

# Autodetect IP address and pre-fill for the user
IP="$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)"
usernamedb=dbuser_"$(gpw 1 6)"
userdbpass=dbuser_pass_"$(pwgen 8 1)"
charset=utf8
dbname=db_"$(gpw 1 7)"

# Bash script written by Saad Ismail - me@saadismail.net

# If /root/.my.cnf exists then it won't ask for root password
if [ -f /root/.my.cnf ]; then
	
	echo "Creating new adminpanel database..."
	mysql -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET ${charset} */;"
	echo "Database successfully created!"
	echo "Showing existing databases..."
	mysql -e "show databases;"
	echo ""
	
	echo "Creating new user..."
	mysql -e "CREATE USER ${usernamedb}@localhost IDENTIFIED BY '${userdbpass}';"
	echo "User successfully created!"
	echo ""
	echo "Granting ALL privileges on ${dbname} to ${usernamedb}!"
	mysql -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${usernamedb}'@'localhost';"
	mysql -e "FLUSH PRIVILEGES;"
	echo "You're good now :)"
	echo ""
	
cat > /root/mysqldata <<EOL
##################################################################################################################
##################################################################################################################
##################################################################################################################

User name: $usernamedb
User db password: $userdbpass
Database name: $dbname
Mysql Root Password: $NEW_MYSQL_PASSWORD

##################################################################################################################
##################################################################################################################
##################################################################################################################
EOL

# If /root/.my.cnf doesn't exist then it'll ask for root password	
else
	echo "Please enter root user MySQL password!"
	read -s rootpasswd <<< $NEW_MYSQL_PASSWORD
	echo "Creating new adminpanel database..."
	mysql -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET ${charset} */;"
	echo "Database successfully created!"
	echo "Showing existing databases..."
	mysql -e "show databases;"
	echo ""
	
	echo "Creating new user..."
	mysql -e "CREATE USER ${usernamedb}@localhost IDENTIFIED BY '${userdbpass}';"
	echo "User successfully created!"
	echo ""
	echo "Granting ALL privileges on ${dbname} to ${usernamedb}!"
	#mysql -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${usernamedb}'@'localhost' WITH GRANT OPTION;"
	mysql -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${usernamedb}'@'localhost';"
	mysql -e "FLUSH PRIVILEGES;"
	echo "You're good now :)"
	echo ""

	
cat > /root/mysqldata <<EOL
##################################################################################################################
##################################################################################################################
##################################################################################################################

User name: $usernamedb
User db password: $userdbpass
Database name: $dbname
Mysql Root Password: $NEW_MYSQL_PASSWORD

##################################################################################################################
##################################################################################################################
##################################################################################################################
EOL

fi
}

install_secure_mysql
create_mysql_user_db
cat /root/mysqldata
