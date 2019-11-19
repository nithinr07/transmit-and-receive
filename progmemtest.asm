mov dptr, #8000h
push dph
push dpl
mov dptr, #0ed00h
movx @dptr, A
pop dpl
pop dph
movx @dptr, A
ret