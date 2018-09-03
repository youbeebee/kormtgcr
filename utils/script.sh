#!/bin/bash

##title:	블로그 태그 자동화 스크립트
##date :	2016. 11.
##author:	B.F.M.
## shell에서 실행이 안될 경우 vi에서 :set ff=unix를 치고 저장할 것.

##argument check
if [ 1 -ne $# ]
then
	echo "arg error"
	exit 1
else
	originalfile=$1
	echo "input : $originalfile"
fi

##Backup
file="temp_$originalfile"
cp "$originalfile" "$file"

##헤더(목차)/테일 날리기(txt가 유니코드UTF-8로 저장되어야 함)
function trim(){
	sed -i '1,/^용어사전/d' "$file"
	echo "Delete Header."
	
	sed -i '/^용어사전/,$d' "$file"
	echo "Delete Tail."
}

## 문법 적용
function markdown_change(){
	##대문단 md 문법 적용
	sed -i 's/\(\(^[0-9]\{3\}\)\. \)/<br><a name="\2"><\/a>\n\n### \1/g' "$file"
	
	##중문단 md 문법 적용
	sed -i 's/\(\(^[0-9]\{3\}\.[0-9]\+\)\.\)\( .\+$\)/<a name="\2"><\/a>\n<p class="paragraph" markdown="1">**\1**\3<\/p>/g' "$file"
	
	##소문단 md 문법 적용
	sed -i 's/\(^[0-9]\{3\}\.[0-9]\+[a-z]\+\)\( .\+$\)/<a name="\1"><\/a>\n<p class="clause" markdown="1">**\1**\2<\/p>/g' "$file"
	
	#--예외 : 205.3i-j, 509.1b, 810.7b 항목에 대한 문법 적용
	sed -i 's/\(^     .\+$\)/<p class="clause" markdown="1">\1<\/p>/g' "$file"
	
	##example 서식 적용
	sed -i 's/\(^Example:\) \(.\+$\)/<p class="example" markdown="1"> **\1** \2<\/p>/g' "$file"

	#--예외 : 607.5. 613.7a
	sed -i 's/\(\*\*613\.7a\*\* 어떤 효과가  \)<\/p>/\1/g' "$file"
	#'613.7a'를 찾은 뒤 5줄 이내에 해당되는 문장이 있으면 치환
	sed -i '/\*\*613\.7a\*\* 어떤 효과가  /, +5 { s/\(그 효과는 다른 효과와 독립적인 것으로 간주합니다\.\)/\1<\/p>/g; }' "$file"
	
	sed -i 's/\(\*\*Example:\*\* Arc.Slogger는 다음과 같은 능력을 가집니다.\+  \)<\/p>$/\1/g' "$file"

	sed -i '/\*\*Example:\*\* Arc.Slogger는 다음과 같은 능력을 가집니다\./, +5 { s/\(Arc-Slogger의 능력을 사용해 추방된 카드는 되돌릴 수 없습니다\.\)/\1<\/p>/g; }' "$file"
	
	echo "Tag apply complete."
}

function symbol_change(){
	##심볼변환
	#한단어 : 
	sed -i 's/{\([T|Q|C|W|B|U|R|G|E|S|P|X]\|PW\|CHAOS\|[0-9]\{1,2\}\)}/![symbol\1](\/assets\/symbols\/\1.gif)/g' "$file"

	#하이브리드:
	sed -i 's/{\([WUBRG2]\)\/\([WUBRGP]\)}/![symbol\1\2](\/assets\/symbols\/\1\2.gif)/g' "$file" 
	echo "Symbol change complete."
}

##홈페이지 링크
function url_change() {
	sed -i 's/\(https\?\:\/\/\)\?\([\da-zA-Z]\+\)\.\([A-Za-z\.]\{2,6\}\)\([\/A-Za-z0-9_\.-]*\)*\([A-Za-z0-9]\)\/\?/[\1\2.\3\4\5](http:\/\/\2.\3\4\5){:target="_blank"}/g' "$file"

	echo "URL change complete."
}

##주석변환
function footnote_change() {
	awk 'BEGIN {cnt =1} /번역자/ { sub(/번역자/, "번역자" cnt++) }1' "$file" > temp.txt
	sed -e 's/(\([^)]*\)번역자\([0-9]\+\)\([^(]*\))\(.*$\)/[^\2]\4\n\n[^\2]: \1\3/g' temp.txt > "$file"
	rm -f temp.txt
	echo "Comments change complete."
}

##See rule XX
function seerule_change() {
	sed -i 's/\(rules\?\|규칙\|and\|와\) *\(\([0-9]\)[0-9]\{2\}\(\.\([0-9]\+\([a-z]\)\{0,1\}\)\)*\)/\1 [\2](\/\300#\2)/g' "$file"

	echo "See rule xxx change complete."
}

##카드이름에 툴팁을 띄우기 위한 태그 추가
function card_name_tag_change() {
	sed -i 's/\[\[\(.\+\?\)\]\]/<mtg-card>\1<\/mtg-card>/g' "card_name.txt"

	echo "Card name tagging complete."
}

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
			##마지막 챕터는 맨 앞 1줄 제거
			tail -n +2 "$splitfilename" > temp.txt
			mv -f temp.txt "$splitfilename"	
		else
			##맨 앞 1줄, 맨 뒤 2줄 제거
			tail -n +2 "$splitfilename" > temp.txt
			head -n -3 temp.txt > "$splitfilename" 
			rm -f temp.txt
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
	mv -f $year-$month-$day-* ./cr/
	rm -f "$file"
}

##START
trim
markdown_change
url_change
symbol_change
footnote_change
seerule_change
##card_name_tag_change ##sed는 Non greedy 수량자를 지원하지 않아 사용 보류
split_chapter
clean_up

echo "Success!"
exit 0
