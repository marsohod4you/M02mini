( J1 Cross Compiler                          JCB 16:55 05/02/12 )


\   Usage gforth cross.fs <machine.fs> <program.fs>
\
\   Where machine.fs defines the target machine
\   and program.fs is the target program
\

variable lst        \ .lst output file handle

: h#	\ -- X							\ берёт из входного потока текст как числа в HEX формате, преобразует в число, кладёт его на стек.
    base @ >r 16 base !
    0. bl parse >number throw 2drop postpone literal
    r> base ! ; immediate				\ слово немедленного исполнения. по умолчанию, всегда выполняется.

: tcell     2 ;							\ базовый размер ячейки 2 байта -> 16 битный целевой форт
: tcells    tcell * ;
: tcell+    tcell + ;

131072 allocate throw constant tflash   \ bytes, target flash new - на 128 KBytes? адрес памяти в  tflash
131072 allocate throw constant _tbranches   \ branch targets, cells		new - на 128 KBytes? адрес памяти в  _tbranches
tflash      131072 0 fill					\ очищаем эти выденые блоки памяти
_tbranches  131072 0 fill
: tbranches cells _tbranches + ;			\ n -- addr	 	Вычисляем адрес памяяти в блоке _tbranches по номеру её ячейки.

variable tdp    0 tdp !						\ Переменная указателя верхушки словаря целевого форта

: there     tdp @ ;						\ -- addr Получить верхушку словаря целевого форта
: islegal   ;							\ -- ничего не делает
: tc!       islegal tflash + c! ;		\ c taddr -- Запись байта в целевой словарь. taddr - адрес в пространстве целевого словаря.
: tc@       islegal tflash + c@ ;		\ taddr -- с Чтение байта из целевого словаря.  taddr - адрес в пространстве целевого словаря.
: tw!       islegal tflash + w! ;
: t!        islegal tflash + l! ;
: t@        islegal tflash + uw@ ;
: twalign   tdp @ 1+ -2 and tdp ! ;		\ Выравнивание целевой словаря на 16-ти битную границу.
: talign    tdp @ 3 + -4 and tdp ! ;	\ Выравнивание целевой словаря на 32-ти битную границу.
: tc,       there tc! 1 tdp +! ;		\ с -- Записать байт по адресу вершины словаря, нарастить указатель словаря на 1 байт.
: t,        there t!  4 tdp +! ;		\ x -- Записать слово по адресу вершины словаря, нарастить указатель словаря на 4 байта.
: tw,       there tw! tcell tdp +! ;	\ x -- Записать 16-битное слово по адресу вершины словаря, нарастить указатель словаря на 2 байта.
: org       tdp ! ;						\ addr -- установить вершину целевого словаря

wordlist constant target-wordlist		\ -- Константа идентификатора словаря.

: add-order ( wid -- )					\
		>r get-order r> swap 1+ set-order
;

: ::	\ --							\ Создать новое слово в целевом словаре.
		get-current >r					\ Сохранить предыдущий словарь пополнения.
		target-wordlist set-current		\ Установить новый.
		:								\ Выполнить определение.
		r> set-current					\ Востановить предыдущий словарь пополнения.
;

\ next-arg included       				\ Подключить файл исходника из аргумента командной строки запуска.
include basewords.fs

( Language basics for target                 JCB 19:08 05/02/12 )

