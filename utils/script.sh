#!/bin/sh

##argument check
if [ 1 -ne $# ]
then
	echo "arg error"
	exit 1
fi
file=$1

##Backup
cp $file $file.org

function markdown_change(){
	##대문단 md 문법 적용
	sed -e 's/\(^[0-9]\{3\}\. \)/<br>\n\n#### \1/g' $file > temp.txt
	mv -f temp.txt $file
	
	##중, 소문단 md 문법 적용
	sed -e 's/\(^[0-9]\{3\}\.[0-9]\+[.|a-z]*\)/**\1**/g' $file > temp.txt
	mv -f temp.txt $file
	
	##소문단 md 문법 적용
	sed -e 's/\(^\*\*[0-9]\{3\}\.[0-9]\+[a-z]\+\*\* .\+$\)/<p class="clause" markdown="1">\1<\/p>/g' $file > temp.txt
	mv -f temp.txt $file
	#--예외 : 205.3i-j, 509.1b, 810.7b
	
	##example 서식 적용
	sed -e 's/\(^Example:\) \(.\+$\)/<p class="example" markdown="1"> **\1** \2<\/p>/g' $file > temp.txt
	mv -f temp.txt $file
	#--예외 : 607.5.
	echo "Tag apply complete."
}

function symbol_change(){
	##심볼변환
	#한단어 : 
	sed -e 's/{\([T|Q|C|W|B|U|R|G|E|S|P|X]\|PW\|CHAOS\|[0-9]\{1,2\}\)}/![symbol\1](\/assets\/symbols\/\1.gif)/g' $file > temp.txt
	mv -f temp.txt $file
	#하이브리드:
	sed -e 's/{\([WUBRG2]\)\/\([WUBRGP]\)}/![symbol\1\2](\/assets\/symbols\/\1\2.gif)/g' $file > temp.txt
	mv -f temp.txt $file
	echo "Symbol change complete."
}

##홈페이지 링크

#echo "Hyperlink change complete."

##주석변환

##예외처리

##파일나누기&파일 이름 변경

##파일앞에 헤더 달기

##
markdown_change
symbol_change

echo "Success!"
exit 0