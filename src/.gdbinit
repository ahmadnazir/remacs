# Set up something to print out s-expressions.
define pr
set Fprin1 ($, Qexternal_debugging_output)
echo \n
end
document pr
Print the emacs s-expression which is $.
Works only when an inferior emacs is executing.
end

# Set this to the same thing as the DATA_SEG_BITS macro in your
# machine-description files.
set $data_seg_bits = 0

define xtype
output (enum Lisp_Type) (($ >> 24) & 0x7f)
echo \n
end
document xtype
Print the type of $, assuming it is an Elisp value.
end

define xint
print (($ & 0x00ffffff) << 8) >> 8
end
document xint
Print $, assuming it is an Elisp integer.  This gets the sign right.
end

define xptr
print (void *) (($ & 0x00ffffff) | $data_seg_bits)
end
document xptr
Print the pointer portion of $, assuming it is an Elisp value.
end

define xwindow
print (struct window *) (($ & 0x00ffffff) | $data_seg_bits)
printf "%dx%d+%d+%d\n", $->width, $->height, $->left, $->top
end
document xwindow
Print $ as a window pointer, assuming it is an Elisp window value.
Print the window's position as "WIDTHxHEIGHT+LEFT+TOP".
end

define xmarker
print (struct Lisp_Marker *) (($ & 0x00ffffff) | $data_seg_bits)
end
document xmarker
Print $ as a marker pointer, assuming it is an Elisp marker value.
end

define xbuffer
print (struct buffer *) (($ & 0x00ffffff) | $data_seg_bits)
output &((struct Lisp_String *) ((($->name) & 0x00ffffff) | $data_seg_bits))->data
echo \n
end
document xbuffer
Set $ as a buffer pointer, assuming it is an Elisp buffer value.
Print the name of the buffer.
end

define xsymbol
print (struct Lisp_Symbol *) (($ & 0x00ffffff) | $data_seg_bits)
output &$->name->data
echo \n
end
document xsymbol
Print the name and address of the symbol $.
This command assumes that $ is an Elisp symbol value.
end

define xstring
print (struct Lisp_String *) (($ & 0x00ffffff) | $data_seg_bits)
output ($->size > 10000) ? "big string" : ($->data[0])@($->size)
echo \n
end
document xstring
Print the contents and address of the string $.
This command assumes that $ is an Elisp string value.
end

define xvector
print (struct Lisp_Vector *) (($ & 0x00ffffff) | $data_seg_bits)
output ($->size > 1000) ? "big vector" : ($->contents[0])@($->size)
echo \n
end
document xvector
Print the contents and address of the vector $.
This command assumes that $ is an Elisp vector value.
end

define xframe
print (struct frame *) (($ & 0x00ffffff) | $data_seg_bits)
end
document xframe
Print $ as a frame pointer, assuming it is an Elisp frame value.
end

define xcons
print (struct Lisp_Cons *) (($ & 0x00ffffff) | $data_seg_bits)
output *$
echo \n
end
document xcons
Print the contents of $, assuming it is an Elisp cons.
end

define xcar
print ((($ >> 24) & 0x7f) == Lisp_Cons ? ((struct Lisp_Cons *) (($ & 0x00ffffff) | $data_seg_bits))->car : 0)
end
document xcar
Print the car of $, assuming it is an Elisp pair.
end

define xcdr
print ((($ >> 24) & 0x7f) == Lisp_Cons ? ((struct Lisp_Cons *) (($ & 0x00ffffff) | $data_seg_bits))->cdr : 0)
end
document xcdr
Print the cdr of $, assuming it is an Elisp pair.
end

define xsubr
print (struct Lisp_Subr *) (($ & 0x00ffffff) | $data_seg_bits)
output *$
echo \n
end
document xsubr
Print the address of the subr which the Lisp_Object $ points to.
end

set print pretty on

unset environment TERMCAP
unset environment TERM
echo TERMCAP and TERM environment variables unset.\n
show environment DISPLAY
set args -q

# Don't let abort actually run, as it will make
# stdio stop working and therefore the `pr' command below as well.
break abort

# If we are running in synchronous mode, we want a chance to look around
# before Emacs exits.  Perhaps we should put the break somewhere else
# instead...
break _XPrintDefaultError

