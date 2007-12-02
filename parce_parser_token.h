
#ifndef OBJC_PARSER_TOKEN_H
#define OBJC_PARSER_TOKEN_H

/*
 *  parce: objc_parser_token.h
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


// define CUSTOM_TOKEN_TYPE at compile time as a gcc -D flag if you provide a custom token implementation; this token is a node in the abstract syntax tree
#ifndef CUSTOM_TOKEN_TYPE
struct token {
	
	int type; // corresponds to the types in the table defined by Bison for communicating with the scanner
	char *text; // the string from the input file corresponding to this token (optional)
	void *value; // user-defined value (optional); provide a freeFunction for memory release or risk leaks
	struct token *next; // next younger sibling in the list
	struct token *first; // beginning of a list of children
	
};

typedef struct token token;


/** general token lifespan function **/
extern token *tokenNew( void );

// value and firstChild are optional; text is optional (ignored, in fact) for keywords
extern token *tokenNewWithAttributes( int type, char *text, void *value, token *firstChild );
extern void tokenRelease( token *aToken ); // releases firstChild and nextSibling


/** value  **/
typedef void (*freeFunction) ( void * );
extern void tokenSetDeleteFunction ( freeFunction valueFreeFunction );


/** smart setter functions -- these release any existing tokens before replacing them **/
extern void tokenSetNextSibling( token *aToken );
extern void tokenSetFirstChild( token *aToken );
#endif

#endif /* OBJC_PARSER_TOKEN_H */