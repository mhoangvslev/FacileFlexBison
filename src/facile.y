%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include <glib.h>

#define YYERROR_VERBOSE 1

int yylex();
int yyerror(const char* msg);

GHashTable *table;

// Offset - Useful for branching
unsigned int if_offset = -1; // +1 everytime
unsigned int elseif_offset = -1; // +1 everytime
unsigned int loop_offset = -1; // +1 when loop

FILE *stream;
char *module_name;
unsigned int max_stack = 10;

extern void begin_code();
extern void end_code();
extern void produce_code(GNode * node);

/* Error handling */


%}


%token<number> TOK_NUMBER
%token<string> TOK_IDENT
%token TOK_AFFECT
%token TOK_SEMICOLON
%left TOK_ADD
%left TOK_SUB
%left TOK_MUL
%left TOK_DIV
%token TOK_OPEN_PARENTHESIS
%token TOK_CLOSE_PARENTHESIS
%token TOK_PRINT
%token TOK_READ

/* Logical OP */
%token TOK_BOOL_OR;
%token TOK_BOOL_AND;
%token TOK_BOOL_EQ;
%token TOK_BOOL_NEQ;
%token TOK_BOOL_GTE;
%token TOK_BOOL_GT;
%token TOK_BOOL_LTE;
%token TOK_BOOL_LT; 
%token TOK_BOOL_NOT;
%token TOK_BOOL_TRUE;
%token TOK_BOOL_FALSE;

/* Operator precedence */
%left TOK_BOOL_OR;
%left TOK_BOOL_AND;
%left TOK_BOOL_NOT;
%left TOK_BOOL_EQ TOK_BOOL_GT TOK_BOOL_GTE TOK_BOOL_LT TOK_BOOL_LTE TOK_BOOL_NEQ;

/* If ElseIf Else */
%token TOK_IF
%token TOK_THEN;
%token<string> TOK_END;
%token<string> TOK_ENDIF;

%token TOK_ELSEIF;
%token TOK_ELSE;

/* While */
%token TOK_WHILE;
%token TOK_ENDWHILE;
%token<string> TOK_DO;

/* Foreach */
%token<string> TOK_FOREACH;
%token<string> TOK_ENDFOREACH;
%token<string> TOK_IN;
%token<string> TOK_ARR_TO;
%token<string> TOK_CONTINUE;
%token<string> TOK_BREAK;

%type<node> code
%type<node> expr
%type<node> instruction
%type<node> ident
%type<node> print
%type<node> read
%type<node> affectation

/*Extension*/
%type<node> boolean_expr
%type<node> if-stmt
%type<node> endif
%type<node> else
%type<node> elseif

%type<node> while-stmt
%type<node> endwhile

%type<node> foreach-stmt
%type<node> endforeach
%type<node> loop-interuptor

%union {
	gulong number;
	char *string;
	GNode * node;
}

%%

program: code {
	begin_code();
	produce_code($1);
	end_code();
	g_node_destroy($1);
} 
;

code:
	code instruction
	{
		$$ = g_node_new("code");
		g_node_append($$, $1);	
		g_node_append($$, $2);		
	}
|
	%empty
	{
		$$ = g_node_new("");
	}
;

instruction: affectation | print | read | if-stmt | while-stmt | foreach-stmt | loop-interuptor;

ident:
	TOK_IDENT
	{
		$$ = g_node_new("ident");
		gulong value = (gulong) g_hash_table_lookup(table, $1);
		if (!value) {
			value = g_hash_table_size(table) + 1;
			g_hash_table_insert(table, strdup($1), (gpointer) value);
		}
		g_node_append_data($$, (gpointer)value);
	}
;

affectation:
	ident TOK_AFFECT expr TOK_SEMICOLON
	{
		$$ = g_node_new("affect");
		g_node_append($$, $1);	
		g_node_append($$, $3);
	}
;

print:
	TOK_PRINT expr TOK_SEMICOLON
	{
		$$ = g_node_new("print");
		g_node_append($$, $2);
	}
;

read:
	TOK_READ ident TOK_SEMICOLON
	{
		$$ = g_node_new("read");
		g_node_append($$, $2);
	}
;

expr:
	ident
|
	TOK_NUMBER
	{
		$$ = g_node_new("number");
		g_node_append_data($$, (gpointer)$1);
	}
|
	expr TOK_ADD expr
	{
		$$ = g_node_new("add");
		g_node_append($$, $1);	
		g_node_append($$, $3);	
	}
