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
	##�빮�� md ���� ����
	sed -e 's/\(^[0-9]\{3\}\. \)/<br>\n\n#### \1/g' $file > temp.txt
	mv -f temp.txt $file
	
	##��, �ҹ��� md ���� ����
	sed -e 's/\(^[0-9]\{3\}\.[0-9]\+[.|a-z]*\)/**\1**/g' $file > temp.txt
	mv -f temp.txt $file
	
	##�ҹ��� md ���� ����
	sed -e 's/\(^\*\*[0-9]\{3\}\.[0-9]\+[a-z]\+\*\* .\+$\)/<p class="clause" markdown="1">\1<\/p>/g' $file > temp.txt
	mv -f temp.txt $file
	#--���� : 205.3i-j, 509.1b, 810.7b
	
	##example ���� ����
	sed -e 's/\(^Example:\) \(.\+$\)/<p class="example" markdown="1"> **\1** \2<\/p>/g' $file > temp.txt
	mv -f temp.txt $file
	#--���� : 607.5.
	echo "Tag apply complete."
}

function symbol_change(){
	##�ɺ���ȯ
	#�Ѵܾ� : 
	sed -e 's/{\([T|Q|C|W|B|U|R|G|E|S|P|X]\|PW\|CHAOS\|[0-9]\{1,2\}\)}/![symbol\1](\/assets\/symbols\/\1.gif)/g' $file > temp.txt
	mv -f temp.txt $file
	#���̺긮��:
	sed -e 's/{\([WUBRG2]\)\/\([WUBRGP]\)}/![symbol\1\2](\/assets\/symbols\/\1\2.gif)/g' $file > temp.txt
	mv -f temp.txt $file
	echo "Symbol change complete."
}

##Ȩ������ ��ũ

#echo "Hyperlink change complete."

##�ּ���ȯ

##����ó��

##���ϳ�����&���� �̸� ����

##���Ͼտ� ��� �ޱ�

##
markdown_change
symbol_change

echo "Success!"
exit 0