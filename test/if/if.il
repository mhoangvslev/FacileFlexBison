.assembly if {}
.method public static void Main() cil managed
{
	.entrypoint
	.maxstack 10
	.locals init (int32, int32, int32)

	call string class [mscorlib]System.Console::ReadLine()
	call int32 int32::Parse(string)
	stloc	0
	ldc.i4	25
	stloc	1
	ldc.i4	0
	stloc	2
	ldloc	0
	ldloc	1
	clt
	brfalse.s IF_13

	nop
	ldloc	2
	ldc.i4	1
	add
	call void class [mscorlib]System.Console::WriteLine(int32)
	nop
	nop
	br.s IL_LAST

	IF_13:	ldloc	0
	ldloc	1
	cgt
	brfalse.s ELSEIF_23

	nop
	ldloc	2
	ldc.i4	2
	add
	call void class [mscorlib]System.Console::WriteLine(int32)
	nop
	nop
	br.s IL_LAST

	ELSEIF_23: 	nop
	ldloc	2
	ldc.i4	3
	add
	call void class [mscorlib]System.Console::WriteLine(int32)
	nop
	IL_LAST: ret
}
