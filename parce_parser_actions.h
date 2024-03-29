
#ifndef OBJC_PARSER_ACTIONS_H
#define OBJC_PARSER_ACTIONS_H
/*
 *  parce: objc_parser_semantic.h
 *
 *  Copyright 2007 Bored Astronaut Software. All rights reserved.

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


// provide your own token implementation
#include "parce_parser_token.h"
#include "parce_parser.h"


enum {
	LIST = CATEGORY_NAME + 1,
	TRANSLATION_UNIT,
	DECLARATION,
	INIT_DECLARATOR,
	FUNCTION_DEF,
	FUNCTION_BODY,
	STRUCT_SPEC,
	UNION_SPEC,
	ENUM_SPEC,
	STRUCT_DEC,
	STRUCT_DECLARATOR,
	ENUMERATOR,
	TYPE_DECLARATOR,
	ARRAY_DECLARATOR,
	LIST_DECLARATOR,
	PARAMETER_DEC,
	STRUCT_INIT,
	STRUCT_OBJC_DEFS,
	CLASS_NAMES,
	PROTOCOL_NAMES,
	PROTOCOL_REFS,
	CLASS_IVARS,
	CLASS_INTERFACE,
	CATEGORY_INTERFACE,
	PROTOCOL_INTERFACE,
	CLASS_IMP,
	CATEGORY_IMP,
	CLASS_METHOD_DEC,
	INSTANCE_METHOD_DEC,
	TYPE_SPEC,
	STMT_COMPOUND,
	STMT_IF,
	STMT_WHILE,
	STMT_FOR,
	STMT_DO,
	STMT_SWITCH,
	STMT_JUMP,
	STMT_LABELED,
	STMT_TRY,
	STMT_SYNC,
	STMT_THROW,
	STMT_EXPRESSION,
	EXPR_POSTFIX,
	EXPR_PREFIX,
//	EXPR_ARRAY,
//	EXPR_PAREN,
	EXPR_DOT,
	EXPR_BINARY,
	EXPR_CAST,
	EXPR_ASSIGN,
	EXRP_CONDITIONAL,
	EXPR_MESSAGE,
	EXPR_RECEIVER,
	EXPR_SELECTOR,
	EXPR_AT_SELECTOR,
	EXPR_AT_PROTOCOL,
	EXPR_AT_ENCODE
};


extern token *tokenNextSibling( token *aToken );
extern token *tokenFirstChild( token *aToken );

extern token *tokenSetNextSibling( token *aToken, token *next );
extern token *tokenSetFirstChild( token *aToken, token *first );

extern token *tokenCopy( token *original );
extern token *tokenListAppend( token *list, token *last );


/** specialized token creation functions for terminal symbols **/

/* mutli-character operators */
extern token *tPtrOp( void );            // ->  also known as a "selection" operator ... equivalent to (*struct).member

extern token *tIncOp( void );            // ++
extern token *tDecOp( void );            // --

extern token *tBooleanAndOp( void );     // &&
extern token *tBooleanOrOp( void );      // ||
extern token *tEqualToOp( void );        // ==
extern token *tLessOrEqualOp( void );    // <=
extern token *tGreaterOrEqualOp( void ); // >=
extern token *tNotEqualToOp( void );     // !=

extern token *tShiftLOp( void );         // <<
extern token *tShiftROp( void );         // >>

extern token *tMulAssignOp( void );     // *=
extern token *tDivAssignOp( void );      // /=
extern token *tModAssignOp( void );      // %=
extern token *tAddAssignOp( void );      // +=
extern token *tSubAssignOp( void );      // -=

extern token *tLeftAssignOp( void );     // <<=
extern token *tRightAssignOp( void );    // >>=
extern token *tAndAssignOp( void );      // &=
extern token *tXorAssignOp( void );      // ^=
extern token *tOrAssignOp( void );       // |=

/* multi-purpose operators */
extern token *tStarOp( void );           // *  "multiply" and "pointer dereference"
extern token *tAmpOp( void );            //  bitwise AND and "address of"
extern token *tExclaimOp( void );         // !  bitwise negation and boolean negation
extern token *tBarOp( void );            // |  bitwise OR and boolean OR
extern token *tSubOp( void );            // -  arithmetic minus and arithmetic negation

/* arithmetic operators */
extern token *tAddOp( void );            // +
extern token *tDivOp( void );            // /
extern token *tModOp( void );            // %

/* boolean operators */
extern token *tLessOp( void );           // < // FIXME: rename to tAngleL() ?
extern token *tGreaterOp( void );        // > // FIXME: rename to tAngleR() ?