warnings off
:: ( postpone ( ;
:: \ postpone \ ;

:: org          org ;					\ Копии слов из форта-источника в целевой форт.
:: include      include ;
:: included     included ;
:: marker       marker ;
:: [if]         postpone [if] ;
:: [else]       postpone [else] ;
:: [then]       postpone [then] ;

: literal		( x -- )
		\ dup $f rshift over $e rshift xor 1 and throw
		dup h# 8000 and					\ x f 15-й бит установлен?
	if									\ x	  Компиляция литералов для FCPU. Сильно завязано на способе хранения их в процессоре.
		h# ffff xor recurse				\ ~x  Инверсия значения и рекурсивный вызов.
		~T alu							\ Записать опкод инверсии.
	else
		h# 8000 or tw,					\ Установлить 15-й бит и сохранить.
	then
;
: literal								\ X -- 32-разрядная версия предыдущего literal-а
		dup $80000000 and
	if
		invert recurse
		~T alu
	else
		dup $ffff8000 and
	 if
		dup $F rshift recurse
		$f recurse
		N<<T d-1 alu
		$7fff and recurse
		T|N d-1 alu
      else
		$8000 or tw,
      then
    then
;

\ ***************************************************************
( Defining words for target                  JCB 19:04 05/02/12 )

: codeptr		( -- orig )				\ адрес интерпретатора кода для условных/безусловных переходов - в шагах ЦПУ.
		tdp @ 2/						\ orig
;

: wordstr		( "name" -- c-addr u )	\ Получить строку из входного потока без изменения его указателя.

		>in @ >r 						\ Сохранить индекс входного потока.
		bl word count					\ c-addr u	Выделить слово из входнго потока.
		r> >in !						\ c-addr u	Сохранить индекс входного потока.
;

variable link 0 link !					\ указатель последнего определённого слова в целевом коде.

:: header		(  "name"  -- )			\ Создать в целевом пространстве кода заголовок словарной статьи.
		twalign there					\ taddr	выравнивание адреса кода.
	\ cr ." link is " link @ .
		link @ tw,						\ taddr	первые 2 байта - адрес последнего созданого слова (поле связи односвязного списка)
		link !							\ определяемое слово - последнее в цепочке списка.
		bl parse						\ c-addr u		имя слова из входного потока.
		dup tc,							\ c-addr u		длина имени слова
		bounds							\ c-addr-e c-addr-b	Перевести в диапазон адресов
	do									\ цикл по длине имени.
		i c@ tc,						\ считать и сохранить символ имени в целевом коде.
	loop								\ повторить по всей длине имени.
		twalign							\ выравнивание адреса кода.
;

:: :			( -- orig )				\ двоеточечное опредеяющее слово в целевом словаре.

		hex
		codeptr s>d						\ D. адрес интерпретатора
		<# bl hold # # # # #>			\ c-addr u		форматное преобразование числа в HEX формате  "XXXX "
		lst @ write-file throw			\ записать в лог адрес
		wordstr lst @ write-line throw	\ записать в лог имя слова
		create  codeptr ,				\ Создать новое слово. Сохранить адрес выполнения.
		does>   @ scall					\ При выполнении, считать сохранённый адрес и выполнить как ПП.
;


:: :noname		( -- xt )				\ опредеяющее слово для слов без имени, в целевом словаре.
;
:: ,			( x -- )				\ Сохранение данных в памяти по текущему указателю, с продвижением указателя на 2.
		talign							\ выравнивание адреса кода.
		t,
;
:: allot		( u -- )				\ Резервирование области памяти по текущему указателю, с продвижением указателя на U.
		0
	?do
		0 tc,
	loop
;
: shortcut		( orig -- f ) 			\ insn @orig precedes ;. Shortcut it.\	????
    \ call becomes jump
		dup t@ h# e000 and h# 4000 =	\ orig f		
	if
		dup t@ h# 1fff and over tw!
		true
	else
		dup t@ h# e00c and h# 6000 =
	 if
		dup t@ h# 0080 or r-1 over tw!
		true
         else
		false
         then
	then
		nip
;
:: ;			( -- )					\ окончание двоеточечного определения слова в целевом словаре.
		there 2 - shortcut				\ true if shortcut applied
		there 0
	do
		i tbranches @ there = 
	 if
		i tbranches @ shortcut and
	 then
	loop
		0=
	if   \ not all shortcuts worked
		s" exit" evaluate
	then
;
:: ;fallthru		( -- )
;

:: jmp			( " name" -- )			\ Компиляция безусловного перехода на слово "NAME"
		' >body @ ubranch				\ 
;
:: constant		( x " name" -- )		\ Создание константы с именем "NAME".
		create ,						\ Создающая часть.
		does>
		@ literal						\ Выполняющая часть.
;

:: create		( "name" -- )
		talign							\ выравнивание адреса кода.
		create there ,					\ Созадь слово, сохранить адрес начала кода.
		does>
		@ literal						\ При выполнении компилируем литерал с сохранеённым адресом.
;

( Switching between target and meta          JCB 19:08 05/02/12 )

: target		\ --					\ Добавить словарь target-wordlist к просмотру.

		only							\ v: -- FORTH Сбросить стек словарей в дефолт. (FORTH)
		target-wordlist add-order		\ v: -- FORTH TARG	Добавить target-wordlist на верхушку стека.
		definitions						\ И установить его для пополнения.
;
: ]			\ --
		target							\ Синоним предыдущего слова.
;
:: meta			\ --					\ Заменить верхушку стека словарей на FORTH словарь	

		forth definitions				\ v: -- FORTH
;
:: [			\ --					\ ]Синоним предыдущего слова.

		forth definitions
;
: t'			\ " name" -- xt			\ Найти исполнительный токен слова из входного потока.
		bl parse target-wordlist search-wordlist	\ 0 | xaddr f Найти слово в словаре "target-wordlist".
		0= throw						\ Вызвать исключение, если не нашли.
		>body @							\ xt Адрес выполнения.
;

( eforth's way of handling constants         JCB 13:12 09/03/10 )

: sign>number   ( c-addr1 u1 -- d c-addr2 u2 ) \ Преобразование строки текста "caddr u" в целое число двойной точности в текущей системе счисления.
										\ На выходе: d - чсло двойной точности, знаковое, c-addr2 u2 - остаток непреобразованой части строки.

		0. 2swap						\ 0. caddr1 u1		Подготивть к преобразованию в 64-битное
		over c@ [char] - =				\ 0. caddr1 u1 f	Первый символ это знак "-"?
	if
		1 /string						\ 0. caddr1+1 u1-1	Исключить этот знак из преобразования (продвинуть указатель строки вправо на 1 символ)
		>number							\ D  caddr2 u2		Преобразовать в 64-битное число.
		2swap dnegate 2swap				\ -D caddr2 u2		Сделать отрицательным.
	else
		>number							\ D  caddr2 u2		Преобразовать в 64-битное число.
	then
;

: base>number   ( caddr u base -- )		\			Преобразование строки текста "caddr u" в число в системе счисления "base"

		base @ >r base !				\ caddr u	Сохранить текущую систему счисления.
		sign>number						\ D caddr1 u1	Преобразовать в 64-битное число.
		r> base !						\ D caddr1 u1	Востановить текущую систему счисления.
		dup 0=							\ D f			Преобразование прошло без ошибок?
	if
		2drop drop literal				\ -- | n		Сброс указателя строки, сброс старшей части двойного, компиляция литерала.
	else
		1 = swap c@ [char] . = and		\ D f			Не преобразовался один символ в конце и это "." ?
	 if
		drop dup literal 32 rshift literal		\			компиляция литерала двойного размера.
	 else
		-1 abort" bad number"			\ иначе - ошибка в преобразовании. вызов исключительной ситуации  интерпретации.
	 then
	then
;

:: d#			( "name" -- )			\ Компиляция литералов в десятичном виде.
		bl parse 10 base>number			\
;
:: h#			( "name" -- )			\ Компиляция литералов в шестнадцатеричном  виде.
		bl parse 16 base>number			\
;		
:: [']
		' >body @ 2* literal			\ Компиляция литерала-ссылки на другое слово.
;		
:: [char]
		char literal					\ Компиляция символа.
;
:: asm-0branch		( "name" -- )		\ Компиляция кода условного перехода.

		' >body @						\ xt
		0branch							\
;

( Conditionals                               JCB 13:12 09/03/10 )
\ Слова для компиляции управляющих конструкций форта IF ELSE THEN

: resolve ( orig -- )					\ Компиляция разрешения ссылки вперёд/назад.

		there over tbranches !			\ forward reference from orig to this loc
		dup t@ there 2/ or swap tw!		\
;
:: if			( -- orig )
		there							\ orig
		0 0branch						\ orig Заготовка условного перехода
;
:: then
		resolve
;
:: else			( orig1 -- orig2 )		\
		there							\ orig1 orig2
		0 ubranch 						\ orig1 orig2 Заготовка безусловного перехода
		swap resolve					\ orig2
;
:: begin		( -- orig )				\ Маркер ссылки.
		 there							\ orig
;
:: again		( orig -- )
		2/ ubranch						\ безусловный переход назад
;
:: until		( orig -- )
		2/ 0branch						\ условный переход назад
;
:: while		( orig1 -- orig1 orig2 ) \
		there							\ orig1 orig2
		0 0branch						\ orig1 orig2 Заготовка условного перехода
;
:: repeat		( orig1 orig2 -- )
		swap 2/ ubranch					\ orig2
		resolve							\
;

4 org									\ текущий адрес компиляции = 4

: .trim ( a-addr u -- a-addr u1 ) 		\ shorten string until it ends with '.'	\	Удаление всех символов с конца строки до символа "."

	begin
		2dup + 1- c@ [char] . <>		\ a-addr u f Последний символ не "." ?
	while
		1-								\ a-addr u-1 Сократить строку.
	repeat								\ a-addr u-1 Повторить
;

include strings.fs						\ модуль работы со строками.


:noname
		S" demo1.fs" 2dup .trim >str	\ c-addr u a-ddr строка имени файла без расширения
;										\ xt
execute
constant prefix.

: .suffix		( c-addr1 u1 -- c-addr2 u2 ) \	Добавить новое расширение к имени файла заданом в prefix

		>str prefix. +str str@			\ c-addr2 u2
;

: create-output-file	( c-addr u -- )	\ Создать файл для записи.
		w/o create-file throw			\ Создать файл, обработать ошибки.
;

: out-suffix		( c-addr1 u1 -- h )	\ Создать файл с расширением "c-addr1 u1" для записи в папке " ../build/firmware/"

		>str							\ a-addr 	Адрес строки в памяти 
		prefix. +str					\ a-addr1	Добавить расширение к проекту - "Prefix+Ext"
		s" ../firmware/" >str +str str@	\ a-addr1	Добавить путь к проекту 
		create-output-file				\ h			Создать файл, получить дескриптор.
;

:noname
		s" lst" out-suffix lst !		\ Добавить расширение файла "lst" к файлу заданом в prefix
; execute

target included                         \ include the program.fs

[ tdp @	0 org ] main [ org ]
meta									\ v: FORTH
decimal
0 value file

: dumpall.16							\ Вывести на печать, всё, что накомпилили в 16 разрядном виде
		s" hex" out-suffix to file		\
		hex
		1024 0							\ iend ibeg
	do
		tflash i 2* + w@				\ w
		s>d <# # # # # #> file write-line throw		\
	loop
		file close-file					\
;

: dumpall.32							\ Вывести на печать, всё, что накомпилили в 32 разрядном виде.
		s" hex" out-suffix to file
		hex
		4096 0
	do
		tflash i 4 * + @
		s>d <# # # # # # # # # #> file write-line throw
	loop
		file close-file
;

: swap_low_high 
	$FFFFFFFF and cr dup . dup $FFFF and #16 lshift swap #16 rshift or ;

: dump_mif.32
    s" mif" out-suffix to file
	s" WIDTH = 32;" file write-line throw
	s" DEPTH = 1024;" file write-line throw
	s" ADDRESS_RADIX = HEX;" file write-line throw
	s" CONTENT BEGIN" file write-line throw
    hex
    1024 0 do
		s" ;" >str
        tflash i 4 * + @ ( swap_low_high ) 
        s>d <# # # # # # # # # #> >str
		s"  : " >str
		i s>d <# # # # # #> >str +str +str +str str@
		file write-line throw
    loop
	s" END" file write-line throw
    file close-file
;

dump_mif.32
dumpall.32

bye
