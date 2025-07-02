#!/bin/bash

# ВНИМАНИЕ! Если нет папки fv_utf8 то необходимо скачать эту библиотеку:
# git clone https://github.com/unxed/fv_utf8

# Перекодировка всех файлов из одной кодировки в другую
# find . -type f -print -exec iconv -f cp866 -t utf-8 -o {}.converted {} \; -exec mv {}.converted {} \;

# Смена расширения у всех файлов по маске
# rename 's/.PAS/.pas/' ./*.PAS

rm samples
rm -rf units
fpcmake
make
