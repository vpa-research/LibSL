#import "../meta.typ": *
#import "../railroad.typ": *
#import "../types.typ": type-expr, ctor, builtin-types, ptr, union as ty-union

#rule-h(<type>)
= Система типов

#rule(<type.intro>)
LibSL является статически типизированным языком.
У всех выражений и переменных в @def:module[модуле] имеется тип.
#def("type")[Тип] определяет набор допустимых @def:value[значений] и операций над ними.
Он также называется статическим типом, чтобы отличать от @def:dynamic-type[динамических типов].

Для указания типов в синтаксических конструкциях используются @def:type-expr[типовые выражения].
В ходе анализа типов типовые выражения интерпретируются для получения типов.

Часть типов в модуле выводится автоматически.
Для этого составляется и решается @def:type-constr-system[система типовых ограничений].

#rule-h(<type.types>)
== Типы

Имеются следующие виды типов:
- @def:constructed-type[Конструируемые типы]
- @def:pointer-type[Типы указателей]
- @def:union-type[Типы-объединения]
- @def:literal-type[Литеральные типы]
- @def:type-param[Типовые параметры]

#rule-h(<type.types.constructed>)
=== Конструируемые типы

#rule(<type.types.constructed.intro>)
#def("constructed-type")[Конструируемый тип] #type-expr(ctor("ctor")($T_1$, $...$, $T_n$)) — тип, получаемый применением последовательности типов $T_1, ..., T_n$ (называемых #def("constructed-type-arg")[Аргумент конструируемого типа][аргументами]) к @def:type-constructor[конструктору типа] #type-expr("ctor").

#def("type-constructor")[Конструктор типа] — именованная @def:entity[сущность], которая определяет семейство типов.
Два конструируемых типа, полученных применением различных конструкторов типа, всегда не @def:type-eq[равны] друг другу.
Ряд конструкторов типов порождаются @def:decl[объявлениями]; LibSL также определяет набор встроенных (@type.builtin).

#rule(<type.types.constructed.eq>)
Конструируемый тип полностью определяется своими конструктором и аргументам.
Если у двух конструируемых типов они попарно @def:type-eq[равны], типы также являются равными.

#rule(<type.types.constructed.decls>)
@def:decl[Объявления], порождающие конструкторы типов:
- @def:struct-decl
- @def:enum-decl

#rule(<type.types.constructed.type-expr>)
Конструируемые типы указываются при помощи @def:name-type-expr[типовых выражений имён].

#rule-h(<type.types.pointer>)
=== Типы указателей

#rule(<type.types.pointer.intro>)
#def("pointer-type")[Тип указателя] #type-expr(ptr($T$)) — тип, содержащий @def:pointer-value[указатели] на данные типа #type-expr($T$).

#rule(<type.types.pointer.type-expr>)
Типы указателей указываются при помощи @def:pointer-type-expr[типовых выражений указателя].

#rule-h(<type.types.union>)
=== Типы-объединения

#rule(<type.types.union.intro>)
#def("union-type")[Тип-объединение] $T_1 union ... union T_n$ — тип, получаемый в результате операции @def:type-union[объединения типов].
Он состоит из двух или более @def:type-eq[различных] типов.
Набор объединяемых типов неупорядочен.
Значения типа-объединения — объединение множеств значений каждого из объединяемых типов.

#rule(<type.types.union.type-expr>)
Типы-объединения указываются при помощи @def:union-type-expr[типовых выражений объединения].

#note[
  LibSL 1 содержал также типы-пересечения.
  Из-за теоретической сложности их поддержки и низкой применимости они были исключены.
]

#rule-h(<type.types.literal>)
=== Литеральные типы

#rule(<type.types.literal.intro>)
#def("literal-type")[Литеральный тип] — тип, определяемый @def:primitive-lit[примитивным литералом], который является его единственным значением.

#rule(<type.types.literal.type-expr>)
Литеральные типы указываются при помощи @def:primitive-lit-type-expr[примитивнолитеральных типовых выражений].

#note[
  Так как @def:primitive-lit-expr[примитивнолитеральные выражения] не имеют литерального типа, для его получения необходимо воспользоваться @def:cast-expr[выражением приведения типов].
]

#rule-h(<type.types.param>)
=== Типовые параметры

#figure(
  ```antlr
  qualifiedTypeName
    :   typeName=fullName
        typeParams=generics?
    ;

  generics
      :   L_ANGLE (list=genericList COMMA?)? R_ANGLE
      ;

  genericList
      :   params+=generic
          (COMMA params+=generic)*
      ;

  generic
      :   variance=varianceSpec?
          name=ident
      ;

  varianceSpec
      :   OUT # Covariant
      |   IN # Contravariant
      |   IN OUT # Invariant
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `qualified-type-name`
      'full-name'
      'generics'?
    ]
    ```
  )
)

