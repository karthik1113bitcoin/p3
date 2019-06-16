#!/bin/bash
# ##############################################################
# File Name		:	exectrusteduser.com
# Description	:	This file is the main interface for the
#					trusted users for executing their programs.
# Steps			:	It checks whether the given executable
#					belongs to babx4001 (menu gen) or bauu9093
#					TBA installation. If yes then it just
#					executes them (no need to login).
#					For others it first creates an LGI and then
#					executes the given batch program.
#					At the end it logs off the user.
# --------------------------------------------------------------
# Author		:	Aditya Narain Lal
# Modification	:	Original Version
# Date			:	13th April 1998
# --------------------------------------------------------------
# Author		:	Aditya Narain Lal
# Modification	:	Added code for taking Module and Solid
# Date			:	3rd May 1998
# --------------------------------------------------------------
# Author		:	Aditya Narain Lal
# Modification	:	Added code for changing to HOME directory
# Date			:	13th May 1998
# --------------------------------------------------------------
# Author		:	Aditya Narain Lal
# Modification	:	Added code for closing off stdin & stdout
# Date			:	20th May 1998
# --------------------------------------------------------------
# Author		:	Aditya Narain Lal
# Modification	:	Added code for passing file prefix in case
#					of SERVERMODE. This is required when there
#					are simultaneous connections from the same
#					server. There may be login file conflicts
#					because all of them start login in the same
#					initial directory.
# Date			:	24th May 1999
# ##############################################################

save_and_unset_stdout_stderr()
{
	if [ "$SERVERMODE" = YES ]
	then
		exec 4>&1
		exec 5>&2
		exec 1>&-
		exec 2>&-
	fi
}

restore_stdout_stderr()
{
	if [ "$SERVERMODE" = YES ]
	then
		exec 1>&4
		exec 2>&5
	fi
}

loc_exit()
{
	restore_stdout_stderr
	exit $1
}

# --------------------------------------------------------------
# Following function executes the given program. It checks the
# extension and call appropriate command - execom or exebatch.
# --------------------------------------------------------------
execute()
{
	restore_stdout_stderr
	extn=` echo $1 | cut -f2 -d. `
	if [ "$extn" = "com" ]
	then
		exename=$1
		shift 1
		`execom $exename` $*
	else
		exebatch $*
	fi
	exitValue=$?
	save_and_unset_stdout_stderr
}

# ----------------------------------------------------------
# This function changes to the working directory of the user
# ----------------------------------------------------------
change_to_home_dir()
{
	user=`id | cut -f2 -d'(' | cut -f1 -d')' 2>/dev/null`
	if [ -z "$user" ]
	then
		user=$USER_ID
		if [ -z "$user" ]
		then
			user=$USER_ID
		fi
	fi
	if [ -z "$user" ]
	then
		dir=/tmp
	else
		dir=`grep "^${user}:" /etc/passwd | awk -F: '{print $6}'`
		if [ -z "$dir" ]
		then
			dir=/tmp
		fi
	fi
	cd $dir
}

# -------------------
# MAIN ACTION BLOCK
# -------------------

# --------------------------------------------------
# Set the default umask for file/directory creation
# --------------------------------------------------
umask 002

# Save and unset file descriptors for stdout & stderr
save_and_unset_stdout_stderr


USAGE="USAGE: `basename $0` [-s <service outlet>] [-m <module>] <Batchexe> <args> ..."
if [ $# -lt 1 ]
then 
	echo $USAGE
	loc_exit 1
fi

set -- `getopt 's:m:' $*`
if [ $? -ne 0 ]
then
	echo $USAGE
	loc_exit 1
fi

SOL_ID_PARAM=""
MODULE_ID_PARAM=""

while [ $1 != -- ]
do
	case $1 in
	-s)	SOL_ID_PARAM="-s $2"
		shift
		;;
	-m)	MODULE_ID_PARAM="-m $2"
		shift
		;;
	esac
	shift
done
shift	# Eliminates --

# Store the rest of the paramaters
exes="$*"

# Define the file prefix for Login program for temporary files
# This is required to ensure file uniqueness in case multiple
# instances of the server come up.
PREFIX_PARAM=""
if [ "$SERVERMODE" = "YES" ]
then
	FILE_PREFIX="$$"
	PREFIX_PARAM="-p $$"
fi

export SOL_ID_PARAM
export MODULE_ID_PARAM
export FILE_PREFIX PREFIX_PARAM

# -----------------------------------------------------
# Ensure that there is some executable/script available
# -----------------------------------------------------
if [ $# -lt 1 ]
then 
	echo $USAGE
	loc_exit 1
fi

# ---------------------------------------------------------------
# In case the argument contains selected executables ignore login
# ---------------------------------------------------------------
cat <<EOT > /tmp/$$.tmp
mrbx4001
babx4001
bauu9093
babx4447
babx4448
EOT

if [ $? -ne 0 ]
then
	echo "Unable to create temporary file for selected executables"
	loc_exit 1
fi

grep `basename $1` /tmp/$$.tmp
status=$?
/bin/rm -f /tmp/$$.tmp

if [ $status -eq 0 ]
then
	execute $exes
	loc_exit $exitValue
fi

# -------------------------------------------------
# Get the complete names for Login & Logout scripts
# -------------------------------------------------
Login=` execom trustedUserLogin.com `
Logout=` execom trustedUserLogout.com `

if [ ! -f "$Login" -o ! -f "$Logout" ]
then
	echo "trustedUserLogin/Logout unaccessible"
	loc_exit 1
fi

trap '/bin/rm -f *.mn? ; . $Logout ; exit' 1 2 3

change_to_home_dir

# ----------------------------------------------------------
# Export the status variable which will be modified by Login
# ----------------------------------------------------------
exitStatus=0
export exitStatus

# Create the login session for trusted user
# -----------------------------------------
. $Login $PREFIX_PARAM $SOL_ID_PARAM $MODULE_ID_PARAM
if [ $exitStatus -ne 0 ]
then
	echo "Logon failed"
	loc_exit 1
fi

# -------------------------
# Execute the batch program
# -------------------------
execute $exes
ret=$exitValue

# -----------------------
# Logout the trusted user
# -----------------------
. $Logout

loc_exit $ret