|
	expr TOK_SUB expr
	{
		$$ = g_node_new("sub");
		g_node_append($$, $1);	
		g_node_append($$, $3);	
	}
|
	expr TOK_MUL expr
	{
		$$ = g_node_new("mul");
		g_node_append($$, $1);	
		g_node_append($$, $3);	
	}
|
	expr TOK_DIV expr
	{
		$$ = g_node_new("div");
		g_node_append($$, $1);	
		g_node_append($$, $3);	
	}
|
	TOK_OPEN_PARENTHESIS expr TOK_CLOSE_PARENTHESIS
	{
		$$ = $2;
	}
;

boolean_expr:
	TOK_OPEN_PARENTHESIS boolean_expr TOK_CLOSE_PARENTHESIS
	{
		$$ = g_node_new("boolexpr");
		g_node_append($$, $2);
	}
|
	TOK_BOOL_TRUE
	{
		$$ = g_node_new("boolTrue");
	}
|
	TOK_BOOL_FALSE
	{
		$$ = g_node_new("boolFalse");
	}
|
	expr TOK_BOOL_EQ expr
	{
		$$ = g_node_new("eq");
		g_node_append($$, $1);
		g_node_append($$, $3);
	}
|
	expr TOK_BOOL_GT expr
	{
		$$ = g_node_new("gt");
		g_node_append($$, $1);
		g_node_append($$, $3);
	}
|
	expr TOK_BOOL_GTE expr
	{
		$$ = g_node_new("gte");
		g_node_append($$, $1);
		g_node_append($$, $3);
	}
|
	expr TOK_BOOL_LT expr
	{
		$$ = g_node_new("lt");
		g_node_append($$, $1);
		g_node_append($$, $3);
	}
|
	expr TOK_BOOL_LTE expr
	{
		$$ = g_node_new("lte");
		g_node_append($$, $1);
		g_node_append($$, $3);
	}
|
	expr TOK_BOOL_NEQ expr
	{
		$$ = g_node_new("neq");
		g_node_append($$, $1);
		g_node_append($$, $3);
	}
|
	boolean_expr TOK_BOOL_OR boolean_expr
	{
		$$ = g_node_new("or");
		g_node_append($$, $1);
		g_node_append($$, $3);
	}
|
	TOK_BOOL_NOT boolean_expr
	{
		$$ = g_node_new("not");
		g_node_append($$, $2);
	}
|
	boolean_expr TOK_BOOL_AND boolean_expr
	{
		$$ = g_node_new("and");
		g_node_append($$, $1);
		g_node_append($$, $3);
	}
;

if-stmt: 
	TOK_IF boolean_expr chk_then code elseif else endif
	{
		$$ = g_node_new("if");
		g_node_append($$, $2);
		g_node_append($$, $4);
		g_node_append($$, $5);
		g_node_append($$, $6);
		g_node_append($$, $7);
	}
;

endif: 
	TOK_END
	{
		$$ = g_node_new("endif");
	}
| 
	TOK_ENDIF
	{
		$$ = g_node_new("endif");
	}
;

elseif: 
	TOK_ELSEIF boolean_expr chk_then code elseif
	{
		$$ = g_node_new("elseif");
		g_node_append($$, $2);
		g_node_append($$, $4);
		g_node_append($$, $5);
	}
|
	%empty
	{
		$$ = g_node_new("");
	}
;
else:
	TOK_ELSE code
	{
		$$ = g_node_new("else");
		g_node_append($$, $2);
	}
|
	%empty
	{
		$$ = g_node_new("");
	}
;

loop-interuptor:
	TOK_CONTINUE TOK_SEMICOLON
	{
		$$ = g_node_new("skipItr");
	}
|
	TOK_BREAK TOK_SEMICOLON
	{
		$$ = g_node_new("breakLoop");
	}
;

while-stmt:
	TOK_WHILE boolean_expr chk_do code endwhile
	{
		$$ = g_node_new("while");
		g_node_append($$, $2);
		g_node_append($$, $4);
		g_node_append($$, $5);
	}
;

endwhile:
	TOK_END
	{
		$$ = g_node_new("endwhile");
	}
|
	TOK_ENDWHILE
	{
		$$ = g_node_new("endwhile");
	}
;

foreach-stmt:
	TOK_FOREACH ident chk_in expr chk_to expr chk_do code endforeach
	{
		$$ = g_node_new("foreach");
		g_node_append($$, $4);
		g_node_append($$, $6);
		g_node_append($$, $8);
		g_node_append($$, $9);
	}