#figure(
  railroad(
    ```
    [
      `generics`
      "<"
      [
        [
          <
            !,
            "out",
            "in",
            ["in" "out"]
          >#`variance`

          'ident'
        ]*","
        ","?
      ]?
      ">"
    ]
    ```,
  )
)

#rule(<type.types.param.intro>)
Ряд сущностей обладают #def("type-param")[Типовой параметр][типовыми параметрами].
Они позволяют обозначить тип символически внутри объявления.
Такие сущности называются #def("parametrized-entity")[Параметризуемая сущность][параметризуемыми].
При использовании параметризуемых сущностей указываются @def:type-arg[типовые аргументы], которые заменяют типовые параметры.

#rule(<type.types.param.identity>)
Типовые параметры идентифицируются их местом объявления, а не именем.

#rule-h(<type.types.param.variance>)
==== Вариантность

Параметры имеют #def("param-variance")[Вариантность][вариантность], которая определяет их взаимодействие с @def:type-sub[подтипизацией]:

- #rule(<type.types.param.variance.invariance>)
  Если указание вариантности отсутствует или указано как `in out`, параметр является #def("invariant-param")[Инвариантный типовой параметр][инвариантным].
  Он может использоваться в любых @def:variance-position[позициях].

- #rule(<type.types.param.variance.covariance>)
  Если вариантность задана как `out`, параметр является #def("covariant-param")[Ковариантный типовой параметр][ковариантным].
  Он может использоваться только в ковариантных и инвариантных @def:variance-position[позициях].

- #rule(<type.types.param.variance.contravariance>)
  Если вариантность задана как `in`, параметр является #def("contravariant-param")[Контравариантный типовой параметр][контравариантным].
  Он может использоваться только в контравариантных и инвариантных @def:variance-position[позициях].

#rule(<type.types.param.variance.illegal-position>)
#sema-err-def[Использование вариантного типового параметра в противоположной вариантной позиции][Использование ковариантного или контравариантного типового параметра в позициях кроме разрешённых — семантическая ошибка.]

#impl-spec(impls.rs)[
  Такая проверка отсутствует.
]

#unresolved[
  А точно ли в LibSL нужна вариантность?
  Сейчас подтипизация в языке рудиментарна.

  Скорее всего, разумно её пока исключить и добавить уже впоследствии, продумав её взаимодействие с остальными аспектами системы типов.
]

#TODO[вариантность для псевдонимов типов]

#rule-h(<type.types.param.constr>)
==== Ограничения на типовые параметры

#figure(
  ```antlr
  whereClause
      :   WHERE constraints+=typeConstraint
          (COMMA constraints+=typeConstraint)*
          COMMA?
      ;

  typeConstraint
      :   param=ident
          COLON
          bound=typeExpr
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `where-clause`
      "where"
      'type-constraint'*","
      ","?
    ]
    ```,
  )
)

#figure(
  railroad(
    ```
    [
      `type-constraint`
      'ident'
      ":"
      'type-expr'
    ]
    ```,
  )
)

#rule(<type.types.param.constr.intro>)
На типовые параметры могут накладываться #def("type-param-constraint")[Ограничение, накладываемое на типовые параметры][ограничения].
Они определяют требования, предъявляемые к @def:type-arg[типовым аргументам].

#unresolved[
  Неясно, что именно обозначают эти ограничения.
  С учётом того, что подтипизация крайне ограничена, а функциональности вроде type class из Haskell в LibSL нет, ограничения кажутся бессмысленными.

  Интересными были бы ограничения вроде "@def:eq-type[проверяемый на равенство]", "@def:ord-type[упорядоченный]", "@def:hashable-type[хэшируемый]", чтобы можно было обобщать сравнения и работу с множествами.
  Что-то похожее есть в Go.
]

#impl-spec(impls.rs)[
  Типовые ограничения игнорируются при семантическом анализе.
]

#rule-h(<type.types.param.arg>)
==== Типовые аргументы

#figure(
  ```antlr
  typeArgSpec
      :   L_ANGLE (list=typeArgList COMMA?)? R_ANGLE
      ;

  typeArgList
      :   typeArgs+=typeArg
          (COMMA typeArgs+=typeArg)*
      ;

  typeArg
      :   variance=varianceSpec? typeExpr # TypeArgTypeExpr
      |   QUESTION # TypeArgWildcard
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `type-arg-spec`
      "<"
      [
        'type-arg'*","
        ","?
      ]?
      ">"
    ]
    ```,
  )
)

