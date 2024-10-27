#! /bin/bash
TEMPDATAFILE="tmp/tempdata.tmp";

encode(){

	BIT=$(($1));

	if [ $BIT == 0 ]; then

		PARAM=18;
		TOTAL=1;

	else

		PARAM=9;
		TOTAL=2;

	fi;

	while [ $TOTAL -gt 0 ]; do


		I=0;
		while [ $I -lt $PARAM ]; do
			printf "\xC0" >> $TEMPDATAFILE;
			I=$(($I+1));
		done;

		I=0;
		while [ $I -lt $PARAM ]; do
			printf "\x40" >> $TEMPDATAFILE;
			I=$(($I+1));
		done;	

		TOTAL=$(($TOTAL-1));

	done;

}

header(){

	if [ "long" == "$1" ]; then

		PULSES=8000;

	else

		PULSES=2000;

	fi

	II=0;

	while [ $II -lt $PULSES ]; do

		encode 1;

		II=$(($II+1));

	done;	

}

silence(){

	I=0;
	while [ $I -lt $((18*4000)) ]; do
		AUX=`printf "%02X" 127`;
		printf "\x$AUX" >> $TEMPDATAFILE;
		I=$(($I+1));
	done;

}
wavheader(){

	printf "RIFF";
	printf "\xFF\xFF\xFF\xFF";
	printf "WAVEfmt ";

	printf "\x10\x00\x00\x00\x01\x00\x01\x00";

	printf "\x44\xac\x00\x00";
	printf "\x44\xac\x00\x00";

	printf "\x01\x00\x08\x00";

	AUX=`printf "%08X" $(($1)) | awk '{print "\\\\x"substr($1,7,2)"\\\\x"substr($1,5,2)"\\\\x"substr($1,3,2)"\\\\x"substr($1,1,2)}'`;

	printf "data$AUX";

}

encodefile(){

	if [ -e $1 ]; then

		BYTELEN=`cat $1 |  tr "\n" "\r" | xxd -i | tr "\n"  " " | sed s/" "/""/g | awk -F "," '{print NF}'`;

		CONT=0;

		while read A; do

			if [ $CONT == $((256*11)) ]; then

				silence;

				header;

				CONT=0;

			fi;

			encode $A;

			CONT=$((CONT+1));

		done < <(cat $1 | xxd -b | sed s/".*:"/""/ | sed s/"^ "/""/ | sed s/"[ ][ ].*"/""/ | sed s/" "/"\n"/g | awk '{print "0";I=8;while(I>0){print substr($1,I,1);I=I-1;}print "1";print "1";}')

		if [ "" == "$2" ]; then 

			ZEROS=$((256-$BYTELEN));

			II=0;

			while [ $II -lt $ZEROS ]; do

				for III in 0 0 0 0 0 0 0 0 0 1 1; do

					encode $III;

				done;

				II=$(($II+1));
			done;

		fi;

	fi;

}

msxheaderfile(){

	echo -n "" > tmp/headerfile.tmp;

	II=0;
	while [ $II -lt 10 ]; do
		printf "\xEA" >> tmp/headerfile.tmp; 
		II=$(($II+1));
	done;
	echo "$1" | awk -F "/" '{printf substr($NF,1,6);}' >> tmp/headerfile.tmp;

}

lastblockfile(){

	echo -n "" > tmp/lastblockfile.tmp;

	II=0;
	while [ $II -lt 256 ]; do

		printf "\x1A" >> tmp/lastblockfile.tmp; 

		II=$(($II+1));
	done;

}

helpme(){

	echo "$0 is used to convert bas MSX basic programs into wav files.";

	printf "\t$0 command must me used with 2 arguments:\n";
	printf "\t\t$0 file.bas output.wav\n"
	echo "";	
	printf  "\tfile.bas: The name of the file whith the basic program in ascii.";
	echo "";
	echo "";
	printf  "\tfile.wav: The name of the output file where the wav is created.";
	echo "";
	echo "";

}

if [ "" != "$1" ]; then

	if [ "" != "$2" ]; then

		if [ -e "$1" ]; then

			if [ -e "$2" ]; then

				echo "$2 exists, please remove it before run the program.";

			else

				touch $2;

				if [ "$?" == "0" ]; then

					echo -n "" > $TEMPDATAFILE

					mkdir tmp 2> /dev/null;

					header "long";
					msxheaderfile $1;
					encodefile "tmp/headerfile.tmp" "NOZEROS";

					silence;
					header;
					encodefile $1;

					silence;
					header;
					lastblockfile;
					encodefile "tmp/lastblockfile.tmp" "NOZEROS";

					TOTALLONG=`ls -al $TEMPDATAFILE | awk '{print $5}'`;

					wavheader $TOTALLONG > $2;

					cat $TEMPDATAFILE >> $2;

					rm tmp/headerfile.tmp  tmp/lastblockfile.tmp  tmp/tempdata.tmp

				else

					echo "Can not write on $2.";

				fi;

			fi;

		else

			echo "$1 does not exists.";

		fi;

	else

		helpme;

	fi;

else

	helpme;

fi;