/* bitwise operators */
extern token *tXorOp( void );            // ^
extern token *tCompOp( void );           // ~ (complement)

/* other single character operators */
extern token *tAssignOp( void );         // =
extern token *tDotOp( void );            // .

/* braces/parentheses */
extern token *tCurlyL( void );           // {
extern token *tCurlyR( void );           // }
extern token *tSquareL( void );          // [
extern token *tSquareR( void );          // ]
extern token *tParenL( void );           // (
extern token *tParenR( void );           // )

/* punctuation marks */
extern token *tComma( void );            // ,
extern token *tColon( void );            // :
extern token *tSemi( void );             // ;
extern token *tQuest( void );            // ? - an operator only when combined with ':' correctly

/* built in types */
extern token *tChar( void );           // char
extern token *tShort( void );          // short
extern token *tInt( void );            // int
extern token *tLong( void );           // long
extern token *tSigned( void );         // signed
extern token *tUnsigned( void );       // unsigned
extern token *tFloat( void );          // float
extern token *tDouble( void );         // double
extern token *tConst( void );          // const
extern token *tVolatile( void );       // volatile
extern token *tVoid( void );           // void

/* reserved words */
extern token *tExtern( void );         // extern
extern token *tStatic( void );         // static
extern token *tAuto( void );           // auto
extern token *tRegister( void );       // register

extern token *tSizeof( void );         // sizeof

/* user defined type creation */
extern token *tTypedef( void );        // typedef
extern token *tStruct( void );         // struct
extern token *tUnion( void );          // union
extern token *tEnum( void );           // enum

extern token *tEllipsis( void );       // ...

/* control flow */
extern token *tIf( void );             // if
extern token *tElse( void );           // else
extern token *tSwitch( void );         // switch
extern token *tCase( void );           // case
extern token *tDefault( void );        // default
extern token *tWhile( void );          // while
extern token *tDo( void );             // do
extern token *tFor( void );            // for
extern token *tGoto( void );           // goto
extern token *tContinue( void );       // continue
extern token *tBreak( void );          // break
extern token *tReturn( void );         // return

/* comments */
extern token *tBlockComment( void );   // /* ... */  FIXME: no token defined yet
extern token *tInLineComment( void );  // // very ... self-referential   FIXME: no token defined yet
extern token *tConstant( char *text );
extern token *tStringLiteral( char *text );


#pragma mark objective-c extensions
extern token *tObjCId( void );                // id
extern token *tObjCSelf( void );              // self
extern token *tObjCSuper( void );             // super
extern token *tObjCIn( void );                // in
extern token *tObjCOut( void );               // out
extern token *tObjCInout( void );             // inout
extern token *tObjCBycopy( void );            // bycopy
extern token *tObjCByref( void );             // byref
extern token *tObjCOneway( void );            // oneway

extern token *tObjCAtClass( void );           // @class
extern token *tObjCAtProtocol( void );        // @protocol
extern token *tObjCAtInterface( void );       // @interface
extern token *tObjCAtImplementation( void );  // @implementation
extern token *tObjCAtEnd( void );             // @end

extern token *tObjCAtPrivate( void );         // @private
extern token *tObjCAtPublic( void );          // @public
extern token *tObjCAtProtected( void );       // @protected

extern token *tObjCAtTry( void );             // @try
extern token *tObjCAtCatch( void );           // @catch
extern token *tObjCAtFinally( void );         // @finally
extern token *tObjCThrow( void );             // @throw

extern token *tObjCAtDefs( void );            // @defs
extern token *tObjCAtSynchronized( void );    // @synchronized
extern token *tObjCAtSelector( void );        // @selector
extern token *tObjCAtEncode( void );          // @encode

extern token *tObjCString( char * );            // @"string" -- '@' and quotation marks are not removed


/** specialized token creation functions for groups (nonterminal symbols) - groups have children; terminals do not **/

#pragma mark Generic List
extern token *gList( token *first );

/*
 
 Notes:
 
 short forms
 
 - "Spec" is short for specifier
 - "Dec" is short for declaration
 - "Qual" is short for qualifier
 - "Expr" is short for expression
 - plural means the head of list, returning from a recursive descent call sequence
 */


#pragma mark external definitions
extern token *gTranslationUnit( token *externalDef );
extern token *gDec( token *decSpecs, token *initDeclarators ); // initDeclarators may be NULL


/* declarations */

/* declarators (??) */
extern token *gInitDeclarator( token *typeDeclarator, token *initializer );

/* declaration specifiers */
// gStorageClassSpecifier // default rule
// gTypeSpec // default rule for C, but see objective-c
// gTypeQualifier // default rule