#figure(
  railroad(
    ```
    [
      `type-arg`
      <
        [
          <
            !,
            "in",
            "out",
            ["in" "out"]
          >

          'type-expr'
        ],
        "?"
      >
    ]
    ```,
  )
)

#def("type-arg")[Типовой аргумент][Типовые аргументы] — синтаксическая конструкция языка, позволяющая задать типы, соответствующие @def:type-param[типовым параметрам] некоторой сущности.
Бывает двух видов:

#rule(<type.types.param.arg.bounded>)
/ #def("bounded-type-arg")[Ограниченный типовой аргумент][Ограниченный]:
  Записывается при помощи @def:type-expr[типового выражения] и обозначает соответствующий тип.

  #rule(<type.types.param.arg.bounded.use-site-variance>)
  Синтаксис также допускает указание `in`, `out` или `in out`.
  #sema-err-def[Указание ограниченного типового аргумента с `in`, `out` или `in out`][Их использование — семантическая ошибка.]

  #note[
    Они были взяты в LibSL 1 по аналогии с use-site variance из Kotlin.
    В LibSL 2 они не поддерживаются.
  ]

  #impl-spec(impls.rs)[
    В семантическом анализе они не реализованы.
  ]

#rule(<type.types.param.arg.wildcard>)
/ #def("wildcard-type-arg")[Неограниченный типовой аргумент][Неограниченный]:
  Записывается как `?`.
  #sema-err-def[Использование неограниченных типовых аргументов][Использование неограниченного типового аргумента — семантическая ошибка.]

  #note[
    Перенят из Java в LibSL 1.
    В LibSL 2 он не поддерживается.
  ]

  #impl-spec(impls.rs)[
    В семантическом анализе он не реализован.
  ]

#rule-h(<type.integral>)
== Целочисленные типы

#rule(<type.integral.intro>)
#def("integral-type")[Целочисленный тип] — тип, являющийся примитивным целочисленным либо @def:enum-decl[перечислимым].
Целочисленный тип характеризуется знаковостью и шириной.

#rule(<type.integral.width>)
#def("integral-type-width")[Ширина целочисленного числа][Ширина] определяет диапазон значений целочисленного типа.
Ширина задаётся в битах; целочисленный тип с шириной $n$ имеет $2^n$ значений.

#rule(<type.integral.signedness>)
#def("integral-type-signedness")[Знаковость целочисленного типа][Знаковость] определяет возможность представления типом отрицательных чисел.
В знаковых типах значения с единичным старшим битом считаются отрицательными согласно дополнительному коду (2's complement).

#rule(<type.integral.primitive>)
#def("primitive-integer-type")[Примитивный целочисленный тип][Примитивными целочисленными типами] являются встроенные целочисленные типы:
#[
  #let t(name, width, sign) = (name: name, width: width, sign: sign)
  #metadata((
    t("int8", 8, true),
    t("int16", 16, true),
    t("int32", 32, true),
    t("int64", 64, true),
    t("unsigned8", 8, false),
    t("unsigned16", 16, false),
    t("unsigned32", 32, false),
    t("unsigned64", 64, false),
  )) <meta:primitive-int-types>
]
#context enum(
  tight: true,

  ..query(<meta:primitive-int-types>).at(0).value.map(it => type-expr(builtin-types.at(it.name)))
)

#rule-h(<type.builtin>)
== Встроенные типы

#rule(<type.builtin.intro>)
Ряд @def:constructed-type[конструируемых типов] являются встроенными в язык.

#rule-h(<type.builtin.nullary>)
=== Типы без параметров

Нижеперечисленные типы не имеют @def:type-param[типовых параметров].

#rule(<type.builtin.int>)
/ Примитивные целочисленные типы:
  Содержат @def:int-value[целочисленные значения].

  #table(
    columns: (2fr, 1fr, 1fr),
    align: center + horizon,

    table.header[*Имя типа*][*Знаковость*][*Ширина*],

    `int8`, [знаковый], $8$,
    `int16`, [знаковый], $16$,
    `int32`, [знаковый], $32$,
    `int64`, [знаковый], $64$,
    `unsigned8`, [беззнаковый], $8$,
    `unsigned16`, [беззнаковый], $16$,
    `unsigned32`, [беззнаковый], $32$,
    `unsigned64`, [беззнаковый], $64$,
  )

