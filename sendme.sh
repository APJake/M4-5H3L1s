#!/bin/bash

default_folder_path="./"
my_address=$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}')

my_address_prefix=$(echo "$my_address" | cut -d '.' -f1 -f2 -f3)
my_port=""
full_path_name=""

function setUpMyPort(){
	my_port="$1"
	if [ -z $my_port ]
	then
		my_port="${my_address: -1}00${RANDOM: -1}"
	fi
}

function createMode(){
	setUpMyPort "$1"
	clear
	echo "Listening..."
	echo "Address: $my_address"
	echo "Port: $my_port"
	echo
	echo

	nc -l "$my_port"
}

function requestAddress(){
	echo -n "Enter address: $my_address_prefix."
	read addr
	client_address="$my_address_prefix.$addr"
}

function requestPort(){
	echo -n "PORT: "
	read port
	client_port="$port"
}

function setUpClientAddressAndPort(){

	client_address="$1"
	client_port="$2"

	if [ -z "$client_address" ]
	then
		requestAddress
	fi

	if [ -z "$client_port" ]
	then
		requestPort
	fi

}

function getFilePath(){
	read file_path
}

function connectMode(){

	setUpClientAddressAndPort "$1" "$2"

	clear
	echo "Connected $client_address:$client_port..."
	echo 
	echo
	echo

	nc "$client_address" "$client_port"

}

function fileSendingMode(){

	setUpClientAddressAndPort

	filename="$1"
	if [ -z "$filename" ]
	then
		echo -n "Enter file path to send: "
		read filename
	fi

	nc -w 3 "$client_address" "$client_port" < "$filename"

}

function fileReceivingMode(){
	
	setUpMyPort

	clear
	echo "Receiving file..."
	echo "Address: $my_address"
	echo "Port: $my_port"

	filename="$1"
	if [ -z "$filename" ]
	then
		echo -n "Enter file path to save: "
		read filename
	fi

	nc -l "$my_port" > "$filename"
}

function tryAgain(){
	echo "1) Listen."
	echo "2) Connect."
	echo "3) File send."
	echo "4) File receive."
	echo
	echo -n "Choose one: "
	read option

	case "$option" in
		"1" )
		runWithMode "-l"
			;;
		"2" )
		runWithMode "-c"
			;;
		"3" )
		runWithMode "-s"
			;;
		"4" )
		runWithMode "-r"
			;;
		* )
		tryAgain
			;;
	esac
}

function runWithMode(){

	mode="$1"

	if [ -z "$mode" ]
	then
		tryAgain
	elif [ "$mode" == "-l" ]
	then
		createMode "$2"
		exit
	elif [ "$mode" == "-s" ]
	then
		fileSendingMode "$2"
		exit
	elif [ "$mode" == "-r" ]
	then
		fileReceivingMode "$2"
		exit
	elif [ "$mode" == "-c" ]
	then
		connectMode
		exit
	else
		connectMode "$1" "$2"
		exit
	fi

}


runWithMode "$1" "$2"


# AP-Jake
# Version-1.0
# Created - Aug 01, 2022
# Last Modified - Aug 01, 2022
