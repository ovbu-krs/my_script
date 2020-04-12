myprint() {
	color='\033[0m'

	case $2 in
		'war' ) color='\033[2m\033[37m';;
		'ok' ) color='\033[32m';;
		'err' ) color='\033[31m';;
	esac

	if [ $3 -gt 1 ]
	then
		echo -n '|'
		printf "%.$3d" 0 | sed s/0/./g

		echo -n '|'>>log.log
		printf "%.$3d" 0 | sed s/0/./g>>log.log

	fi

	if [ $4 -eq 1 ]
	then
		echo $color $1 '\033[0m'
		echo $1>>log.log

	else
		echo -n $color $1 '\033[0m'
		echo -n $1>>log.log
	fi

}
mdownload() {
	myprint 'паект '$1':'$2' поиск' 'simple' $3  1
	if A=$(find . -name $1"_*.deb" -exec echo -n "1" \;); [ "$A" = "" ]
	then
		apt download $1:$2 2>>errors.txt
		if A=$(find . -name $1"_*.deb" -exec echo -n "1" \;); [ "$A" = "" ] && [ "$2" != "any" ]
		then
			myprint 'пакет '$1:$2' не найден  - поиск '$1':any' 'war' $3 1
			apt download $1 2>>errors.txt
		fi
		if A=$(find . -name $1"_*.deb" -exec echo -n "1" \;); [ "$A" = "" ]
		then
			myprint 'пакет '$1' не найден' 'err' $3 1
		else
			myprint 'пакет '$1' скачан' 'ok' $3 1
		fi
	else
		myprint 'пакет '$1' уже скачан' 'war' $3 1
	fi

}
mdownloadwithrel() {

	#среди предлогает первого уровня часто встрчаются необходимые пакеты
	mdownload $1 $2 $3
	fnd_str='Зависит|Предзависит|Предлагает'
	if [ $3 -gt 1 ]
	then
		fnd_str='Зависит|Предзависит'
	fi

	for i in $(apt-cache depends $1':'$2 | grep -E $fnd_str | cut -d  ':' -f 2 | sed -e s/'<'/''/ -e s/'>'/''/)
	do

		if [ -z "$4" ]
		then
			#############
			#без рекурсии
			#############
			mdownload $i $2 $(( $3+1 ))
		elif A2=$(find . -name $i"_*.deb" -exec echo -n "1" \;); [ "$A2" = "" ]
		then
			#######################################################
			##рекурсия скачивает все хранилище - это не правильно.
			#########################################################
			mdownloadwithrel $i $2 $(( $3+1 )) 1
		elif A4=$(find . -name $i"_*.deb" -exec echo -n "1" \;); [ "$A4" = "1" ]
		then
			myprint 'пакет '$i' уже скачан' 'war' $3 1
		fi
	done
}

if  [ "$3" = "0" ]
then
	myprint 'режим без рекурсии' 'simple' 0 1
else
	myprint 'режим с рекурсией' 'err' 0 1
fi

date_now=$(date  +%Y%m%d%H%M%S)
mname=$1'_'$2'_'$date_now
if [ -z "$4" ]
then
	mkdir $mname
elif A3=$(find . -name $4 -exec echo -n "1" \;); [ "$A3" = "" ]
then
	mname=$4
	mkdir $mname
else
	mname=$4
fi

myprint 'текущий кататлог '$mname 'ok' 0 1

cd $mname
mdownloadwithrel $1 $2 1 $3
cd ..