#rule(<type.builtin.float>)
/ #def("float-type")[Вещественный числовой тип][Вещественные численные типы]:
  #[
    #let t(name, width, repr) = (name: name, width: width, repr: repr)
    #metadata((
      t("float32", 32, "binary32"),
      t("float64", 64, "binary64"),
    )) <meta:float-types>
  ]
  Типы `float32` и `float64`.
  Содержат @def:float-value[вещественные значения].

#rule(<type.builtin.bool>)
/ Булевый тип:
  Тип `bool`.
  Содержит @def:bool-value[булевы значения].

#rule(<type.builtin.char>)
/ Символьный тип:
  Тип `char`.
  Содержит @def:char-value[символьные значения].

#rule(<type.builtin.string>)
/ Строковый тип:
  Тип `string`.
  Содержит @def:string-value[строковые значения].

#rule(<type.builtin.void>)
/ Тип `void`:
  Содержит единственное @def:void-value[void-значение].

#rule(<type.builtin.any>)
/ Тип `any`:
  Является @def:type-sub[надтипом] всех типов.
  Содержит любые значения.

#rule(<type.builtin.nothing>)
/ Тип `nothing`:
  Является @def:type-sub[подтипом] всех типов.
  Не имеет значений.

#rule-h(<type.builtin.parametrized>)
=== Параметризованные типы

#rule(<type.builtin.array>)
/ Типы массивов:
  Тип вида #type-expr(ctor(builtin-types.array)($T$)).
  $T$ является @def:invariant-param[инвариантным] типовым параметром, задающим тип элемента массива.
  Содержит @def:array-value[массивы].

#rule(<type.builtin.set>)
/ Типы множеств:
  Тип вида #type-expr(ctor(builtin-types.set)($T$)).
  $T$ является @def:covariant-param[ковариантным] типовым параметром, задающим тип элемента множества.
  Аргумент $T$ должен быть @def:hashable-type[хэшируемым].
  Содержит @def:set-value[множества].

#rule-h(<type.op>)
== Типовые операции и отношения

#rule(<type.op.intro>)
На типах определён ряд операций и отношений, которые используются в данной спецификации.

#rule-h(<type.op.widening>)
=== Расширение литерального типа

#def("literal-type-widening")[Расширение литерального типа] $"widen"$ — типовая операция, определённая на @def:literal-type[литеральных типах].
Она сопоставляет каждому @def:primitive-lit[примитивному литералу] его #def("widened-type")[Расширенный тип примитивного литерала][расширенный тип] согласно виду литерала.

#note[
  Расширенный тип определяется в описании каждого вида примитивного литерала (@lex.primitive-lit).
]

#example[
  $ "widen"(#`true`) = #type-expr(builtin-types.bool) $
  $ "widen"(#`42ux`) = #type-expr(builtin-types.unsigned8) $
]

#rule-h(<type.op.clone-type-param>)
=== Клонирование типовых параметров

#def("clone-type-param")[Клонирование типового параметра] $"clone-type-param"$ — типовая операция, определённая на @def:type-param[типовых параметрах].

$ "clone-type-param"(#type-expr($T$)) = #type-expr($T'$), $

где #type-expr($T$) — клонируемый типовой параметр, а #type-expr($T'$) — новый (не @def:type-eq[равный] какому-либо другому) типовой параметр той же @def:param-variance[вариантности].

#rule-h(<type.op.union>)
=== Объединение типов

#def("type-union")[Объединение типов] $"union"(T, U)$ — типовая операция, определённая на всех типах следующим образом:

#{
  show math.equation: set block(breakable: true)
  $
    &"union"(T_1 union ... union T_n, R) = T_1 union ... union T_n, " если" exists k: R = T_k; \
    &"union"(L, T_1 union ... union T_n) = T_1 union ... union T_n, " если" exists k: L = T_k; \
    &"union"(T_1 union ... union T_n union U_1 union ... union U_k, U_1 union ... union U_k union S_1 union ... union S_m) = \
    &#h(4em)T_1 union ... union T_n union U_1 union ... union U_k union S_1 union ... union S_m; \
    &"union"(T, T) = T; \
    &"union"(L, R) = L union R "в противном случае".
  $
}

Также определены:

$
  &"union"(T_1, ..., T_n) &&= "union"("union"(T_1, ..., T_(n - 1)), T_n) "для" n > 2; \
  &"union"(T) &&= T; \
  &"union"() &&= #type-expr(builtin-types.nothing).
$

#rule-h(<type.op.subst>)
=== Подстановка типов

#def("type-subst")[Подстановка типов] $T[L_1 mapsto R_1, ..., L_n mapsto R_n]$, где $L_1, ..., L_n$ — попарно различные @def:infer-var[типовые переменные] или @def:type-param[типовые параметры], — типовая операция, определённая на всех @def:extended-type[расширенных типах].
Она однократно заменяет вхождения типовых переменных и параметров $L_1, ..., L_n$ в типе $T$ на соответствующие расширенные типы $R_1, ..., R_n$.

#example[
  $ #type-expr(ctor(builtin-types.array)(ctor(builtin-types.set)($T$)))\[#type-expr($T$) mapsto #type-expr(builtin-types.int32)\] = #type-expr(ctor(builtin-types.array)(ctor(builtin-types.set)(builtin-types.int32))) $
]

