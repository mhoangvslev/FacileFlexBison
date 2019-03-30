.assembly loop {}
.method public static void Main() cil managed
{
	.entrypoint
	.maxstack 10
	.locals init (int32)

	nop
	ldc.i4	1
	stloc.0
	br.s LOOP_2
	// Start loop (head: LOOP_2)
	LOOP_START_2: nop
	ldloc	0
	ldc.i4	5
	ceq
	brfalse.s IF_6

	nop
	LOOP_START_7	nop
	nop
	IF_6:	ldloc	0
	ldc.i4	8
	ceq
	brfalse.s IF_17

	nop
	LOOP_END_18	nop
	nop
	IF_17:	ldloc	0
	call void class [mscorlib]System.Console::WriteLine(int32)
	nop
	nop
	ldloc.0
	ldc.i4.1
	add
	stloc.0

	LOOP_2: 	ldloc.0
	ldc.i4	10
	cgt
	ldc.i4.0
	ceq
	brtrue.s LOOP_START_2
	// End loop
	LOOP_END_2: nop
	IL_LAST: ret
}
