header 1+       : 1+        d# 1 + ;
header 1-       : 1-        d# -1 + ;
header 0=       : 0=        d# 0 = ;
header cell+    : cell+     d# 2 + ;

header <>       : <>        = invert ; 
header >        : >         swap < ; 
header 0<       : 0<        d# 0 < ; 
header 0>       : 0>        d# 0 > ;
header 0<>      : 0<>       d# 0 <> ;
header u>       : u>        swap u< ;

( check serial rx port has byte )
header read?
: read?
    d# 0 io@
    d# 8 and
    0<>
;

( read byte from serial port )
header read
: read
    begin
        read?
    until
    d# 0 io@ d# 8 rshift
    d# 0 d# 2 io!
;

( check serial tx port busy )
: tx_busy
    d# 0 io@
    d# 4 and
    0=
;

header emit
: emit
    begin tx_busy until
    h# 0 io!
;

header c@
: c@

header cr
: cr
    d# 13 emit
    d# 10 emit
;

header space
: space
    d# 32 emit
;

: h  dup d# 10 < if h# 30 else d# 55 then + emit ;
: hh dup d# 4 rshift d# 15 and h d# 15 and h ;

: main
	noop
	noop
	noop
	noop
	noop
	d# 0
    begin
		read dup hh space emit cr
		d# 1 +
		dup
		d# 4 io!
    again
;
