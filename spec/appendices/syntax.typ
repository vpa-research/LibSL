#import "../meta.typ": *
#import "../railroad.typ": railroad

= Синтаксис отдельных конструкций

В данном приложении приведены грамматика и соответствующие синтаксические диаграммы отдельных синтаксических конструкций языка.

== Целочисленные литералы <int-lit-syntax>

```antlr
IntegerLit
    :   DecimalIntegerLit
    |   HexIntegerLit
    |   OctalIntegerLit
    |   BinaryIntegerLit
    ;

fragment DecimalIntegerLit
    :   DecimalNumeral IntegerTypeSuffix?
    ;

fragment HexIntegerLit
    :   HexNumeral IntegerTypeSuffix?
    ;

fragment OctalIntegerLit
    :   OctalNumeral IntegerTypeSuffix?
    ;

fragment BinaryIntegerLit
    :   BinaryNumeral IntegerTypeSuffix?
    ;

fragment DecimalNumeral
    :   '0'
    |   NonZeroDigit (Digits?)
    ;

fragment IntegerTypeSuffix
    :   [lLxsu]
    |   'ux'
    |   'us'
    |   'uL'
    ;

fragment Digits
    :   Digit+
    ;

Digit
    :   [0-9]
    ;

fragment NonZeroDigit
    :   [1-9]
    ;

fragment Hex
    :   Digit
    |   [a-fA-F]
    ;

fragment HexNumeral
    :   '0' [xX] Hex+
    ;

fragment OctalNumeral
    :   '0' OctalDigit+
    ;

fragment OctalDigit
    :   [0-7]
    ;

fragment BinaryNumeral
    :   '0' [bB] BinaryDigit+
    ;

fragment BinaryDigit
    :   [01]
    ;
```

== Синтаксис вещественных литералов <float-lit-syntax>

```antlr
FloatLit
    :   DecimalFloatLit
    ;

fragment DecimalFloatLit
    :   Digits '.' Digits? ExponentPart? FloatTypeSuffix?
    |   Digits ExponentPart FloatTypeSuffix?
    |   Digits FloatTypeSuffix
    ;

fragment ExponentPart
    :   ExponentIndicator SignedInteger
    ;

fragment ExponentIndicator
    :   [eE]
    ;

fragment SignedInteger
    :   Sign? Digits
    ;

fragment Sign
    :   [+-]
    ;

fragment FloatTypeSuffix
    :   [fFdD]
    ;
```

== Синтаксис символьных литералов <char-lit-syntax>

```antlr
CharacterLit
    :   '\'' SingleCharacter '\''
    |   '\'' EscapeSequence '\''
    ;

fragment SingleCharacter
    :   ~['\\\r\n]
    ;

fragment EscapeSequence
    :   '\\' [btnfr"'\\]
    |   UnicodeEscape
    |   OctalEscape
    ;

fragment UnicodeEscape
    :   '\\' 'u'+ Hex Hex Hex Hex
    ;

fragment OctalEscape
    :   '\\' OctalDigit
    |   '\\' OctalDigit OctalDigit
    |   '\\' ZeroToThree OctalDigit OctalDigit
    ;

fragment ZeroToThree
    :   [0-3]
    ;
```

== Синтаксис функций <fun-syntax>

Синтаксис @def:function-decl[объявления функции]:

```antlr
functionDecl
    :   annotations+=annotation*
        modifiers+=functionModifier*
        FUN
        (extensionFor=fullName DOT)?
        method=methodSpec?
        name=ident
        typeParams=generics?
        L_PAREN (params=functionParamList COMMA?)? R_PAREN
        (COLON retType=typeExpr)?
        typeConstraints=whereClause?
        def=functionDef
    ;

functionModifier
    :   STATIC # FunctionModifierStatic
    ;

methodSpec
    :   ASTERISK DOT
    ;

functionParamList
    :   params+=functionParam
        (COMMA params+=functionParam)*
    ;

functionParam
    :   annotations+=annotation*
        name=ident
        COLON type=typeExpr
    ;

functionDef
    :   L_BRACE body=functionBody R_BRACE # FunctionDefBraced
    |   SEMICOLON? # FunctionDefSemicolon
    ;
```

#metadata((
  railroad(
    ```
    {
      [
        `function-decl`
        ['annotation'*[]]?
      ],
      [
        [
          'function-modifier'*[]
        ]?
        "fun"
        [
          'full-name'
          "."
        ]?#`extension specifier`
        [
          "*"
          "."
        ]?#`method specifier`
        'ident'
      ],
      [
        'generics'?
        "("
        [
          'function-param'*","
          ","?
        ]?
        ")"
        [
          ":"
          'type-expr'
        ]?#`return type`
      ],
      'where-clause'?,
      <
        ["{" 'function-body' "}"],
        ";"?
      >
    }
    ```,
  ),

  railroad(
    ```
    [
      `function-modifier`
      <
        "static"
      >
    ]
    ```,
  ),

  railroad(
    ```
    [
      `function-param`
      ['annotation'*[]]?
      'ident'
      ":"
      'type-expr'
    ]
    ```,
  ),
)) <fun-syntax-railroad>

