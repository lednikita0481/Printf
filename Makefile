all: everybody

everybody: printf.o call_printf.o
						gcc call_printf.o -no-pie printf.o -o printf

printf.o:	 printf.s
						nasm -f elf64 -l printf.lst printf.s

call_printf.o: call_printf.c 
								gcc -c call_printf.c call_printf.o

clear:
		rm .o