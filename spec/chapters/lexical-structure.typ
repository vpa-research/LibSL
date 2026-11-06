#import "../meta.typ": *
#import "../railroad.typ": railroad
#import "../types.typ": builtin-types, type-expr

#rule-h(<lex>)
= Лексическая структура

#rule(<lex.source-file>)
#def("source-file")[Исходный файл] — последовательность символов Unicode.
#def("character")[Символ исходного файла][Символом] считается один Unicode scalar value#footnote[https://www.unicode.org/glossary/#unicode_scalar_value] в кодировке UTF-8.

#note[
  #let korean(body) = {
    set text(2em)
    align(center, body)
  }

  Понимание символа в данной спецификации может отличаться от привычного.
  Пример:
  
  #korean[훯]

  Этот корейский слог является одним символом с точки зрения корейского языка, однако его представление в Unicode в данном случае использует 3 @def:character[символа]:
  
  #korean[ᄒ ᅯ ᆶ]

  (В Unicode также содержится представление того же слога как одного @def:character[символа]: 훯.)

  Наиболее часто такое встречается в Emoji: так, 🏴‍☠️ состоит из 4 @def:character[символов].
]

#rule(<lex.invalid-encoding>)
#syntax-err-def[Ошибка в кодировке UTF-8][Недопустимая последовательность UTF-8 (в т. ч. суррогаты и overlong encoding) является синтаксической ошибкой].

#rule(<lex.tokenization>)
После декодирования исходный файл преобразуется в последовательность #def("token")[Токен][токенов] — атомарных синтаксических единиц.
Синтаксические конструкции определяются в терминах токенов.

В языке имеются следующие виды токенов:
- идентификаторы (@lex.ident);
- ключевые слова (@lex.keyword);
- примитивные литералы (@lex.primitive-lit);
- комментарии (@lex.comment);
- пути к файлам (@lex.path).

#syntax-err-def[Невозможность распознать последовательность символов как токен][Последовательность символов, которую нельзя распознать как токен, является синтаксической ошибкой.]

#rule-h(<lex.ident>)
== Идентификаторы

#figure(
  ```antlr
  Identifier
      :   [a-zA-Z_$][a-zA-Z0-9_$]*
      |   '`' .*? '`'
      ;
  ```
)

#rule(<lex.ident.intro>)
#def("ident")[Идентификатор][Идентификаторы] служат для описания имён сущностей, а также обозначения ряда синтаксических конструкций.
Идентификаторы могут быть двух форм:

+ Простая форма состоит из следующего набора ASCII-символов: букв, цифр, подчёркивания и знака `$`.

