%{
	
/*

parce: objc.y

Copyright 2007 Bored Astronaut Software. All rights reserved.


Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/




#include <stdlib.h>
	
#include "parce_parser_actions.h"
%}



%token IDENTIFIER CONSTANT STRING_LITERAL NULL_VAL SIZEOF
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN TYPE_NAME

%token TYPEDEF EXTERN STATIC AUTO REGISTER
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token STRUCT UNION ENUM ELLIPSIS

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%token OBJC_STRING_LITERAL
%token OBJC_ID SELF SUPER
%token IN OUT INOUT BYCOPY BYREF ONEWAY
%token AT_CLASS AT_PROTOCOL AT_IMPLEMENTATION AT_INTERFACE AT_END
%token AT_PRIVATE AT_PROTECTED AT_PUBLIC
%token AT_TRY AT_CATCH AT_THROW AT_FINALLY
%token AT_DEFS AT_SYNCHRONIZED AT_SELECTOR AT_ENCODE

%token CLASS_NAME PROTOCOL_NAME CATEGORY_NAME



%parse-param {YYSTYPE *root}

%pure-parser

%start translation_unit
%%



/* Expressions */

primary_expression
	: identifier
	| CONSTANT { $$ = tokenCopy( yylval ); }
	| STRING_LITERAL { $$ = tokenCopy( yylval ); }
	| NULL_VAL { $$ = tokenCopy( yylval ); }
	| '(' expression ')' { $$ = gParen( $2 ); }
	| message_expression
	| selector_expression
	| protocol_expression
	| encode_expression
	;

postfix_expression
	: primary_expression
	| postfix_expression '[' expression ']' { $$ = gArray( $3 ); }
	| postfix_expression '(' ')' { $$ = gParen( NULL ); }
	| postfix_expression '(' argument_expression_list ')' { $$ = gParen( $3 ); }
	| postfix_expression '.' identifier { $$ = gDot( $1, $3 ); }
	| postfix_expression PTR_OP identifier { $$ = gPostfix( $1, tPtrOp(), $3 ); }
	| postfix_expression INC_OP { $$ = gPostfix( $1, tIncOp(), NULL ); }
	| postfix_expression DEC_OP { $$ = gPostfix( $1, tDecOp(), NULL ); }
	;

argument_expression_list
	: assignment_expression
	| argument_expression_list ',' assignment_expression { $$ = tokenListAppend( $1, tokenListAppend(tComma(), $3) ); }
	;

unary_expression
	: postfix_expression
	| INC_OP unary_expression { $$ = gPrefix( tIncOp(), $2 ); }
	| DEC_OP unary_expression { $$ = gPrefix( tDecOp(), $2 ); }
	| unary_operator cast_expression { $$ = gPrefix( $1, $2 ); }
	| SIZEOF unary_expression { $$ = gSizeofUnary( $2 ); }
	| SIZEOF '(' type_specification ')' { $$ = gSizeofType( $3 ); }
	;

unary_operator
	: '&' { $$ = tAmpOp(); }
	| '*' { $$ = tStarOp(); }
	| '+' { $$ = tAddOp(); }
	| '-' { $$ = tSubOp(); }
	| '~' { $$ = tCompOp(); }
	| '!' { $$ = tExclaimOp(); }
	;

cast_expression
	: unary_expression
	| '(' type_specification ')' cast_expression { $$ = gCast( $2, $4 ); }
	;

multiplicative_expression
	: cast_expression
	| multiplicative_expression '*' cast_expression { $$ = gBinary( $1, tStarOp(), $3 ); }
	| multiplicative_expression '/' cast_expression { $$ = gBinary( $1, tDivOp(), $3 ); }
	| multiplicative_expression '%' cast_expression { $$ = gBinary( $1, tModOp(), $3 ); }
	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' multiplicative_expression { $$ = gBinary( $1, tAddOp(), $3 ); }
	| additive_expression '-' multiplicative_expression { $$ = gBinary( $1, tSubOp(), $3 ); }
	;

shift_expression
	: additive_expression
	| shift_expression LEFT_OP additive_expression { $$ = gBinary( $1, tShiftLOp(), $3 ); }
	| shift_expression RIGHT_OP additive_expression { $$ = gBinary( $1, tShiftROp(), $3 ); }
	;

relational_expression
	: shift_expression
	| relational_expression '<' shift_expression { $$ = gBinary( $1, tLessOp(), $3 ); }
	| relational_expression '>' shift_expression { $$ = gBinary( $1, tGreaterOp(), $3 ); }
	| relational_expression LE_OP shift_expression { $$ = gBinary( $1, tLessOrEqualOp(), $3 ); }
	| relational_expression GE_OP shift_expression { $$ = gBinary( $1, tGreaterOrEqualOp(), $3 ); }
	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP relational_expression { $$ = gBinary( $1, tEqualToOp(), $3 ); }
	| equality_expression NE_OP relational_expression { $$ = gBinary( $1, tNotEqualToOp(), $3 ); }
	;

and_expression
	: equality_expression
	| and_expression '&' equality_expression { $$ = gBinary( $1, tAmpOp(), $3 ); }
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' and_expression { $$ = gBinary( $1, tXorOp(), $3 ); }
	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression '|' exclusive_or_expression { $$ = gBinary( $1, tBarOp(), $3 ); }
	;

logical_and_expression
	: inclusive_or_expression
	| logical_and_expression AND_OP inclusive_or_expression { $$ = gBinary( $1, tBooleanAndOp(), $3 ); }
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression { $$ = gBinary( $1, tBooleanOrOp(), $3 ); }
	;

conditional_expression
	: logical_or_expression
	| logical_or_expression '?' logical_or_expression ':' conditional_expression { $$ = gConditional( $1, $3, $5 ); }
	;

assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression { $$ = gAssign( $1, $2, $3 ); }
	;

assignment_operator
	: '='
	| MUL_ASSIGN { $$ = tMulAssignOp(); }
	| DIV_ASSIGN { $$ = tDivAssignOp(); }
	| MOD_ASSIGN { $$ = tModAssignOp(); }
	| ADD_ASSIGN { $$ = tAddAssignOp(); }
	| SUB_ASSIGN { $$ = tSubAssignOp(); }
	| LEFT_ASSIGN { $$ = tLeftAssignOp(); }
	| RIGHT_ASSIGN { $$ = tRightAssignOp(); }
	| AND_ASSIGN { $$ = tAndAssignOp(); }
	| XOR_ASSIGN { $$ = tXorAssignOp(); }
	| OR_ASSIGN { $$ = tOrAssignOp(); }
	;

expression
	: assignment_expression
	| expression ',' assignment_expression { $$ = tokenListAppend( $1, tokenListAppend(tComma(), $3) ); }
	;

constant_expression
	: conditional_expression
	;

// objective-c additions
message_expression
	: '[' receiver message_selector ']' { $$ = gMessage( $1, $2 ); }
	;

receiver
	: expression
	| SELF { $$ = tObjCSelf(); }
	| SUPER { $$ = tObjCSuper(); }
	| class_name
	;

message_selector
	: selector { $$ = gSelector( $1 ); }
	| keyword_argument_list { $$ = gSelector( $1 ); }
	;

keyword_argument_list
	: keyword_argument
	| keyword_argument_list keyword_argument { $$ = tokenListAppend( $1, $2 ); }
	;

keyword_argument
	: selector ':' expression { $$ = tokenListAppend( $1, tokenListAppend(tColon(), $3) ); }
	| ':' expression { $$ = tokenListAppend( $1, $2 ); }
	;

selector_expression
	: AT_SELECTOR '(' selector_name ')' { $$ = gAtSelector( $3 ); }
	;

selector_name
	: selector
	| keyword_name_list
	;

keyword_name_list
	: keyword_name
	| keyword_name_list keyword_name { $$ = tokenListAppend( $1, $2 ); }
	;

keyword_name
	: selector ':' { $$ = gSelectorKeyword( $1 ); }
	| ':' { $$ = gSelectorKeyword( NULL ); }
	;

selector
	: identifier
	;
	
protocol_expression
	: AT_PROTOCOL '(' identifier ')' { $$ = gAtProtocol( $3 ); }
	;

encode_expression
	: AT_ENCODE '(' type_name ')' { $$ = gAtEncode( $3 ); }
	;



/* Declarations */

declaration
	: declaration_specifier_list ';' { $$ = gDec( $1, NULL ); }
	| declaration_specifier_list init_declarator_list ';' { $$ = gDec( $1, $2 ); }
	;

declaration_specifier_list
	: storage_class_specifier
	| storage_class_specifier declaration_specifier_list { $$ = tokenListAppend( $1, $2 ); }
	| type_specifier
	| type_specifier declaration_specifier_list { $$ = tokenListAppend( $1, $2 ); }
	| type_qualifier
	| type_qualifier declaration_specifier_list { $$ = tokenListAppend( $1, $2 ); }
	;

init_declarator_list
	: init_declarator
	| init_declarator_list ',' init_declarator { $$ = tokenListAppend( $1, tokenListAppend(tComma(), $3) ); }
	;

init_declarator
	: type_declarator { $$ = gInitDeclarator( NULL, $1 ); }
	| type_declarator '=' initializer { $$ = gInitDeclarator( $1, $2 ); }
	;

storage_class_specifier
	: TYPEDEF { $$ = tTypedef(); }
	| EXTERN { $$ = tExtern(); }
	| STATIC { $$ = tStatic(); }
	| AUTO { $$ = tAuto(); }
	| REGISTER { $$ = tRegister(); }
	;

type_specifier
	: CHAR { $$ = tChar(); }
	| SHORT { $$ = tShort(); }
	| INT { $$ = tInt(); }
	| LONG { $$ = tLong(); }
	| SIGNED { $$ = tSigned(); }
	| UNSIGNED { $$ = tUnsigned(); }
	| FLOAT { $$ = tFloat(); }
	| DOUBLE { $$ = tDouble(); }
	| VOID { $$ = tVoid(); }
	| struct_or_union_specifier
	| enum_specifier
	| type_name { $$ = tokenCopy( yylval ); }
 // objective-c	additions
	| OBJC_ID { $$ = tObjCId(); }
	| OBJC_ID protocol_reference_list { $$ = gTypeSpec( tObjCId(), $2 ); }
	| class_name { $$ = tokenCopy( yylval ); }
	| class_name protocol_reference_list { $$ = gTypeSpec( tokenCopy( yylval ), $1 ); }
	;

struct_or_union_specifier
	: struct_or_union identifier '{' struct_declaration_list '}' { $$ = gStructOrUnionSpec( $1, $2, $4 ); }
	| struct_or_union '{' struct_declaration_list '}' { $$ = gStructOrUnionSpec( $1, NULL, $3 ); }
// objective-c additions
	| struct_or_union '{' struct_objc_defs '}' { $$ = gStructOrUnionSpec( $1, NULL, $3 ); }
	| struct_or_union identifier '{' struct_objc_defs '}' { $$ = gStructOrUnionSpec( $1, $2, $4 ); }
	| struct_or_union identifier { $$ = gStructOrUnionSpec( $1, $2, NULL ); }
	;

struct_objc_defs
	: AT_DEFS '(' class_name ')' { $$ = gStructObjCDefs( $2 ); }
	;

struct_or_union
	: STRUCT { $$ = tStruct(); }
	| UNION { $$ = tUnion(); }
	;

struct_declaration_list
	: struct_declaration
	| struct_declaration_list struct_declaration { $$ = tokenListAppend( $1, $2 ); }
	;

struct_declaration
	: specifier_qualifier_list struct_declarator_list ';' { $$ = gStructDec( $1, $2 ); }
	;

struct_declarator_list
	: struct_declarator
	| struct_declarator_list ',' struct_declarator { $$ = tokenListAppend( $1, tokenListAppend(tComma(), $3) ); }
	;

struct_declarator
	: type_declarator { $$ = gStructDeclarator( $1, NULL ); }
	| ':' constant_expression { $$ = gStructDeclarator( NULL, $2 ); }
	| type_declarator ':' constant_expression { gStructDeclarator( $1, $3 ); }
	;

specifier_qualifier_list
	: type_specifier
	| type_specifier specifier_qualifier_list { $$ = tokenListAppend( $1, $2 ); }
	| type_qualifier
	| type_qualifier specifier_qualifier_list { $$ = tokenListAppend( $1, $2 ); }
	;

enum_specifier
	: ENUM '{' enumerator_list '}' { $$ = gEnumSpec( NULL, $3 ); }
	| ENUM identifier '{' enumerator_list '}' { $$ = gEnumSpec( $2, $4 ); }
	| ENUM identifier { $$ = gEnumSpec( $2, NULL ); }
	;

enumerator_list
	: enumerator
	| enumerator_list ',' enumerator { $$ = tokenListAppend( $1, tokenListAppend(tComma(), $3) ); }
	;

enumerator
	: identifier { $$ = gEnumerator( $1, NULL ); }
	| identifier '=' constant_expression { $$ = gEnumerator( $1, $3 ); }
	;


type_qualifier
	: CONST { $$ = tConst(); }
	| VOLATILE { $$ = tVolatile(); }

// objective-c additions
	| IN { $$ = tObjCIn(); }
	| OUT { $$ = tObjCOut(); }
	| INOUT { $$ = tObjCInout(); }
	| BYCOPY { $$ = tObjCBycopy(); }
	| BYREF { $$ = tObjCByref(); }
	| ONEWAY { $$ = tObjCOneway(); }
	;

type_declarator
	: type_direct_declarator { $$ = gTypeDeclarator( NULL, $1 ); }
	| pointer type_direct_declarator { $$ = gTypeDeclarator( $1, $2 ); }
	;

type_direct_declarator
	: identifier // this should come back as a type_name in later uses
	| '(' type_declarator ')' { $$ = gListDeclarator( $2 ); }
	| type_direct_declarator '[' ']' { $$ = gArrayDeclarator( NULL ); }
	| type_direct_declarator '[' constant_expression ']' { $$ = tokenListAppend( $1, gArrayDeclarator($3) ); }
	| type_direct_declarator '(' ')' { $$ = tokenListAppend( $1, gListDeclarator(NULL) ); }
	| type_direct_declarator '(' parameter_type_list ')' { $$ = tokenListAppend( $1, gListDeclarator($3) ); }
	| type_direct_declarator '(' parameter_identifier_list ')' { $$ = tokenListAppend( $1, gListDeclarator($3) ); }
	;

pointer
	: '*' { $$ = tStarOp(); }
	| '*' type_specifier_list { $$ = tokenListAppend( tStarOp(), $2 ); }
	| '*' pointer { $$ = tokenListAppend( tStarOp(), $2); }
	| '*' type_specifier_list pointer { $$ = tokenListAppend( tokenListAppend(tStarOp(), $2), $3 ); }
	;

type_specifier_list
	: type_specifier
	| type_specifier_list type_specifier { $$ = tokenListAppend( $1, $2 ); }
	;

parameter_identifier_list
	: identifier_list
	| identifier_list ',' ELLIPSIS { $$ = tokenListAppend( $1, tokenListAppend($2, tEllipsis()) ); }
	;

identifier_list
	: identifier
	| identifier_list ',' identifier { $$ = tokenListAppend( $1, tokenListAppend(tComma(), $3) ); }
	;

parameter_type_list
	: parameter_list
	| parameter_list ',' ELLIPSIS { $$ = tokenListAppend( $1, tokenListAppend($2, tEllipsis()) ); }
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration { $$ = tokenListAppend( $1, tokenListAppend(tComma(), $3) ); }
	;

parameter_declaration
	: type_specifier_list type_declarator { $$ = gParameterDec( $1, $2 ); }
	| type_specification
	;

type_specification
	: type_specifier_list { $$ = gParameterDec( $1, NULL ); }
	| type_specifier_list abstract_declarator { $$ = gParameterDec( $1, $2 ); }
	;

abstract_declarator
	: pointer
	| abstract_declarator2
	| pointer abstract_declarator2 { $$ = tokenListAppend( $1, $2 ); }
	;

abstract_declarator2
	: '(' abstract_declarator ')' { $$ = gListDeclarator( $2 ); }
	| '[' ']' { $$ = gArrayDeclarator( NULL ); }
	| '[' constant_expression ']' { $$ = gArrayDeclarator( $2 ); }
	| abstract_declarator2 '[' ']' { $$ = tokenListAppend( $1, gArrayDeclarator(NULL) ); }
	| abstract_declarator2 '[' constant_expression ']' { $$ = tokenListAppend( $1, gArrayDeclarator($3) ); }
	| '(' ')' { $$ = gListDeclarator( NULL ); }
	| '(' parameter_type_list ')' { $$ = gListDeclarator( $2 ); }
	| abstract_declarator2 '(' ')' { $$ = tokenListAppend( $1, gListDeclarator(NULL) ); }
	| abstract_declarator2 '(' parameter_type_list ')' { $$ = tokenListAppend( $1, gListDeclarator($3) ); }
	;

initializer
	: assignment_expression
	| '{' initializer_list '}' { $$ = gStructInitializer( $2 ); }
	| '{' initializer_list ',' '}' { $$ = gStructInitializer( $2 ); }
	;

initializer_list
	: initializer
	| initializer_list ',' initializer { $$ = tokenListAppend($1, tokenListAppend(tComma(), $3) ); }
	;



/* Statements */

statement
	: open_statement
	| closed_statement
	;

open_statement
	: open_labeled_statement
	| open_if_statement
	| open_try_statement
	| open_while_statement
	| open_for_statement
	| open_synchronized_statement
	;

closed_statement
	: closed_labeled_statement
	| closed_if_statement
	| closed_try_statement
	| closed_while_statement
	| closed_for_statement
	| closed_synchronized_statement
	| compound_statement
	| expression_statement
	| switch_statement
	| do_statement
	| jump_statement
	| throw_statement
	;

open_labeled_statement
	: identifier ':' open_statement { $$ = gLabeled( $1, $3 ); }
	| CASE constant_expression ':' open_statement { $$ = gCase( $2, $4 ); }
	| DEFAULT ':' open_statement { $$ = gDefault( $3 ); }
	;

closed_labeled_statement
	: identifier ':' closed_statement { $$ = gLabeled( $1, $3 ); }
	| CASE constant_expression ':' closed_statement { $$ = gCase( $2, $4 ); }
	| DEFAULT ':' closed_statement { $$ = gDefault( $3 ); }
	;

compound_statement
	: '{' '}' { $$ = gCompound( NULL ); }
//	| '{' statement_or_declaration_list '}' { $$ = gCompound( $2 ); }
//	| '{' statement_or_declaration_list '}' { $$ = gCompoundText(/* text */); }
	| '{' statement_or_declaration_list '}' { $$ = gCompound(NULL); }
	;

statement_or_declaration_list
	: statement
	| statement statement_or_declaration_list { $$ = tokenListAppend( $1, $2 ); }
	| declaration
	| declaration statement_or_declaration_list { $$ = tokenListAppend( $1, $2 ); }
	;

declaration_list
	: declaration
	| declaration_list declaration { $$ = tokenListAppend( $1, $2 ); }
	;

expression_statement
	: ';'
	| expression ';' { $$ = gExpression( $1 ); }
	;

open_if_statement
	: IF '(' expression ')' statement { $$ = gIf( $3, $5 ); }
	| IF '(' expression ')' closed_statement ELSE open_statement { $$ = gIfElse( $3, $5, $7 ); }
	;

closed_if_statement
	: IF '(' expression ')' closed_statement ELSE closed_statement { $$ = gIfElse( $3, $5, $7 ); }
	;

open_try_statement
	: AT_TRY closed_statement AT_CATCH '(' init_declarator ')' statement { $$ = gTry ($2, $5, $7, NULL); }
	| AT_TRY closed_statement AT_CATCH '(' init_declarator ')' closed_statement AT_FINALLY open_statement { $$ = gTry ($2, $5, $7, $9); }
	;

closed_try_statement
	: AT_TRY closed_statement AT_CATCH '(' init_declarator ')' closed_statement AT_FINALLY closed_statement { $$ = gTry ($2, $5, $7, $9); }
	;

open_synchronized_statement
	: AT_SYNCHRONIZED '(' identifier ')' open_statement { $$ = gSynch( $3, $5 ); }
	;

closed_synchronized_statement
	: AT_SYNCHRONIZED '(' identifier ')' closed_statement { $$ = gSynch( $3, $5 ); }
	;

switch_statement
	: SWITCH '(' expression ')' compound_statement { $$ = gSwitch( $3, $5 ); }
	;

open_while_statement
	: WHILE '(' expression ')' open_statement { $$ = gWhile( $3, $5 ); }
	;

closed_while_statement
	: WHILE '(' expression ')' closed_statement { $$ = gWhile( $3, $5 ); }
	;

do_statement
	: DO statement WHILE '(' expression ')' ';' { $$ = gDo( $2, $5 ); }
	;

open_for_statement
	: for_prefix open_statement { tokenSetFirstChild( $1, $2 ); }
	;

closed_for_statement
	: for_prefix closed_statement { tokenSetFirstChild( $1, $2 ); }
	;

for_prefix
	: FOR '(' ';' ';' ')' { $$ = gFor( NULL, NULL, NULL, NULL ); }
	| FOR '(' ';' ';' expression ')' { $$ = gFor( NULL, NULL, $5, NULL ); }
	| FOR '(' ';' expression ';' ')' { $$ = gFor( NULL, $4, NULL, NULL ); }
	| FOR '(' ';' expression ';' expression ')' { $$ = gFor( NULL, $4, $6, NULL ); }
	| FOR '(' expression ';' ';' ')' { $$ = gFor( $3, NULL, NULL, NULL ); }
	| FOR '(' expression ';' ';' expression ')' { $$ = gFor( $3, NULL, $6, NULL ); }
	| FOR '(' expression ';' expression ';' ')' { $$ = gFor( $3, $5, NULL, NULL ); }
	| FOR '(' expression ';' expression ';' expression ')' { $$ = gFor( $3, $5, $7, NULL ); }
	;

jump_statement
	: GOTO identifier ';' { $$ = gGoto( $2 ); }
	| CONTINUE ';' { $$ == tContinue(); }
	| BREAK ';' { $$ == tBreak(); }
	| RETURN ';' { $$ = gReturn( NULL ); }
	| RETURN expression ';' { $$ = gReturn( $2 ); }
	;

throw_statement
	: AT_THROW '(' identifier ')' { $$ = gThrow( gParen( $3 ) ); }
	| AT_THROW identifier { $$ = gThrow( $2 ); }
	;



/* Definitions */

translation_unit
	: external_definition { *root = $$ = gTranslationUnit($1); }
	| translation_unit external_definition { $$ = tokenListAppend( tokenFirstChild($1), $2 ); }
	;

external_definition // default rule
	: declaration
	| function_definition

// objective-c additions
	| class_declaration_list
	| protocol_declaration_list
	| class_interface
	| category_interface
	| protocol_declaration
	| class_implementation
	| category_implementation
	;

function_definition
	: type_declarator function_body { $$ = gFunctionDef( NULL, $1, $2 ); }
	| declaration_specifier_list type_declarator function_body { $$ = gFunctionDef( $1, $2, $3 ); }
	;

function_body
	: compound_statement { $$ = gFunctionBody( NULL, $1 ); }
	| declaration_list compound_statement { $$ = gFunctionBody( $1, $2 ); }
	;

// objective-c additions
class_declaration_list
	// the identifiers become class_names
	: AT_CLASS identifier_list ';' { $$ = gClassNameDecs( $2 ); }
	;

protocol_declaration_list
	// the identifiers become protocol_names
	: AT_PROTOCOL identifier_list ';' { $$ = gProtocolNameDecs( $2 ); }
	;

class_interface
	// the identifier becomes the class_name; the class_name is the superclass name
	: AT_INTERFACE identifier ':' class_name protocol_reference_list instance_variables interface_declaration_list AT_END {
		$$ = gClassInterface( $2, $4, $5, $6, $7 );
	}
	| AT_INTERFACE identifier ':' class_name protocol_reference_list instance_variables AT_END {
		$$ = gClassInterface( $2, $4, $5, $6, NULL );
	}
	| AT_INTERFACE identifier ':' class_name protocol_reference_list interface_declaration_list AT_END {
		$$ = gClassInterface( $2, $4, $5, NULL, $6 );
	}

	| AT_INTERFACE identifier ':' class_name protocol_reference_list AT_END {
		$$ = gClassInterface( $2, $4, $5, NULL, NULL );
	}

	| AT_INTERFACE identifier ':' class_name instance_variables interface_declaration_list AT_END {
		$$ = gClassInterface( $2, $4, NULL, $5, $6 );
	}
	
	| AT_INTERFACE identifier ':' class_name instance_variables AT_END {
		$$ = gClassInterface( $2, $4, NULL, $5, NULL );
	}
	
	| AT_INTERFACE identifier ':' class_name interface_declaration_list AT_END {
		$$ = gClassInterface( $2, $4, NULL, NULL, $5 );
	}

	| AT_INTERFACE identifier ':' class_name AT_END {
		$$ = gClassInterface( $2, $4, NULL, NULL, NULL );
	}

	| AT_INTERFACE identifier protocol_reference_list instance_variables interface_declaration_list AT_END {
		$$ = gClassInterface( $2, NULL, $3, $4, $5 );
	}

	| AT_INTERFACE identifier protocol_reference_list instance_variables AT_END {
		$$ = gClassInterface( $2, NULL, $3, $4, NULL );
	}

	| AT_INTERFACE identifier protocol_reference_list interface_declaration_list AT_END {
		$$ = gClassInterface( $2, NULL, $3, NULL, $4 );
	}
	
	| AT_INTERFACE identifier protocol_reference_list AT_END {
		$$ = gClassInterface( $2, NULL, $3, NULL, NULL );
	}
	
	| AT_INTERFACE identifier instance_variables interface_declaration_list AT_END {
		$$ = gClassInterface( $2, NULL, NULL, $3, $4 );
	}

	| AT_INTERFACE identifier instance_variables AT_END {
		$$ = gClassInterface( $2, NULL, NULL, $3, NULL );
	}

	| AT_INTERFACE identifier interface_declaration_list AT_END {
		$$ = gClassInterface( $2, NULL, NULL, NULL, $3 );
	}
	
	| AT_INTERFACE identifier AT_END {
		$$ = gClassInterface( $2, NULL, NULL, NULL, NULL );
	}
	;

class_implementation
	: AT_IMPLEMENTATION class_name AT_END { $$ = gClassImplementation( $2, NULL ); }
	| AT_IMPLEMENTATION class_name implementation_definition_list AT_END { $$ = gClassImplementation( $2, $3 ); }
	;

category_interface
	// the identifier becomes a category_name
	: AT_INTERFACE class_name '(' identifier ')' protocol_reference_list interface_declaration_list AT_END { $$ = gCategoryInterface( $2, $4, $6, $7 ); }
	| AT_INTERFACE class_name '(' identifier ')' interface_declaration_list AT_END { $$ = gCategoryInterface( $2, $4, $6, $7 ); }
	;

category_implementation
	: AT_IMPLEMENTATION class_name '(' category_name ')' implementation_definition_list AT_END { $$ = gCategoryImplementation( $2, $4, $5 ); }
	;

protocol_declaration
	// the identifier becomes a protocol_name
	: AT_PROTOCOL identifier protocol_reference_list interface_declaration_list AT_END { $$ = gProtocolDec( $2, $3, $4 ); }
	;

protocol_reference_list
	: '<' protocol_list '>' { $$ = gProtocolRefs( $2 ); }
	;

protocol_list
	: protocol_name
	| protocol_list protocol_name { $$ = tokenListAppend( $1, $2 ); }
	;

instance_variables
	: '{' instance_variable_declaration_list '}' { $$ = gInstanceVariables( $2 ); }
	;

instance_variable_declaration_list
	: visibility_specification
	| struct_declaration
	| instance_variable_declaration_list visibility_specification { $$ = tokenListAppend( $1, $2 ); }
	| instance_variable_declaration_list struct_declaration { $$ = tokenListAppend( $1, $2 ); }
	;

visibility_specification
	: AT_PRIVATE
	| AT_PROTECTED
	| AT_PUBLIC
	;

interface_declaration_list
	: declaration
	| method_declaration
	| interface_declaration_list declaration { $$ = tokenListAppend( $1, $2 ); }
	| interface_declaration_list method_declaration { $$ = tokenListAppend( $1, $2 ); }
	;

method_declaration
	: class_method_declaration
	| instance_method_declaration
	;

class_method_declaration
	: '+' method_selector ';' { $$ = gClassMethodDec( NULL, $2 ); }
	| '+' '(' type_specifier ')' method_selector ';' { $$ = gClassMethodDec( $3, $5 ); }
	;

instance_method_declaration
	: '-' method_selector ';' { $$ = gInstanceMethodDec( NULL, $2 ); }
	| '-' '(' type_specifier ')' method_selector ';' { $$ = gInstanceMethodDec( $3, $5 ); }
	;

implementation_definition_list
	: function_definition
	| declaration
	| method_definition
	| implementation_definition_list function_definition { $$ = tokenListAppend( $1, $2 ); }
	| implementation_definition_list declaration { $$ = tokenListAppend( $1, $2 ); }
	| implementation_definition_list method_definition { $$ = tokenListAppend( $1, $2 ); }
	;

method_definition
	: class_method_definition
	| instance_method_definition
	;

class_method_definition
	: '+' method_selector declaration_list compound_statement { $$ = gClassMethodDef( NULL, $2, $3, $4 ); }
	| '+' '(' type_specifier ')' method_selector declaration_list compound_statement { $$ = gClassMethodDef( $3, $5, $6, $7 ); }
	;

instance_method_definition
	: '-' method_selector declaration_list compound_statement { $$ = gInstanceMethodDef( NULL, $2, $3, $4 ); }
	| '-' '(' type_specifier ')' method_selector declaration_list compound_statement { $$ = gInstanceMethodDef( $3, $5, $6, $7 ); }
	;

method_selector
	: unary_selector
	| keyword_selector
	| keyword_selector ',' ELLIPSIS { $$ = tokenListAppend( $1, tokenListAppend(tComma(), $3) ); }
//	| keyword_selector ',' parameter_type_list // ambiguity: and who ever uses this form?
	;

unary_selector
	: identifier
	;

keyword_selector
	: keyword_declarator
	| keyword_selector keyword_declarator { $$ = tokenListAppend( $1, $2 ); }
	;
	
keyword_declarator
	: ':' identifier { $$ = tokenListAppend( $1, $2 ); }
	| ':' '(' type_specifier ')' identifier {
		$$ = tokenListAppend( $1, tokenListAppend($3, $5) );
	}
	| identifier ':' identifier {
		$$ = tokenListAppend( $1, tokenListAppend($2, $3) );
	}
	| identifier ':' '(' type_specifier ')' identifier {
		$$ = tokenListAppend( $1, tokenListAppend($2, tokenListAppend( $4, $6)) );
	}
	;


/* Identifiers */

identifier
	: IDENTIFIER { $$ = tokenCopy( yylval ); }
	;

type_name
	: TYPE_NAME { $$ = tokenCopy( yylval ); }
	;

class_name
	: CLASS_NAME { $$ = tokenCopy( yylval ); }
	;

protocol_name
	: CATEGORY_NAME { $$ = tokenCopy( yylval ); }
	;
	
category_name
	: CATEGORY_NAME { $$ = tokenCopy( yylval ); }
	;
	
%%


int yyerror(char *s) {
	return 0;
}

int yywrap( int val ) {
	return 0;
}