#rule-h(<type.op.eq>)
=== Равенство

#def("type-eq")[Отношение равенства] $L = R$ на типах устанавливается следующим образом:

+ Для @def:constructed-type[конструируемых типов]: см. @type.types.constructed.eq.

+ Два @def:pointer-type[типа указателя] #type-expr(ptr($T$)) и #type-expr(ptr($U$)) равны, если $T = U$.

+ Два @def:union-type[типа-объединения] $L = #type-expr(ty-union($T_1$, $...$, $T_n$))$ и $R = #type-expr(ty-union($U_1$, $...$, $U_m$))$ равны, если:
  + для каждого $T_i$ существует $U_j$ такой, что $T_i = U_j$;
  + для каждого $U_i$ существует $T_j$ такой, что $T_j = U_i$.

+ Два @def:literal-type[литеральных типа] равны, если значения их литералов равны.

  + Значения вещественных литералов сравниваются побитово.

+ Два @def:type-param[типовых параметра] равны, если они являются одними и теми же типовыми параметрами.

  #explanation[
    Имя параметров для равенства не имеет значения.
  ]

+ Остальные типы неравны друг другу.

#note[
  Отношение равенства является отношением эквивалентности: оно рефлексивно, симметрично и транзитивно.
]

#rule-h(<type.op.sub>)
=== Подтипизация

#def("type-sub")[Отношение подтипизации] $L <: R$ на типах устанавливается следующим образом:

+ Если $L = #type-expr(ctor("A")($T_1$, $...$, $T_n$))$ и $R = #type-expr(ctor("B")($U_1$, $...$, $U_m$))$ — @def:constructed-type[конструируемые типы], то $L <: R$, если:
  + $#type-expr("A") = #type-expr("B")$;
  + $n = m$;
  + для каждого $i in {1, ..., n}$ выполнено:
    + если $i$-ый @def:type-param[типовой параметр] #type-expr("A"):
      + @def:invariant-param[инвариантен], то $T_i = U_i$;
      + @def:covariant-param[ковариантен], то $T_i <: U_i$;
      + @def:contravariant-param[контравариантен], то $U_i <: T_i$.

+ Если $L = #type-expr(builtin-types.nothing)$, то $L <: R$.

+ Если $R = #type-expr(builtin-types.any)$, то $L <: R$.

+ В противном случае $L <: R$, если $L = R$.

#note[
  Различные @def:union-type[типы-объединения] не находятся друг с другом в отношении подтипизации.
]

#note[
  Отношение подтипизации является отношением частичного порядка: оно рефлексивно, антисимметрично и транзитивно.
]

#rule-h(<type.op.coerce>)
=== Неявное приведение

#def("type-coerce")[Отношение неявного приведения] $L --> R$ на типах устанавливается следующим образом:

+ Если $L$ и $R$ — @def:primitive-integer-type[примитивные целочисленные типы] однаковой @def:integral-type-signedness[знаковости], то $L --> R$, если @def:integral-type-width[ширина] $R$ больше ширины $L$.

+ Если $L = #type-expr(builtin-types.float32)$ и $R = #type-expr(builtin-types.float64)$, то $L --> R$.

+ Если $L = #type-expr(ty-union($T_1$, $...$, $T_n$))$ и $R = #type-expr(ty-union($U_1$, $...$, $U_m$))$, то $L --> R$, если для любого $i in {1, ..., n}$ существует $j$ такой, что $T_i = U_j$.

  #note[
    Иначе говоря, множество объединяемых типов $L$ содержится в множестве объединяемых типов $R$.
  ]

+ Если $R = #type-expr(ty-union($U_1$, $...$, $U_n$))$, то $L --> R$, если существует $j$ такой, что $L = U_j$.

+ В противном случае $L --> R$, если $L <: R$.

#note[
  Отношение неявного приведения является отношением частичного порядка: оно рефлексивно, антисимметрично и транзитивно.
]

#rule-h(<type.expr>)
== Типовые выражения

