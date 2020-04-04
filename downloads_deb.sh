echo поиск $1:$2

apt download $1:$2 2>>errors.txt

for i in $(apt-cache depends $1 | grep -E 'Зависит|Предлагает' | cut -d  ':' -f 2 | sed -e s/'<'/''/ -e s/'>'/''/)
do
	if A=$(find . -name $i"*.deb" -exec echo -n "1" \;); [ "$A" = "" ]
	then
		echo '\033[37m' поиск  $i '\033[0m'
		apt download $i:$2 2>>errors.txt
		if A=$(find . -name $i"*.deb" -exec echo -n "1" \;); [ "$A" = "" ]
		then
			echo '\033[33m' не найден $i*.deb для $i:$2  - поиск $i:any '\033[0m'
			apt download $i 2>>errors.txt
		fi
		if A=$(find . -name $i"*.deb" -exec echo -n "1" \;); [ "$A" = "" ]
		then
			echo '\033[31m' пакет $i не найден'\033[0m'
		else
			echo '\033[32m' пакет $i скачан '\033[0m'
		fi


	else
		echo '\033[2m\033[37' пакет $i уже скачан '\033[0m'
	fi
done

if B=$(find . -name $1"*.deb" -exec echo -n "1" \;); [ "$B" = "" ]
then
	echo '\033[31m' пакет $1 не найден'\033[0m'
else
	echo '\033[32m' пакет $1 скачан '\033[0m'
fi