+ Экранированная форма состоит из произвольного набора символов между знаками ``` ` ```.

#rule-h(<lex.ident.simple>)
=== Простая форма идентификаторов

#rule(<lex.ident.simple.digit>)
Простая форма не может начинаться с цифры.

#rule(<lex.ident.simple.keyword>)
Часть идентификаторов в простой форме используются в качестве #def("keyword")[Ключевое слово][ключевых слов].
Они имеют специальное значение в синтаксисе LibSL.

#rule(<lex.ident.simple.name>)
Простые идентификаторы, являющиеся @def:keyword-strict[строгими ключевыми словами], не обозначают имени.
Имя, обозначаемое остальными идентификаторами в простой форме, совпадает с текстовым представлением.

#rule-h(<lex.ident.escaped>)
=== Экранированная форма идентификаторов

#rule(<lex.ident.escaped.name>)
Имя, обозначаемое экранированной формой, записывается внутри ``` ` ```.
Имя не может содержать символа ``` ` ```, так как он обозначает начало и конец идентификатора.

#rule-h(<lex.ident.name>)
=== Имена идентификаторов

#figure(
  ```antlr
  ident
      :   Identifier
      |   weak-keyword
      ;
  ```,
)

#rule(<lex.ident.name.entity>)
Синтаксические конструкции используют идентификаторы для обозначения имён вводимых сущностей.

#rule(<lex.ident.name.equiv>)
Идентификаторы, обозначающие одно и то же имя, эквивалентны.

#note[
  Например, `test` и ``` `test` ``` — два эквивалентных варианта записи одного и того же имени `test`.

  В то же время `for` и ``` `for` ``` не являются эквивалентными.
  Первый идентификатор является @def:keyword-strict[строгим ключевым словом], поэтому он не обозначает какого-либо имени.
  Второй идентификатор ключевым словом не является и, в отличие от первого, обозначает имя `for`.
]

#rule-h(<lex.keyword>)
== Ключевые слова

#rule(<lex.keyword.intro>)
@def:keyword[Ключевые слова] в LibSL делятся на строгие и слабые.

#rule-h(<lex.keyword.strict>)
=== Строгие ключевые слова

#rule(<lex.keyword.strict.intro>)
#def("keyword-strict")[Строгое ключевое слово][Строгие ключевые слова] применяются для обозначения синтаксических конструкций.

#rule(<lex.keyword.strict.name>)
#syntax-err-def[Использование строгих ключевых слов для именования сущностей][Использование их в качестве имён — синтаксическая ошибка.]

#rule-h(<lex.keyword.weak>)
=== Слабые ключевые слова

#rule(<lex.keyword.weak.intro>)
#def("keyword-weak")[Слабое ключевое слово][Слабые ключевые слова] интерпретируются особым образом в некоторых синтаксических конструкциях.
В то же время они могут применяться для именования сущностей.

#rule-h(<lex.keyword.list>)
=== Список ключевых слов

#table(
  columns: (1fr, 5em),
  align: (left, center),

  table.header[*Ключевое слово*][*Строгое*],

  ..(
    `import`,
    `include`,
    `libsl`,
    `library`,
    `version`,
    `language`,
    `url`,
    `typealias`,
    `type`,
    `types`,
    `enum`,
    `annotation`,
    `automaton`,
    `concept`,
    `var`,
    `val`,
    `initstate`,
    `state`,
    `finishstate`,
    `shift`,
    `new`,
    `fun`,
    `constructor`,
    `destructor`,
    `proc`,
    `pred`,
    `action`,
    `requires`,
    `ensures`,
    `assigns`,
    `true`,
    `false`,
    `define`,
    `if`,
    `else`,
    `by`,
    `is`,
    `as`,
    `null`,
    `in`,
    `out`,
    `where`,
    `for`,
    `has`,
    `cancel`,
  ).map(kw => (kw, [Да])).flatten(),

  ..(
    `static`,
    `implements`,
    `pure`,
    `any`,
    `self`,
  ).map(kw => (kw, [Нет])).flatten(),
)

#rule-h(<lex.primitive-lit>)
== Примитивные литералы

#figure(
  ```antlr
  primitiveLit
      :   IntegerLit # PrimitiveLitInt
      |   FloatLit # PrimitiveLitFloat
      |   StringLit # PrimitiveLitStringLit
      |   CharacterLit # PrimitiveLitChar
      |   TRUE # PrimitiveLitTrue
      |   FALSE # PrimitiveLitFalse
      |   NULL # PrimitiveLitNull
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `primitive-lit`
      <
        'integer-lit',
        'float-lit',
        'string-lit',
        'character-lit',
        "true",
        "false",
        "null"
      >
    ]
    ```,
  )
)

#rule(<lex.primitive-lit.intro>)
#def("primitive-lit")[Примитивный литерал] — токен, который используется в @def:primitive-lit-expr[примитивнолитеральных выражениях] для записи значения.
Таковыми являются:
+ целочисленные литералы (@lex.primitive-lit.int);
+ вещественные литералы (@lex.primitive-lit.float);
+ строковые литералы (@lex.primitive-lit.string);
+ символьные литералы (@lex.primitive-lit.char);
+ булевозначные литералы (@lex.primitive-lit.bool);
+ литерал `null` (@lex.primitive-lit.null).

#rule-h(<lex.primitive-lit.int>)
=== Целочисленные литералы

#figure(
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
  
  fragment IntegerTypeSuffix
      :   [lLxsu]
      |   'ux'
      |   'us'
      |   'uL'
      ;
  ```,
)