#figure(
  ```antlr
  atomicTypeExpr
      :   L_PAREN inner=typeExpr R_PAREN # TypeExprParen
      |   lit=primitiveLit # TypeExprPrimitiveLit
      |   nameTypeExpr # TypeExprName
      |   pointerTypeExpr # TypeExprPointer
      ;

  typeExpr
      :   atomicTypeExpr # TypeExprAtomic
      |   lhs=typeExpr AMP rhs=typeExpr # TypeExprIntersection
      |   lhs=typeExpr PIPE rhs=typeExpr # TypeExprUnion
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `type-expr`
      <
        ["(" 'type-expr' ")"],
        'primitive-lit-type-expr',
        'name-type-expr',
        'pointer-type-expr',
        'intersection-type-expr',
        'union-type-expr'
      >
    ]
    ```,
  )
)

#rule(<type.expr.intro>)
#def("type-expr")[Типовое выражение][Типовые выражения] — синтаксические конструкции, посредством которых указываются @def:type[типы].

#rule(<type.expr.kinds>)
В языке имеются следующие типовые выражения:

+ @def:primitive-lit-type-expr
+ @def:name-type-expr
+ @def:pointer-type-expr
+ @def:intersection-type-expr
+ @def:union-type-expr

#rule(<type.expr.precedence>)
Приоритеты и ассоциативность типовых выражений и типовых операторов в LibSL следующие (в порядке уменьшения приоритетов):

#table(
  columns: 2,

  table.header[*Типовые операторы и выражения*][*Ассоциативность*],

  [@def:pointer-type-expr], [—],
  [@def:intersection-type-expr], [Левая],
  [@def:union-type-expr], [Левая]
)

#rule(<type.expr.paren>)
В типовом выражении могут произвольным образом использоваться скобки для группировки типовых подвыражений независимо от приоритетов.
Они имеют значение только для синтаксического разбора; на семантические свойства они не влияют.

#rule-h(<type.expr.primitive-lit>)
=== Примитивнолитеральное типовое выражение

#figure(
  railroad(
    ```
    [
      `primitive-lit-type-expr`
      'primitive-lit'
    ]
    ```,
  )
)

#rule(<type.expr.primitive-lit.intro>)
#def("primitive-lit-type-expr")[Примитивнолитеральное типовое выражение] состоит из @def:primitive-lit[примитивного литерала].

#rule(<type.expr.primitive-lit.type>)
Тип, задаваемый типовым выражением, — @def:literal-type[литеральный тип] с соответствующим литералом.

#rule-h(<type.expr.name>)
=== Типовое выражение имени

#figure(
  ```antlr
  nameTypeExpr
      :   typeName=fullName
          typeArgs=typeArgSpec?
      ;
  ```
)

#figure(
  railroad(
    ```
    [
      `name-type-expr`
      'full-name'
      'type-arg-spec'?
    ]
    ```,
  )
)

#rule(<type.expr.name.intro>)
#def("name-type-expr")[Типовое выражение имени] формирует тип на основании применения @def:type-arg[типовых аргументов] к некоторой именованной сущности.

#rule-h(<type.expr.name.alias>)
==== Псевдоним типа

#rule(<type.expr.name.alias.intro>)
Данная секция описывает интерпретацию типового выражения имени, которое соответствует @def:type-alias-decl[псевдониму типа].

Пусть:

+ $T_1, ..., T_n$ — @def:type-param[типовые параметры] псевдонима типа.
+ $U_1, ..., U_m$ — @def:type-arg[типовые аргументы] типового выражения.
+ $S$ — тип-определение псевдонима типа.

#rule(<type.expr.name.alias.arg-count>)
Число типовых аргументов $m$ должно быть равно количеству типовых параметров $n$.
#sema-err-def[Несовпадение числа типовых аргументов выражения имени с количеством типовых параметров псевдонима типа][Несовпадение является семантической ошибкой.]

#rule(<type.expr.name.type>)
Тип, задаваемый типовым выражением, — $S[T_1 mapsto U_1, ..., T_n mapsto U_n]$, где квадратные скобки обозначают операцию @def:type-subst[подстановки типов].

#rule-h(<type.expr.name.param>)
==== Типовой параметр

#rule(<type.expr.name.param.intro>)
Данная секция описывает интерпретацию типового выражения имени, которое соответствует @def:type-param[типовому параметру] $T$.

#rule(<type.expr.name.param.arg-count>)
Типовое выражение не должно иметь типовых аргументов.
#sema-err-def[Наличие типовых аргументов у типового выражения имени типового параметра][Их наличие является семантической ошибкой.]

#note[
  Допустимые формы записи: `T` или `T<>`.
]

