#!/bin/bash

##title:	블로그 태그 자동화 스크립트
##date :	2016. 11
##author:	B.F.M.

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
	
	#--예외 : 205.3i-j, 509.1b, 810.7b 항목에 대한 문법 적용
	sed -e 's/\(^     .\+$\)/<p class="clause" markdown="1">\1<\/p>/g' "$file" > temp.txt
	mv -f temp.txt "$file"
	
	##example 서식 적용
	sed -e 's/\(^Example:\) \(.\+$\)/<p class="example" markdown="1"> **\1** \2<\/p>/g' "$file" > temp.txt
	mv -f temp.txt "$file"
	#--예외 : 607.5. 613.7a
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
	sed -e 's/(\([^)]*\)번역자\([0-9]\+\)\([^(]*\))\(.*$\)/[^\2]\4\n\n[^\2]: \1\3/g' temp.txt > "$file"
	rm -f temp.txt
	echo "URL change complete."
}

##예외처리

##파일나누기&파일 이름 변경
chapter_kr=(
"1. 게임의 컨셉"
"2. 카드의 구성"
"3. 카드의 타입"
"4. 구역"
"5. 턴의 구조"
"6. 주문, 능력, 효과"
"7. 추가 규칙"
"8. 다인전 규칙"
"9. 캐주얼 규칙"
)

chapter_en=(
"1.Game Concepts"
"2.Parts of a Card"
"3.Card Types"
"4.Zones"
"5.Turn Structure"
"6.Spells, Abilities, and Effects"
"7.Additional Rules"
"8.Multiplayer Rules"
"9.Casual Variants"
)

chapter_num=(
"100"
"200"
"300"
"400"
"500"
"600"
"700"
"800"
"900"
)

chapter_both=(
"1. 게임의 컨셉 Game Concepts"
"2. 카드의 구성 Parts of a Card"
"3. 카드의 타입 Card Types"
"4. 구역 Zones"
"5. 턴의 구조 Turn Structure"
"6. 주문, 능력, 효과 Spells, Abilities, and Effects"
"7. 추가 규칙 Additional Rules"
"8. 다인전 규칙 Multiplayer Rules"
"9. 캐주얼 규칙 Casual Variants"
)

year=$(date +"%Y")
month=$(date +"%m")
day=$(date +"%d")

header="---
layout: post
title: test
categories: [OnlineCR]
tags: [cr, online]
comments: true
description: DDDD
---

{% include toc.md %}
"
function split_chapter() {
	for((i=1;i<10;i++)); do
		j=$((i+1))
		splitfilename=$year-$month-$day-${chapter_num[$i-1]}.md
		echo $splitfilename
		sed -n -e "/^$i\. /,/^$j\. /p" "$file" > "$splitfilename"
		
		if [ $i -eq 9 ]
		then
			sed -n -e '/^9\. /,$p' "$file" > "$splitfilename"
		fi
		
		if [ $i -eq 9 ]
		then	
			##마지막 챕터는 특별. 맨 앞 1줄
			sed -e 1d "$splitfilename" > temp.txt
			mv -f temp.txt "$splitfilename"	
		else
			##맨 앞 1줄, 맨 뒤 2줄 제거
			sed -e 1d "$splitfilename" > temp.txt
			mv -f temp.txt "$splitfilename"
			sed -e '$'d "$splitfilename" > temp.txt
			mv -f temp.txt "$splitfilename"
			sed -e '$'d "$splitfilename" > temp.txt
			mv -f temp.txt "$splitfilename"
		fi
		## 마지막 수평선 삽입
		echo "
" >> "$splitfilename"
		echo "----" >> "$splitfilename"

		
		##헤더 변경(test -> chapter[])
		echo "$header" > header.txt
		sed -e "s/test/${chapter_kr[$i-1]}/g" header.txt > temp.txt
		mv -f temp.txt header.txt
		sed -e "s/DDDD/${chapter_both[$i-1]}/g" header.txt > temp.txt
		rm -f header.txt
		##파일 앞에 헤더 달기
		cat "$splitfilename" >> temp.txt
		mv -f temp.txt "$splitfilename"
	done
}

function clean_up() {
	mkdir cr
	mv $year-$month-$day-* ./cr/
	mv -f "$file.orig" "$file"
}

##START
trim
markdown_change
url_change
symbol_change
footnote_change
split_chapter
clean_up

echo "Success!"
exit 0