;

endforeach:
	TOK_END
	{
		$$ = g_node_new("endforeach");
	}
|
	TOK_ENDFOREACH
	{
		$$ = g_node_new("endforeach");
	}
;


chk_then:
	TOK_THEN | { yyerror("Missing token <then>"); YYABORT; }   error
;

chk_in:
	TOK_IN | { yyerror("Missing token <in>"); YYABORT; }   error
;

chk_to:
	TOK_ARR_TO | { yyerror("Missing token <..>"); YYABORT; }   error
;

chk_do:
	TOK_DO | { yyerror("Missing token <do>"); YYABORT; }   error
;

%%

#include <stdlib.h>

int yyerror(const char* msg)
{
	fprintf(stderr, "%s\n", msg);
}

void begin_code()
{
	fprintf(stream,
		".assembly %s {}\n"
		".method public static void Main() cil managed\n"
		"{\n"      
		"	.entrypoint\n"
		"	.maxstack %u\n"
		"	.locals init (",
		module_name,
		max_stack
	);
	guint size = g_hash_table_size(table);
	guint i;
	for (i = 0; i < size; i++) {
		if (i) {
			fprintf(stream, ", ");
		}
		fprintf(stream, "int32");
	}
	fprintf(stream, ")\n\n");
}

void produce_code(GNode * node)
{	
	if (node->data == "code") {
		produce_code(g_node_nth_child(node, 0));
		produce_code(g_node_nth_child(node, 1));
	} else if (node->data == "affect") {
		produce_code(g_node_nth_child(node, 1));
		fprintf(stream, "	stloc\t%ld\n", (long) g_node_nth_child(g_node_nth_child(node, 0), 0)->data - 1);
	} else if (node->data == "add") {
		produce_code(g_node_nth_child(node, 0));
		produce_code(g_node_nth_child(node, 1));
		fprintf(stream, "	add\n");
	} else if (node->data == "sub") {
		produce_code(g_node_nth_child(node, 0));
		produce_code(g_node_nth_child(node, 1));
		fprintf(stream, "	sub\n");
	} else if (node->data == "mul") {
		produce_code(g_node_nth_child(node, 0));
		produce_code(g_node_nth_child(node, 1));
		fprintf(stream, "	mul\n");
	} else if (node->data == "div") {
		produce_code(g_node_nth_child(node, 0));
		produce_code(g_node_nth_child(node, 1));
		fprintf(stream, "	div\n");
	} else if (node->data == "number") {
		fprintf(stream, "	ldc.i4\t%ld\n", (long)g_node_nth_child(node, 0)->data);
	} else if (node->data == "ident") {
		fprintf(stream, "	ldloc\t%ld\n", (long)g_node_nth_child(node, 0)->data - 1);
	} else if (node->data == "print") {
		produce_code(g_node_nth_child(node, 0));
		fprintf(stream, "	call void class [mscorlib]System.Console::WriteLine(int32)\n");
	} else if (node->data == "read") {
		fprintf(stream, "	call string class [mscorlib]System.Console::ReadLine()\n");
		fprintf(stream, "	call int32 int32::Parse(string)\n");
		fprintf(stream, "	stloc\t%ld\n", (long) g_node_nth_child(g_node_nth_child(node, 0), 0)->data - 1);
	} 

	/* Handle boolean_expr */
	else if (node->data == "boolexpr"){
		produce_code(g_node_nth_child(node, 0));
	}

	else if (node->data == "boolTrue"){
		fprintf(stream, " ldc.i4.1\n");
	}

	else if (node->data == "boolFalse"){
		fprintf(stream, " ldc.i4.0\n");
	}

	else if(node->data == "and"){
		produce_code(g_node_nth_child(node, 0));
		produce_code(g_node_nth_child(node, 1));
		fprintf(stream, "	and\n");
	}
	
	else if(node->data == "or"){
		produce_code(g_node_nth_child(node, 0));
		produce_code(g_node_nth_child(node, 1));
		fprintf(stream, "	or\n");
	}

	else if(node->data == "not"){
		produce_code(g_node_nth_child(node, 0)); // 'a' la valeur dans le stack
		fprintf(stream, "	ldc.i4.0\nceq\n"); // 1 si a == 0  sinon 0
	}

	else if(node->data == "eq"){
		produce_code(g_node_nth_child(node, 0));
		produce_code(g_node_nth_child(node, 1));
		fprintf(stream, "	ceq\n");
	}

	else if(node->data == "neq"){
		produce_code(g_node_nth_child(node, 0));
		produce_code(g_node_nth_child(node, 1));
		fprintf(stream, "	ceq\nldc.i4.0\nceq\n"); // litterally "equal + not"
	}

	else if(node->data == "gt"){
		produce_code(g_node_nth_child(node, 0));
		produce_code(g_node_nth_child(node, 1));
		fprintf(stream, "	cgt\n");
	}

	else if(node->data == "gte"){
		produce_code(g_node_nth_child(node, 0));
		produce_code(g_node_nth_child(node, 1));
		fprintf(stream, "	clt\nldc.i4.0\nceq\n"); // litt. "not lesser than"
	}

	else if(node->data == "lt"){
		produce_code(g_node_nth_child(node, 0));
		produce_code(g_node_nth_child(node, 1));
		fprintf(stream, "	clt\n");
	}

	else if(node->data == "lte"){
		produce_code(g_node_nth_child(node, 0));
		produce_code(g_node_nth_child(node, 1));
		fprintf(stream, "	cgt\nldc.i4.0\nceq\n"); // litt. "not greater than"
	}

	/* If statement */
	else if(node->data == "if"){
		if_offset++;

		produce_code(g_node_nth_child(node, 0)); // boolean_expr 

		// Mark the jump address
		guint endSbl = if_offset;
		fprintf(stream, "	brfalse IF_%d\n\n", endSbl);
		
		fprintf(stream, "	nop\n");
		produce_code(g_node_nth_child(node, 1)); // code wrapped with nop for catching
		fprintf(stream, "	nop\n");

		fprintf(stream, "	nop\n");
		fprintf(stream, "	br IF_END_%d\n\n", endSbl);
		
		fprintf(stream, "	IF_%d: nop\n", endSbl); // end of code, mark jump point

		produce_code(g_node_nth_child(node, 2)); // elseif
		produce_code(g_node_nth_child(node, 3)); // else 
		produce_code(g_node_nth_child(node, 4)); // endif

		fprintf(stream, "	IF_END_%d: nop\n", endSbl);
	}

	/*ElseIf statement*/
	else if(node->data == "elseif"){
		elseif_offset++;

		produce_code(g_node_nth_child(node, 0)); // boolean_expr

		// Mark the jump address
		guint endSbl = elseif_offset;
		guint ifSbl = if_offset;

		fprintf(stream, "	brfalse ELSEIF_%d\n\n", endSbl);
		
		fprintf(stream, "	nop\n");
		produce_code(g_node_nth_child(node, 1)); // code
		fprintf(stream, "	nop\n");

		fprintf(stream, "	nop\n");
		fprintf(stream, "	br IF_END_%d\n\n", ifSbl);

		fprintf(stream, "	ELSEIF_%d: nop\n", endSbl); // end of code, mark jump point
		produce_code(g_node_nth_child(node, 2)); // elseif
	}

	/* Else */
	else if(node->data == "else"){
		fprintf(stream, "	nop\n");
		produce_code(g_node_nth_child(node, 0)); // code
		fprintf(stream, "	nop\n");
	}

	/* Loop interuptor  */
	else if(node->data == "skipItr"){
		guint endSbl = loop_offset;
		fprintf(stream, "	br LOOP_INCR_%d\n\n", endSbl);
	}

	else if(node->data == "breakLoop"){
		guint endSbl = loop_offset;
		fprintf(stream, "	br LOOP_END_%d\n\n", endSbl);
	}

	/* While */	
	else if(node->data == "while"){
		loop_offset++;

		// Branch out
		guint endSbl = loop_offset;
		fprintf(stream, "	br LOOP_HEAD_%d\n", endSbl); // Init first iteration by jumping to head
		fprintf(stream, "	// Start loop (head: LOOP_HEAD_%d)\n", endSbl);
		fprintf(stream, "	LOOP_START_%d: nop\n", endSbl); // Mark beginning

		fprintf(stream, "	nop\n");
		produce_code(g_node_nth_child(node, 1)); // code
		fprintf(stream, "	nop\n");

		// Non existing counter
		fprintf(stream, "	LOOP_INCR_%d: nop\n", endSbl);

		fprintf(stream, "	LOOP_HEAD_%d: ", endSbl); // Mark head
		produce_code(g_node_nth_child(node, 0)); // boolean_expr
		fprintf(stream, "	brtrue LOOP_START_%d\n", endSbl); // jump to beginning of loop if cond

		produce_code(g_node_nth_child(node, 2)); // endwhile
		fprintf(stream, "	// End loop\n");
		fprintf(stream, "	LOOP_END_%d: nop\n", endSbl);
	}

	/* Foreach */
	else if(node->data == "foreach"){

		loop_offset++;
		guint endSbl = loop_offset;
		
		// Initialise counter variable
		fprintf(stream, "	nop\n");
		produce_code(g_node_nth_child(node, 0)); // expr
		fprintf(stream, "	stloc %d\n", endSbl);

		// Branch off - while like
		fprintf(stream, "	br LOOP_HEAD_%d\n", endSbl); // Jump to head
		fprintf(stream, "	// Start loop (head: LOOP_HEAD_%d)\n", endSbl);

		fprintf(stream, "	LOOP_START_%d: nop\n", endSbl); // Mark beginning
				
		// Procedure
		produce_code(g_node_nth_child(node, 2)); // code
		fprintf(stream, "	nop\n");

		// Increment counter
		fprintf(stream, "	LOOP_INCR_%d: ", endSbl); 
		fprintf(stream, "	nop\n");
		fprintf(stream, "	ldloc %d\n", endSbl);
		fprintf(stream, "	ldc.i4.1\n");
		fprintf(stream, "	add\n");
		fprintf(stream, "	stloc %d\n\n", endSbl); // Unload counter

		fprintf(stream, "	LOOP_HEAD_%d: ", endSbl); // Mark head
		fprintf(stream, "	ldloc %d\n", endSbl); // Reload counter
		produce_code(g_node_nth_child(node, 1)); // expr
		
		// Check condition
		fprintf(stream, "	cgt\n");
		fprintf(stream, "	ldc.i4.0\n");
		fprintf(stream, "	ceq\n");

		fprintf(stream, "	brtrue LOOP_START_%d\n", endSbl); // jump to beginning of loop if cond

		produce_code(g_node_nth_child(node, 3)); // endforeach
		fprintf(stream, "	// End loop\n");
		fprintf(stream, "	LOOP_END_%d: nop\n", endSbl);
	}
}