/* functions */
extern token *gFunctionDef (token *decSpecs, token *typeDec, token *body ); // decSpecs may be NULL
extern token *gFunctionBody ( token *decs, token *compoundStatement ); // decs may be NULL

/* type specifiers */
extern token *gStructOrUnionSpec( token *structOrUnion, token *name, token *structDecs ); // name or structDecs may be NULL (but not both)
extern token *gEnumSpec( token *name, token *enumerators ); // name or enumerators may be NULL (but not both).

/* structure/union elements */
extern token *gStructDec( token *specQuals, token *declarators );
extern token *gStructDeclarator( token *typeDeclarator, token *initValue ); // type declarator or initValue may be null (but not both)

/* enumeration elements */
extern token *gEnumerator( token *name, token *initValue ); // initValue may be NULL

/* type declarations */
extern token *gTypeDeclarator( token *pointer, token *declarators ); // pointer may be NULL, or a list
extern token *gArrayDeclarator( token *length ); // '[' length ']' length may be NULL
extern token *gListDeclarator( token *parameters ); // '(' parameters ')' parameters may be NULL, or a list of types or a list of identifiers; either list may end in an ellipsis
extern token *gParameterDec( token *specs, token *declarator ); // declarator is a typeDeclarator or an abstractDeclarator, or may be NULL

extern token *gPointer( token *elements );

extern token *gStructInitializer( token *assignmentExpr );


/** Statements **/
extern token *gCompound( token *stmtsAndDecs );

extern token *gIf( token *test, token *trueStmt );
extern token *gIfElse( token *test, token *trueStmt, token *falseStmt );
extern token *gWhile( token *test, token *stmt );
extern token *gFor( token *init, token *test, token *inc, token *stmt );
extern token *gDo( token *stmt, token *test);
extern token *gSwitch( token *test, token *compoundStmt );
extern token *gGoto( token *identifier );
extern token *gReturn( token *expr );
extern token *gLabeled( token *identifier, token *stmt );
extern token *gCase( token *constant, token *stmt );
extern token *gDefault( token *stmt );
extern token *gExpression( token *expr );

/* objc */
extern token *gTry( token *tryBlock, token *catchInitDecl, token *catchBlock, token *finBlock );
extern token *gSynch( token *identifier, token *stmt );
extern token *gThrow( token *identifier );

/** Expressions **/
extern token *gPostfix( token *expr, token *op, token *member ); // member may be NULL
extern token *gPrefix( token *op, token *expr);
extern token *gArray( token *expr );
extern token *gParen( token *expr );
extern token *gDot( token *expr, token *ident );
extern token *gBinary( token *left, token *op, token *right);
extern token *gCast( token *typeSpec, token *expr );
extern token *gAssign( token *left, token *op, token *right );
extern token *gConditional( token *logical, token *trueExpr, token *falseExpr );

extern token *gSizeofUnary( token *unary );
extern token *gSizeofType( token *typeSpec );


/** Objective-C **/
/* expressions */
extern token *gMessage( token *receiver, token *message );
extern token *gAtSelector( token *name );
extern token *gSelector( token *keysWordsAndArgs );
extern token *gSelectorKeyword( token *identifier );
extern token *gAtProtocol( token *identifier );
extern token *gAtEncode( token *typeName );

/* external definitions */
extern token *gClassNameDecs( token *identifiers );
extern token *gProtocolNameDecs( token *identifiers );

extern token *gProtocolRefs( token *identifiers );
extern token *gInstanceVariables( token *members );

extern token *gClassInterface( token *className, token *superClassName, token *protocolRefs, token *ivars, token *interfaceDecs ); // any or all of superClassName, protocolRefs, ivars or interfaceDecs may be NULL
extern token *gCategoryInterface( token *className, token *categoryName, token *protocolRefs, token *interfaceDecs );
extern token *gProtocolDec( token *protocolName, token *protocolRefs, token *interfaceDecs );

extern token *gClassImplementation(token *className, token *methodDefs );
extern token *gCategoryImplementation( token *className, token *categoryName, token *methodDefs );

extern token *gClassMethodDec( token *returnType, token *selector );
extern token *gInstanceMethodDec( token *returnType, token *selector );

extern token *gClassMethodDef( token *returnType, token *selector, token *decs, token *compoundStmt );
extern token *gInstanceMethodDef( token *returnType, token *selector, token *decs, token *compoundStmt );

/* type specifiers */
extern token *gTypeSpec( token *typeSpec, token *protocolRefs ); // type is either OBJC_ID or CLASS_NAME; protocolRefs is a list of protocol names

extern token *gStructObjCDefs( token *className );

#endif /* OBJC_PARSER_ACTIONS_H */