#rule(<lex.primitive-lit.int.intro>)
Целочисленные литералы (см. @int-lit-syntax) позволяют задать @def:int-value[целые числа].
Числа состоят из цифр, которыми (в зависимости от системы счисления) являются:

#table(
  columns: (auto, auto, 1fr),
  align: (left + horizon, center + horizon, left + horizon),

  table.header[*Система счисления*][*Префикс*][*Цифры*],

  [десятичная], [нет], [`0`, `1`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`],
  [двоичная], `0b`, [`0`, `1`],
  [восьмеричная], `0`, [`0`, `1`, `2`, `3`, `4`, `5`, `6`, `7`],
  [шестнадцатеричная], `0x`, [`0`, `1`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `a`, `b`, `c`, `d`, `e`, `f`],
)

Символы могут приводиться в любом регистре.

#rule(<lex.primitive-lit.int.suffix>)
У целочисленного литерала может иметься суффикс, определяющий его @def:widened-type[расширенный тип примитивного литерала]:

#table(
  columns: (auto, 0.75fr, 1fr, 1fr),
  align: center + horizon,

  table.header[*Суффикс*][*Расширенный тип*][*Мин. значение*][*Макс. значение*],

  `x`, type-expr(builtin-types.int8), $-128$, $127$,
  `ux`, type-expr(builtin-types.unsigned8), $0$, $255$,
  `s`, type-expr(builtin-types.int16), $-32768$, $32767$,
  `us`, type-expr(builtin-types.unsigned16), $0$, $65535$,
  [нет], type-expr(builtin-types.int32), $-2147483648$, $2147483647$,
  `u`, type-expr(builtin-types.unsigned32), $0$, $4194967295$,
  [`l` или `L`], type-expr(builtin-types.int64), $-9223372036854775808$, $9223372036854775807$,
  `uL`, type-expr(builtin-types.unsigned64), $0$, $18446744073709551615$,
)

Суффикс регистрозависим.

#rule(<lex.primitive-lit.int.range>)
Суффикс определяет диапазон допустимых значений литерала.
#syntax-err-def[Использование целочисленного литерала, значение которого превышает границы][Указание числа за допустимыми пределами — синтаксическая ошибка.]

#rule(<lex.primitive-lit.int.sign>)
Знак `-` или `+` не является частью литерала с точки зрения синтаксиса.
Отрицательные числа можно указать при помощи @def:signed-num-lit-expr[знакового целочисленного литерала].
Допустимость значения числа в них определяется с учётом знака.

#explanation[
  `128x` синтаксически ошибочно, так как $128$ больше максимального значения $127$.
  В отличие от него, выражение `-128x` не является ошибочным: при проверке значением литерала считается $-128$, которое допустимо.
]

#rule-h(<lex.primitive-lit.float>)
=== Вещественные литералы

#figure(
  ```antlr
  FloatLit
      :   DecimalFloatLit
      ;
  
  fragment DecimalFloatLit
      :   Digits '.' Digits? ExponentPart? FloatTypeSuffix?
      |   Digits ExponentPart FloatTypeSuffix?
      |   Digits FloatTypeSuffix
      ;
  ```
)

#rule(<lex.primitive-lit.float.intro>)
Вещественные литералы (см. @float-lit-syntax) позволяют задать @def:float-value[числа с плавающей запятой].

#rule(<lex.primitive-lit.float.exponent>)
Вещественный литерал состоит из мантиссы $b$ и опциональной экспоненты $n$.
При отсутствии экспонента полагается равной нулю.
Вещественный литерал интерпретируется как $v = b dot 10^n$.

#rule(<lex.primitive-lit.float.ieee-754>)
Значение вещественного литерала представляется в формате, регламентируемом стандартом IEEE 754#footnote[IEEE Standard for Floating-Point Arithmetic : IEEE Std 754-2019 / IEEE. — New York : IEEE, 2019. — ISBN 978-1-5044-5924-2. — DOI 10.1109/IEEESTD.2019.8766229.] <ref:ieee>.
Число $v$ преобразуется в значение посредством округления к ближайшему представимому (согласно `roundTiesToEven`).

#note[
  В частности, значениями могут быть знаковые бесконечности и `NaN`.
  Для них не имеется явных литералов, однако бесконечность можно получить при превышении диапазонов представимых конечных чисел.
]

#rule(<lex.primitive-lit.float.suffix>)
У вещественного литерала может иметься суффикс, определяющий его @def:widened-type[расширенный тип примитивного литерала]:

#table(
  columns: (auto, auto, 1fr),
  align: center + horizon,

  table.header[*Суффикс*][*Расширенный тип*][*Формат представления (по IEEE 754)*],

  [нет или `f`], type-expr(builtin-types.float32), `binary32`,
  `d`, type-expr(builtin-types.float64), `binary64`,
)

Суффикс регистронезависим.

#rule-h(<lex.primitive-lit.string>)
=== Строковые литералы

#figure(
  ```antlr
  StringLit
      :   '"' (ESCAPED_QUOTE | ~('\n' | '\r'))*? '"'
      ;
  ```,
)

#rule(<lex.primitive-lit.string.intro>)
Строковые литералы позволяют задать @def:string-value[строковые значения] @def:widened-type[расширенного типа примитивного литерала] #type-expr(builtin-types.string).

#rule(<lex.primitive-lit.string.value>)
Значение литерала — последовательность @def:character[символов].
В литерале они представляются непосредственно, кроме следующих символов:

- символы с Unicode-кодами `U+000A` и `U+000D` — недопустимы в литерале и не могут быть записаны;
- последовательность символов `\"` интерпретируется как `"`.

#deficiency[
  Нет способа записать строку, содержащую символы с кодами `U+000A`, `U+000D` или `U+005C` (`\`).
]

#rule-h(<lex.primitive-lit.char>)
=== Символьные литералы

#figure(
  ```antlr
  CharacterLit
      :   '\'' SingleCharacter '\''
      |   '\'' EscapeSequence '\''
      ;
  ```,
)

#rule(<lex.primitive-lit.char.intro>)
Символьные литералы (см. @char-lit-syntax) позволяют задать @def:char-value[символьные значения] @def:widened-type[расширенного типа примитивного литерала] #type-expr(builtin-types.char).

#rule(<pex.primitive-lit.char.value>)
Значение литерала — один @def:character[символ].
Запись его интерпретируется следующим образом:

#table(
  columns: (2fr, 1fr, 2fr),
  align: center + horizon,

  table.header[*Запись*][*Значение*][*Комментарий*],

  [Любой @def:character[символ] кроме `U+000A`, `U+000D`, `U+0027`, `U+005C`], [Непосредственное], [Недопустимые символы — `'`, `\`, а также `LINE FEED` и `CARRIAGE RETURN`],
  `\b`, `U+0008`, [Символ `BACKSPACE`],
  `\t`, `U+0009`, [Символ `HORIZONTAL TAB`],
  `\n`, `U+000A`, [Символ `LINE FEED`],
  `\f`, `U+000C`, [Символ `FORM FEED`],
  `\r`, `U+000D`, [Символ `CARRIAGE RETURN`],
  `\"`, `U+0022`, `"`,
  `\'`, `U+0027`, `'`,
  `\\`, `U+005C`, `\`,
  `\uXXXX`, table.cell(colspan: 2)[`XXXX` — шестнадцатеричное число с 4 цифрами, обозначающее Unicode codepoint @def:character[символа]],
  [`\OOO` \ (от 1 до 3 восьмеричных цифр)], table.cell(colspan: 2)[`OOO` — восьмеричное число от $0$ до $377_8$ ($255$ в десятичной системе счисления), обозначающее Unicode codepoint @def:character[символа]],
)

#deficiency[
  Символы вне Basic Multilingual Plane должны указываться напрямую: для них не имеется hex-экранирующей последовательности.
]

#rule-h(<lex.primitive-lit.bool>)
=== Булевозначные литералы

Литералы `true` и `false` обозначают соответственно истинное и ложное @def:bool-value[булевы значения] @def:widened-type[расширенного типа примитивного литерала] #type-expr(builtin-types.bool).

#rule-h(<lex.primitive-lit.null>)
=== Литерал `null`

Литерал `null` обозначает единственное @def:null-value[значение] @def:widened-type[расширенного типа примитивного литерала] #type-expr(builtin-types.null).

#note[
  `null` не является указателем.
]

#rule-h(<lex.comment>)
== Комментарии

#figure(
  ```antlr
  fragment COMMENT
      :   '/*' .*? '*/'
      ;
  
  fragment LINE_COMMENT
      :   '//' ~[\r\n]*
      ;
  ```,
)

@def:source-file[Исходный файл] может содержать комментарии.
Они игнорируются в синтаксических конструкциях языка.

Имеются два вида комментариев:

+ #rule(<lex.comment.line>)
  Строковый комментарий начинается с последовательности `//` и продолжается до первого символа `U+000A` (`LINE FEED`) или `U+000D` (`CARRIAGE RETURN`), не включая его.

+ #rule(<lex.comment.block>)
  Блоковый комментарий начинается с последовательности `/*` и завершается последовательностью `*/`.

#rule-h(<lex.whitespace>)
== Пробельные символы

Пробельные символы игнорируются в синтаксических конструкциях языка.
Следующие символы являются пробельными:

#table(
  columns: (auto, 1fr),
  align: (center, left),

  table.header[*Символ (Unicode codepoint)*][*Комментарий*],

  `U+0020`, [Символ `SPACE`],
  `U+0009`, [Символ `HORIZONTAL TAB`],
  `U+000A`, [Символ `LINE FEED`],
  `U+000C`, [Символ `FORM FEED`],
  `U+000D`, [Символ `CARRIAGE RETURN`],
)