#rule(<type.expr.name.param.type>)
Тип, задаваемый типовым выражением, — #type-expr($T$).

#rule-h(<type.expr.other>)
==== Иные сущности

#rule(<type.expr.other.intro>)
Данная секция описывает интерпретацию типового выражения имени, которое соответствует сущности, не описанной выше.

Пусть:

+ #type-expr("ctor") — имя сущности.
+ $T_1, ..., T_n$ — @def:type-param[типовые параметры] псевдонима типа.
+ $U_1, ..., U_m$ — @def:type-arg[типовые аргументы] типового выражения.

#rule(<type.expr.other.arg-count>)
Число типовых аргументов $m$ должно быть равно количеству типовых параметров $n$.
#sema-err-def[Несовпадение числа типовых аргументов выражения имени с количеством типовых параметров][Несовпадение является семантической ошибкой.]

#rule(<type.expr.other.type>)
Тип, задаваемый типовым выражением, — @def:constructed-type[конструируемый тип] #type-expr(ctor("ctor")($U_1$, $...$, $U_m$)).

#rule-h(<type.expr.pointer>)
=== Типовое выражение указателя

#figure(
  ```antlr
  pointerTypeExpr
      :   ASTERISK
          base=atomicTypeExpr
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `pointer-type-expr`
      "*"
      'type-expr'
    ]
    ```,
  )
)

#rule(<type.expr.pointer.intro>)
#def("pointer-type-expr")[Типовое выражение указателя] позволяет указать @def:pointer-type[тип указателя].

#rule(<type.expr.pointer.type>)
Пусть $T$ — тип, задаваемый типовым подвыражением.
Тогда типовое выражение указателя задаёт @def:pointer-type[тип указателя] #type-expr(ptr($T$)).

#rule-h(<type.expr.intersection>)
=== Типовое выражение пересечения

#figure(
  ```antlr
  typeExpr:
      ...
      |   lhs=typeExpr AMP rhs=typeExpr # TypeExprIntersection
      ...
  ```,
)

#figure(
  railroad(
    ```
    [
      `intersection-type-expr`
      'type-expr'
      "&"
      'type-expr'
    ]
    ```,
  )
)

#rule(<type.expr.intersection.intro>)
#def("intersection-type-expr")[Типовое выражение пересечения] — неподдерживаемая синтаксическая конструкция.

#sema-err-def[Использование типового выражения пересечения][Её использование — семантическая ошибка.]

#note[
  Данное типовое выражение было унаследовано от LibSL 1, в котором оно задавало тип-пересечение.
  Так как типы-пересечения в LibSL 2 отсутствуют, соответствующее типовое выражение является ошибочным.
]

#impl-spec(impls.rs)[
  Семантический анализ для этого типового выражения не реализован.
]

#rule-h(<type.expr.union>)
=== Типовое выражение объединения

#figure(
  ```antlr
  typeExpr:
      ...
      |   lhs=typeExpr PIPE rhs=typeExpr # TypeExprUnion
      ...
  ```,
)

#figure(
  railroad(
    ```
    [
      `union-type-expr`
      'type-expr'
      "|"
      'type-expr'
    ]
    ```,
  )
)

#rule(<type.expr.union.intro>)
#def("union-type-expr")[Типовое выражение объединения] позволяет указать @def:union-type[тип-объединение].

#rule(<type.expr.union.type>)
Пусть $L$ и $R$ — типы, задаваемые типовыми подвыражениями.
Тогда типовое выражение объединения задаёт тип $"union"(L, R)$, где $"union"$ обозначает операцию @def:type-union[объединения типов].

#rule-h(<type.infer>)
== Вывод и проверка типов

#rule(<type.infer.intro>)
LibSL обладает ограниченным механизмом автоматического вывода типов.
Например, тип @def:local-variable[локальных переменных] может быть установлен автоматически.
Вывод типов также применяется при @def:overload-resolution[разрешении перегрузок].

Вывод типов — составная часть анализа типов.
Задачей вывода типов является установить тип каких-либо синтаксических конструкций языка.
Помимо него также производится проверка типов на соответствие ограничениям синтаксических конструкций.

Вывод и проверка типов описываются в терминах @def:type-constr[типовых ограничений].
Они устанавливают отношения, которые должны выполняться между типами.

#rule(<type.infer.extended-type>)
Для задачи вывода семейство типов дополняется #def("infer-var")[Типовая переменная][типовыми переменными], которые обозначают неизвестные типы.
#def("extended-type")[Расширенный тип][Расширенные типы] — те, в которых могут фигурировать типовые переменные.
#def("proper-type")[Собственный тип][Собственным типом] называется такой, который не содержит типовых переменных.