#align(center)[
  #context query(<fun-syntax-railroad>).at(0).value.join(parbreak())
]

== Синтаксис выражений <expr-syntax>

Синтаксис @def:expr[выражений]:

```antlr
expr
    :   L_PAREN inner=expr R_PAREN # ExprParen
    |   lit=primitiveLit # ExprPrimitiveLit
    |   arrayLitExpr # ExprArrayLit
    |   setLitExpr # ExprSetLit
    |   name=ident typeArgs=typeArgSpec? L_PAREN (args=exprList COMMA?)? R_PAREN # ExprProcCallUnqualified
    |   actionCallExpr # ExprActionCall
    |   instantiationExpr # ExprInstantiation
    |   name=ident # ExprName
    |   base=expr QUOTE # ExprPrev
    |   base=expr DOT name=ident typeArgs=typeArgSpec? L_PAREN (args=exprList COMMA?)? R_PAREN # ExprProcCallQualified
    |   base=expr DOT field=ident # ExprField
    |   base=expr DOT ASTERISK # ExprDeref
    |   base=expr L_BRACKET index=expr R_BRACKET # ExprIndex
    |   op=unOp rhs=expr # ExprUnary
    |   lhs=expr not=BANG? HAS concept=ident # ExprHasConcept
    |   lhs=expr not=BANG? IS type=typeExpr # ExprTypeComparison
    |   lhs=expr AS type=typeExpr # ExprCast
    |   lhs=expr op=mulBinOp rhs=expr # ExprMultiplicative
    |   lhs=expr op=addBinOp rhs=expr # ExprAdditive
    |   lhs=expr op=bitShiftOp rhs=expr # ExprShift
    |   lhs=expr AMP rhs=expr # ExprBitAnd
    |   lhs=expr CARET rhs=expr # ExprBitXor
    |   lhs=expr PIPE rhs=expr # ExprBitOr
    |   lhs=expr op=relOp rhs=expr # ExprRelational
    |   lhs=expr AMP_AMP rhs=expr # ExprAnd
    |   lhs=expr PIPE_PIPE rhs=expr # ExprOr
    ;
```

#align(center, railroad(
  ```
  [
    `expr`
    <
      ["(" 'expr' ")"],
      'primitive-lit-expr',
      'array-lit-expr',
      'set-lit-expr',
      'call-expr',
      'action-call-expr',
      'instantiation-expr',
      'name-expr',
      'prev-expr',
      'field-expr',
      'deref-expr',
      'index-expr',
      'unary-expr',
      'has-concept-expr',
      'type-comparison-expr',
      'cast-expr',
      'binary-expr'
    >
  ]
  ```,
))

=== Синтаксис бинарных операторных выражений <binary-expr-syntax>

Синтаксис @def:binary-expr[бинарных операторных выражений]:

```antlr
expr:
    ...
    |   lhs=expr op=mulBinOp rhs=expr # ExprMultiplicative
    |   lhs=expr op=addBinOp rhs=expr # ExprAdditive
    |   lhs=expr op=bitShiftOp rhs=expr # ExprShift
    |   lhs=expr AMP rhs=expr # ExprBitAnd
    |   lhs=expr CARET rhs=expr # ExprBitXor
    |   lhs=expr PIPE rhs=expr # ExprBitOr
    |   lhs=expr op=relOp rhs=expr # ExprRelational
    |   lhs=expr AMP_AMP rhs=expr # ExprAnd
    |   lhs=expr PIPE_PIPE rhs=expr # ExprOr
    ...
```

#align(center, railroad(
  ```
  [
    `binary-expr`
    <
      ['expr' "*" 'expr'],
      ['expr' "/" 'expr'],
      ['expr' "%" 'expr'],
      ['expr' "+" 'expr'],
      ['expr' "-" 'expr'],
      ['expr' "<<<" 'expr'],
      ['expr' ">>>" 'expr'],
      ['expr' "<<" 'expr'],
      ['expr' ">>" 'expr'],
      ['expr' "&" 'expr'],
      ['expr' "^" 'expr'],
      ['expr' "|" 'expr'],
      ['expr' "<=" 'expr'],
      ['expr' ">=" 'expr'],
      ['expr' "<" 'expr'],
      ['expr' ">" 'expr'],
      ['expr' "==" 'expr'],
      ['expr' "!=" 'expr'],
      ['expr' <!, "!"> "in" 'expr']
    >
  ]
  ```,
))