#rule-h(<lex.path>)
== Пути к файлам

#figure(
  ```antlr
  mode Path;
  
  PathIgnored
      :   IGNORED -> channel(HIDDEN)
      ;
  
  PathSemi
      :   ';' -> type(SEMICOLON), popMode
      ;
  
  PathStringLit
      :   StringLit -> type(StringLit)
      ;
  
  BarePath
      :   [\p{L}\p{N}!@$%^&*+=/_\\.-]+
      ;
  ```,
)

#rule(<lex.path.intro>)
После токенов `import` и `include` располагается #def("file-path")[Путь к файлу][путь к файлу], который распознаётся особым образом.
Путь к файлу может быть указан двумя способами:

#rule(<lex.path.string-lit>)
/ Строковый литерал:
  Распознаётся так же, как в @lex.primitive-lit.string.
  Значение строки обозначает путь.

#rule(<lex.path.bare>)
/ Непосредственный:
  Непосредственным путём к файлу является непрерывная последовательность следующих символов:

  - Любые из таблицы ниже:

    #table(
      columns: (1fr, 2fr),
      align: (center, left),

      table.header[*Символ*][*Комментарий*],
      
      ..{
        let chars = (
          "!",
          "@",
          "$",
          "%",
          "^",
          "&",
          "*",
          "+",
          "=",
          "/",
          "_",
          "\\",
          ".",
          "-",
        )

        for c in chars {
          let codepoint = str(str.to-unicode(c))

          let leading-zeros = if codepoint.len() < 4 {
            "0" * (4 - codepoint.len())
          } else {
            ""
          }

          (raw("U+" + leading-zeros + codepoint), raw(c))
        }
      }
    )

  - Символы с Unicode-свойством `General_Category`, равным `Letter` или `Number`.