void end_code()
{
	fprintf(stream, "	IL_LAST: ret\n}\n");
}

int main(int argc, char *argv[])
{
	if (argc == 2) {
		char *file_name_input = argv[1];
		char *extension;
		char *directory_delimiter;
		char *basename;
		extension = rindex(file_name_input, '.');
		if (!extension || strcmp(extension, ".facile") != 0) {
			fprintf(stderr, "Input filename extension must be '.facile'\n");
			return EXIT_FAILURE;
		}
		directory_delimiter = rindex(file_name_input, '/');
		if (!directory_delimiter) {
			directory_delimiter = rindex(file_name_input, '\\');
		}
		if (directory_delimiter) {
			basename = strdup(directory_delimiter + 1);
		} else {
			basename = strdup(file_name_input);
		}
		module_name = strdup(basename);
		*rindex(module_name, '.') = '\0';
		strcpy(rindex(basename, '.'), ".il");
		char *onechar = module_name;
		if (!isalpha(*onechar) && *onechar != '_') {
			free(basename);
			fprintf(stderr, "Base input filename must start with a letter or an underscore\n");
			return EXIT_FAILURE;
		}
		onechar++;
		while (*onechar) {
			if (!isalnum(*onechar) && *onechar != '_') {
				free(basename);
				fprintf(stderr, "Base input filename cannot contains special characters\n");
				return EXIT_FAILURE;
			}
			onechar++;
		}

		/* Open the file and parse */
		if (stdin = fopen(file_name_input, "r")) {
			if (stream = fopen(basename, "w")) {
				table = g_hash_table_new_full(g_str_hash, g_str_equal, free, NULL);
				yyparse();
				g_hash_table_destroy(table);
				fclose(stream);
				fclose(stdin);
			} else {
				free(basename);
				fclose(stdin);
				fprintf(stderr, "Output filename cannot be opened\n");
				return EXIT_FAILURE;
			}
		} else {
			free(basename);
			fprintf(stderr, "Input filename cannot be opened\n");
			return EXIT_FAILURE;
		}
		free(basename);
	}

	else {
		fprintf(stderr, "No input filename given\n");
		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}

