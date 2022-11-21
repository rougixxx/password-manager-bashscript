#!/bin/bash

umask 077

# variables 
GPG_OPTS="--quiet --yes --batch"
# --yes is for assume yes on mose questions || --batch is for Never ask, do not allow interactive commands.
STORE_DIR="${HOME}/.password_STORE"

#abort function
abort() {
	printf '%s\n' "${1}" 1>&2
	exit 1
}
#the encrypt and decrypt func 
gpg() {
	echo "Encrypting the password NOW"
	gpg2 $GPG_OPTS --default-recipient-self "$@"
}

#password reader 
readpw() {
	if [ -t 0 ]; then
		echo -n "Enter password for ${entry_name}:"
		read -s password
		echo
	fi
}

#insert func
insert() {
	entry_name="${1}"
	entry_path="${STORE_DIR}/${entry_name}.gpg"
	if [ -z "${entry_path}" ]; then
		abort "USAGE: tinypm.sh insert PROFILENAME"
	fi

	if [ -e "${entry_path}" ]; then
		abort "This entry or password profile already exists!"
	fi

	#reading the passwrod
	readpw

	if [ -t 0 ]; then
		printf '\n'
	fi

	if [ -z ${password} ]; then
		abort "You did not specify a password"
	fi
	
	mkdir -p "${entry_path%/*}"
 
 	echo -n "${password}" | gpg --encrypt --output "${entry_path}"
}

#show func
show() {
	entry_name="${1}"
	entry_path="$STORE_DIR/${entry_name}.gpg"

	if [ -z "${entry_name}" ]; then
		abort "USAGE: tinypm.sh show PROFILENAME"
	fi

	if [ ! -e "${entry_path}" ]; then
		abort "The requested password profile does not exists"
	fi

	gpg --decrypt "${entry_path}"

}

#list func
list() {
	for line in $(ls ~/.password_STORE | rev | cut -c 5- | rev); do
		echo $line 
	done
}

# THE MAIN PROGRAM
if [ "$#" -gt 2 ]; then
	abort "tinypm.sh will not work more than two arguments!"
fi

if [ "$#" -lt 1 ]; then
	abort "USAGE: tinypm.sh COMMAND PROFILENAME"
fi

# choosing what you want to do
case "${1}" in 
	"show") show "${2}" ;;
	"list") list ;;
	"insert") insert "${2}" ;;
	*) abort "USAGE: tinypm.sh COMMAND PROFILENAME" ;;
esac
#The COMMANDS