В данной спецификации типовые переменные обозначаются греческими буквами (например, #type-expr($α$)).

#rule(<type.infer.extended-type-arg>)
Аналогично расширенному типу вводится понятие #def("extended-type-arg")[Расширенный типовой аргумент][расширенного типового аргумента] — @def:type-arg[типовой аргумент], в котором могут фигурировать типовые переменные.

#rule(<type.infer.constr-system>)
Набор типовых ограничений образует #def("type-constr-system")[Система типовых ограничений][систему типовых ограничений].
В ходе вывода типов эвристическим способом производится поиск её решения.
#def("type-constr-system-solution")[Решение системы типовых ограничений] — подстановка, заменяющая все типовые переменные на собственные типы, которая не нарушает типовые ограничения системы.
#def("partial-type-constr-system-solution")[Частичное решение системы типовых ограничений] — подстановка, заменяющая часть типовых переменных на собственные типы, которая не нарушает типовые ограничения системы.

#def("extended-type-solution")[Решение расширенного типа] — собственный тип, получаемый применением @def:type-subst[подстановки] — решения системы типовых ограничений — к расширенному.

#rule(<type.infer.constr-system.sat>)
Система типовых ограничений, имеющая решение, называется #def("type-constr-system-satisfiability")[Выполнимая система типовых ограничений][выполнимой].

#rule(<type.infer.scope>)
Вывод типов производится только в пределах одной @def:fn-entity[функциональной сущности].
Решение системы типовых ограничений производится после порождения ограничений для всего тела, а также в процессе анализа отдельных выражений, для которых необходима информация о собственном типе.
В последнем случае производится частичное решение системы для переменных, которые присутствуют в расширенном типе.

Для каждой функциональной сущности составляется единая система типовых ограничений.
Могут также составляться #def("specific-type-constr-system")[Частная система типовых ограничений][частные системы типовых ограничений], которые к ограничениям единой системы добавляют другие.
Решение частных систем производится независимо как друг от друга, так и от единой системы.

#rule(<type.infer.error>)
Единая система типовых ограничений должна быть выполнимой.
#sema-err-def[Невыполнимость единой системы типовых ограничений][Несуществование её решения — семантическая ошибка.]
Эта ошибка также называется #def("type-error")[Ошибка типизации][ошибкой типизации].

Алгоритм вывода типов консервативен.
Это означает, что он может не найти решения системы типовых ограничений, даже если оно существует.

#note[
  Иначе говоря, в программах, которые могли бы быть корректно типизированы, могут быть обнаружены ложные ошибки типизации.
  Чтобы их устранить, можно предоставить больше типовой информации: например, явно задать типы у локальных переменных.
]

#rule-h(<type.infer.constr>)
=== Типовые ограничения

#rule(<type.infer.constr.intro>)
#def("type-constr")[Типовое ограничение] — отношение между @def:extended-type[расширенными типами].
Имеются следующие типовые ограничения:

#rule(<type.infer.constr.eq>)
/ Равенство типов:
  Записывается как $T = U$.
  Требует, чтобы @def:extended-type-solution[решения] $T$ и $U$ были @def:type-eq[равны].

#rule(<type.infer.constr.sub>)
/ Подтипизация:
  Записывается как $T <: U$.
  Требует, чтобы @def:extended-type-solution[решение] $T$ было @def:type-sub[подтипом] решения $U$.

#rule(<type.infer.constr.coerce>)
/ Неявная приводимость:
  Записывается как $T --> U$.
  Требует, чтобы @def:extended-type-solution[решение] $T$ было @def:type-coerce[неявно приводимо] к решению $U$.

#rule(<type.infer.constr.expr>)
Для ряда @def:expr[выражений] справедливо, что в отрыве от контекста им можно назначить различные типы.
Например, @def:array-lit-expr[выражение литерала массива] `[]` имеет тип #type-expr(ctor(builtin-types.array)($T$)), где $T$ — некоторый тип элемента.
В таких случаях создаётся новая @def:infer-var[типовая переменная] $α$, которая заменяет неизвестный тип.
Тогда при выводе типа такого выражения ему назначается расширенный тип #type-expr(ctor(builtin-types.array)($α$)).

Некоторые синтаксические конструкции требуют, чтобы выражения #def("expr-conformity")[Соответствие выражения типу][соответствовали] какому-либо типу $R$.
В таком случае порождается типовое ограничение $T --> R$, где $T$ — расширенный тип выражения.
При вычислении выражения его значения при этом автоматически @def:cast[приводится] к типу $R$.
