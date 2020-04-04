mdownload() {
	if A=$(find . -name $1"*.deb" -exec echo -n "1" \;); [ "$A" = "" ]
	then
		echo '\033[37m' поиск  $1 '\033[0m'
		apt download $1:$2 2>>errors.txt
		if A=$(find . -name $1"*.deb" -exec echo -n "1" \;); [ "$A" = "" ]
		then
			echo '\033[33m' не найден $1*.deb для $1:$2  - поиск $1:any '\033[0m'
			apt download $1 2>>errors.txt
		fi
		if A=$(find . -name $1"*.deb" -exec echo -n "1" \;); [ "$A" = "" ]
		then
			echo '\033[31m' пакет $1 не найден'\033[0m'
		else
			echo '\033[32m' пакет $1 скачан '\033[0m'
		fi
	else
		echo '\033[2m\033[37m' пакет $1 уже скачан '\033[0m'
	fi

}

mdownloadwithrel() {
	mdownload $1 $2

	for i in $(apt-cache depends $1 | grep -E 'Зависит|Предлагает' | cut -d  ':' -f 2 | sed -e s/'<'/''/ -e s/'>'/''/)
	do
		if [ -z "$3" ]
		then
			#############
			#без рекурсии
			#############
			mdownload $i $2
		else
			#######################################################
			##рекурсия скачивает все хранилище - это не правильно.
			#########################################################
			if A=$(find . -name $i"*.deb" -exec echo -n "1" \;); [ "$A" = "" ]
			then
				mdownloadwithrel $i $2 $3
			else
				echo '\033[2m\033[37m' пакет $i уже скачан '\033[0m'
			fi
		fi
	done
}

if  [ -z "$3" ]
then
	echo '\033[32m' режим без рекурсии '\033[0m'
else
	echo '\033[31m' режим с рекурсией '\033[0m'
fi
mdownloadwithrel $1 $2 $3
