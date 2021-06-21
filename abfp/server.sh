#!/bin/bash

PORT=2021
OUTPUT_PATH="salida_server/"

echo "(0) Server ABFP"

echo "(1) Listening $PORT"

HEADER=`nc -l -p $PORT`

echo "TEST! $HEADER"

PREFIX=`echo $HEADER | cut -d " " -f 1`
IP_CLIENT=`echo $HEADER | cut -d " " -f 2`

echo "(4) RESPONSE"

if [ "$PREFIX" != "ABFP" ]; then

	echo "Error en la cabecera"

	sleep 1
	echo "KO_CONN" | nc -q 1 $IP_CLIENT $PORT

	exit 1
fi

sleep 1
echo "OK_CONN" | nc -q 1 $IP_CLIENT $PORT

echo  "(5) LISTEN"

HANDSHAKE=`nc -l -p $PORT`

if [ "$HANDSHAKE" != "THIS_IS_MY_CLASSROOM" ]; then
	echo "ERROR: Handshake incorrecto"

	sleep 1
	echo "KO_HANDSHAKE" | nc -q 1 $IP_CLIENT $PORT

	exit 2
fi

echo "(8a) RESPONSE"
sleep 1
echo "YES_IT_IS" | nc -q 1 $IP_CLIENT $PORT


echo "(8b) LISTEN NUM_FILES"
NUM_FILES=`nc -l -p $PORT`

PREFIX=`echo $NUM_FILES | cut -d " " -f 1`
NUM=`echo $NUM_FILES | cut -d " " -f 2`

if [ "$PREFIX" != "NUM_FILES" ]; then
	echo "ERROR: Prefijo NUM_FILES incorrecto"

	sleep 1
	echo "KO_NUM_FILES" | nc -q 1 $IP_CLIENT $PORT

	exit 3
fi

sleep 1
echo "OK_NUM_FILES" | nc -q 1 $IP_CLIENT $PORT

echo "NUM_FILES: $NUM"

for NUMBER in `seq $NUM`; do

	echo "(9) LISTEN FILE_NAME"

	FILE_NAME=`nc -l -p $PORT`


	PREFIX=`echo $FILE_NAME | cut -d " " -f 1`
	NAME=`echo $FILE_NAME | cut -d " " -f 2`
	NAME_MD5=`echo $FILE_NAME | cut -d " " -f 3`

	if [ "$PREFIX" != "FILE_NAME" ]; then
		echo "ERROR: Prefijo FILE_NAME incorrecto"

		sleep 1
		echo "KO_FILE_NAME" | nc -q 1 $IP_CLIENT $PORT

		exit 4
	fi

	TEMP_MD5=`echo $NAME | md5sum | cut -d " " -f 1`

	if [ "$NAME_MD5" != "$TEMP_MD5" ]; then
		echo "ERROR: MD5 Incorrecto"

		sleep 1
		echo "KO_FILE_NAME_MD5" | nc -q 1 $IP_CLIENT $PORT

		exit 5
	fi

	echo "(12) RESPONSE OK_FILE_NAME"
	sleep 1
	echo "OK_FILE_NAME" | nc -q 1 $IP_CLIENT $PORT

	TEMP_MD5=`nc -l -p $PORT`
	
	FILE=`nc -l -p $PORT`
	FILE_MD5=`echo $FILE | md5sum | cut -d " " -f 1`

	if [ "$TEMP_MD5" != "$FILE_MD5" ]; then
		echo "ERROR: MD5 Incorrecto"

		sleep 1
		echo "KO_FILE_MD5" | nc -q 1 $IP_CLIENT $PORT

		exit 6
	fi

	echo $OUTPUT_PATH$NAME

	echo "$FILE" > $OUTPUT_PATH$NAME
done

sleep 1
echo "OK_DATA" | nc -q 1 $IP_CLIENT $PORT


echo "(Extra) DESPEDIDA"
GOODBYE=`nc -l -p $PORT`
if [ "$GOODBYE" != "ABFP GOODBYE" ]; then
	echo "Error: wrong goodbye"
	exit 7
fi

exit 0
