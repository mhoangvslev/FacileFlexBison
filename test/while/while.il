.assembly while {}
.method public static void Main() cil managed
{
	.entrypoint
	.maxstack 10
	.locals init (int32, int32)

	call string class [mscorlib]System.Console::ReadLine()
	call int32 int32::Parse(string)
	stloc	0
	ldc.i4	0
	stloc	1
	br.s LOOP_6
	// Start loop (head: LOOP_6)
	LOOP_START_6: nop
	nop
	ldloc	1
	ldc.i4	1
	add
	stloc	1
	ldloc	0
	ldc.i4	1
	sub
	stloc	0
	ldloc	1
	call void class [mscorlib]System.Console::WriteLine(int32)
	nop
	LOOP_6: 	ldloc	0
	ldc.i4	0
	cgt
	brtrue.s LOOP_START_6
	// End loop
	LOOP_END_6: nop
	IL_LAST: ret
}
