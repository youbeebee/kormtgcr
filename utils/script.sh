#!/bin/bash

##argument check
if [ 1 -ne $# ]
then
	echo "arg error"
	exit 1
else
	file=$1
fi

##Backup
cp "$file" "$file.orig"

##헤더(목차)/테일 날리기(txt가 유니코드UTF-8로 저장되어야 함)
function trim(){
	sed -e '1,/^용어사전/d' "$file" > temp.txt
	mv -f temp.txt "$file"
	echo "Delete Header."
	
	sed -e '/^용어사전/,$d' "$file" > temp.txt
	mv -f temp.txt "$file"
	echo "Delete Tail."
}

## 문법 적용
function markdown_change(){
	##대문단 md 문법 적용
	sed -e 's/\(^[0-9]\{3\}\. \)/<br>\n\n#### \1/g' "$file" > temp.txt
	mv -f temp.txt "$file"
	
	##중, 소문단 md 문법 적용
	sed -e 's/\(^[0-9]\{3\}\.[0-9]\+[.|a-z]*\)/**\1**/g' "$file" > temp.txt
	mv -f temp.txt "$file"
	
	##소문단 md 문법 적용
	sed -e 's/\(^\*\*[0-9]\{3\}\.[0-9]\+[a-z]\+\*\* .\+$\)/<p class="clause" markdown="1">\1<\/p>/g' "$file" > temp.txt
	mv -f temp.txt "$file"
	#--예외 : 205.3i-j, 509.1b, 810.7b
	
	##example 서식 적용
	sed -e 's/\(^Example:\) \(.\+$\)/<p class="example" markdown="1"> **\1** \2<\/p>/g' "$file" > temp.txt
	mv -f temp.txt "$file"
	#--예외 : 607.5.
	echo "Tag apply complete."
}

function symbol_change(){
	##심볼변환
	#한단어 : 
	sed -e 's/{\([T|Q|C|W|B|U|R|G|E|S|P|X]\|PW\|CHAOS\|[0-9]\{1,2\}\)}/![symbol\1](\/assets\/symbols\/\1.gif)/g' "$file" > temp.txt
	mv -f temp.txt "$file"
	#하이브리드:
	sed -e 's/{\([WUBRG2]\)\/\([WUBRGP]\)}/![symbol\1\2](\/assets\/symbols\/\1\2.gif)/g' "$file" > temp.txt
	mv -f temp.txt "$file"
	echo "Symbol change complete."
}

##홈페이지 링크
function url_change() {
	sed -e 's/\(https\?\:\/\/\)\?\([\da-zA-Z]\+\)\.\([A-Za-z\.]\{2,6\}\)\([\/A-Za-z0-9_\.-]*\)*\([A-Za-z0-9]\)\/\?/[\1\2.\3\4\5](http:\/\/\2.\3\4\5)/g' "$file" > temp.txt
	mv -f temp.txt "$file"
	echo "URL change complete."
}

##주석변환
function footnote_change() {
	awk 'BEGIN {cnt =1} /번역자/ { sub(/번역자/, "번역자" cnt++) }1' "$file" > temp.txt
	sed -e 's/(\([^)]*\)번역자\([0-9]\+\)\([^(]*\))\(.*$\)/[^\2]\4\n\n[^\2]\1\3/g' temp.txt > "$file"
	rm -f temp.txt
	echo "URL change complete."
}

##예외처리

##파일나누기&파일 이름 변경

##파일앞에 헤더 달기

##START
trim
markdown_change
url_change
symbol_change
footnote_change

echo "Success!"
exit 0