#!/usr/bin/python3
"""태그 자동화 스크립트
 * Date: 2022-01-19
 * Author:	B.F.M.
 * Usage: python3 thisfile.py ../MagicCompRules_KR.txt
"""
import os
import sys
import re


def check_args():
    if len(sys.argv) != 2:
        print("Insufficient arguments")
        print("Usage: python3 {} ../MagicCompRules_KR.txt".format(__file__))
        sys.exit()
    else:
        return sys.argv[1]


def open_file(name):
    with open(name, 'r') as f:
        text = f.read()
    return text


def trim(text):
    """헤더와 푸터 제거
    """
    trimed_txt = text.split('용어사전')
    if len(trimed_txt) != 3:
        print('Trim Error!')
        sys.exit()

    return trimed_txt[1]


def apply_markdown(t):
    """마크다운 문법 적용
    """
    # 대문단 (100. xxxx)
    pattern = r'((^[0-9]{3})\. )'
    repl = r'<br><a name="\g<2>"></a>\n\n### \g<1>'
    t = regex_replace(pattern, repl, t)

    # 중문단 (100.1. xxxx)
    pattern = r'((^[0-9]{3}\.[0-9]+)\.)( .+$)'
    repl = r'<a name="\2"></a>\n<p class="paragraph" markdown="1">**\1**\3</p>'
    t = regex_replace(pattern, repl, t)

    # 소문단 (100.1a xxxx)
    pattern = r'(^[0-9]{3}\.[0-9]+[a-z]+)( .+$)'
    repl = r'<a name="\1"></a>\n<p class="clause" markdown="1">**\1**\2</p>'
    t = regex_replace(pattern, repl, t)

    # example (Example: xxxx)
    pattern = r'(^Example:) (.+$)'
    repl = r'<p class="example" markdown="1"> **\1** \2</p>'
    t = regex_replace(pattern, repl, t)

    return t


def apply_symbol(t):
    """심볼을 gif 이미지로 변환
    {T} -> ![{T}](/assets/symbols/T.gif)
    """
    # 한 단어
    pattern = r'{([T|Q|C|W|B|U|R|G|E|S|P|X]|PW|CHAOS|[0-9]{1,2})}'
    repl = r'![{\1}](/assets/symbols/\1.gif)'
    t = regex_replace(pattern, repl, t)

    # 하이브리드
    pattern = r'{([WUBRG2])/([WUBRGP])}'
    repl = r'![{\1\2}](/assets/symbols/\1\2.gif)'
    t = regex_replace(pattern, repl, t)

    return t


def apply_url(t):
    """마크다운 문법으로 웹페이지 링크
    """
    pattern = r'(https?://)?(([\da-zA-Z]+)\.([A-Za-z\.]{2,6})([\/A-Za-z0-9_\.-]*)*([A-Za-z0-9])/?)'
    repl = r'[\g<1>\g<2>](http://\g<2>){:target="_blank"}'

    return regex_replace(pattern, repl, t)


def apply_seerule(t):
    """See rule xxx 변환
    """
    pattern = r'(rules?|규칙|and|와) *(([0-9])[0-9]{2}(\.([0-9]+([a-z]){0,1}))*)'
    repl = r'\1 [\2](/\g<3>00#\2)'

    return regex_replace(pattern, repl, t)


def apply_footnote(t):
    """주석 변환
    (번역자 주-xxxx) -> [^n]xxxx,
    """
    count = 1
    while t.find('번역자 주-') != -1:
        t = t.replace('번역자 주-', '주석{cnt} '.format(cnt=count), 1)
        count += 1

    # r'\(([^)]*)주석([0-9]+)([^(]*)\)(.*$)'
    # r'[^\2]\4\n\n[^\2]: \1\3'
    pattern = r'\(주석([0-9]+) (.*?)\)(.*$)'  # *? -> non greedy qualifier
    repl = r'[^\1]\3\n\n[^\1]: \2'
    t = regex_replace(pattern, repl, t)
    return t


def apply_card_tag(t):
    """카드 이름 태그로 변환
    기능은 구현되어 있으나 룰텍스트에 적용은 안함
    [[xxxx]] -> <mtg-card>xxxx</mtg-card>
    """
    pattern = r'\[\[\(.+?\)\]\]'  # +? -> non greedy qualifier
    repl = r'<mtg-card>\1</mtg-card>'

    return regex_replace(pattern, repl, t)


def regex_replace(pattern, repl, string):
    """string(str)에서 pattern(regex)을 찾아 repl(regex)로 변환
    """
    return re.sub(pattern, repl, string, flags=re.MULTILINE)


def split_chapter(t):
    return t


if __name__ == '__main__':
    filename = check_args()
    text = open_file(filename)

    print('START')
    text = trim(text)
    print('Delete Header & Footer')

    text = apply_markdown(text)
    print('Tag apply complete.')

    text = apply_symbol(text)
    print('Symbol change complete.')

    text = apply_url(text)
    print('URL change complete.')

    text = apply_seerule(text)
    print('See rule xxx change complete.')

    text = apply_footnote(text)
    print('Footnote change complete.')

    text = apply_card_tag(text)
    print('Card name tagging complete.')

    print('END')
    print(text)
