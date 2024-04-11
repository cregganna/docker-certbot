#!/bin/sh

#	Created by Tony.Jewell@Cregganna.Com
#	Feel free to fork and use but I take no responsibility for the code or its effects.

die() {
	echo "$@"
	exit 1
}

prompt() {
	echo -n "$1 [$2]: "
}

usage="
** Docker CertBot **
  Show       - Show Account and Certificate Details
  Register   - Register Account with LetsEncrypt
               Example: Register myemail@example.com
  UnRegister - Unregister Account
  Create     - Create Certificate with given domain,
               Example: Create example.com
               (Will prompt you to add DNS Record and hit return)
  Renew      - Renew expired or close to expiry certificates
               (Can provide optional Certificate Name)
  Delete     - Delete Certificate
               Example: Delete example.com
  Certbot    - Run certbot with your own commands
  Shell      - Will run a bash shell
  Help       - This help
"

run() {
	certbot "$@" "--config-dir=/certificates" "--work-dir=/certificates" "--logs-dir=/certificates/logs"
}

echoRun() {
	echo "** certbot $@"
	run "$@"
}

show() {
	echo "** Account **"
	run show_account
	echo "** Certificates **"
	run certificates
}

checkAccountRegistered() {
	run show_account >/dev/null 2>&1 || die "Unable to $1: No Account registered - please run Register command first"
}

register() {
	[ "$#" -ge "1" ] || die "Please provide Account Email"
	echoRun register --agree-tos --no-eff-email -m "$1"
}

unregister() {
	echoRun unregister
}

create() {
	tty -s || die "Please run docker container with -it"
	[ "$#" -ge "1" ] || die "Please provide new certificate domain"
	checkAccountRegistered "Create Certificate"
	echoRun certonly --manual --manual-auth-hook /acme-dns-auth.py --preferred-challenges dns --debug-challenges \
		-d "*.$1" -d "$1" 
}

renew() {
	checkAccountRegistered "Create Certificate"
	if [ "$#" = 1 ]
	then
		echoRun renew --cert-name "$1"
	else
		echoRun renew
	fi
}


delete() {
	[ "$#" -ge "1" ] || die "Please provide new certificate domain"
	checkAccountRegistered "Delete Certificate"
	echoRun delete --cert-name "$1"
}

help() {
	echo "$usage"
}

if [ "$#" = "0" ]
then
	show
	help
else
	cmd="$1"; shift 1
	lCmd=`echo "$cmd" | tr '[:upper:]' '[:lower:]'`
	case "$lCmd" in
	show)		show "$@";;
	register)	register "$@";;
	unregister)	unregister "$@";;
	create)		create "$@";;
	renew)		renew "$@";;
	delete)		delete "$@";;
	help)		help "$@";;
	certbot)	echoRun "$@";;
	shell)		bash -i;;
	*)		help
			die "Unrecognised Command: $cmd $@"
			;;
	esac
fi
