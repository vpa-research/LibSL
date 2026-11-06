#import "../meta.typ": *
#import "../railroad.typ": railroad

#rule-h(<annotation>)
= Аннотации

#figure(
  ```antlr
  annotation
      :   AT name=ident
          (L_PAREN (args=annotationArgList COMMA?)? R_PAREN)?
      ;

  annotationArgList
      :   args+=annotationArg
          (COMMA args+=annotationArg)*
      ;

  annotationArg
      :   (name=ident EQ)?
          value=expr
      ;
  ```,
)

#figure(
  railroad(
    ```
    {
      [
        `annotation`
        "@"
        'ident'
      ],
      [
        "("
        [
          [
            [
              'ident'
              "="
            ]?
            'expr'
          ]*","
          ","?
        ]?
        ")"
      ]?
    }
    ```,
  )
)

#rule(<annotation.intro>)
#def("annotation")[Аннотация] — синтаксическая конструкция, которая позволяет добавить дополнительную информацию к элементам @def:module[модуля].

LibSL объявляет встроенные аннотации, семантика которых определена языком.
Дополнительные аннотации могут объявляться @def:processor[процессором], а также пользователем (@decl.annotation) непосредственно в модуле.
Их семантика задаётся @def:processor[процессором].

#rule(<annotation.arguments>)
Аргументы задают значения параметров аннотации.
Они могут опционально именоваться.

#rule(<annotation.arguments.positional>)
Неименованные аргументы задают значения параметров в том же порядке, в каком они присутствует в объявлении аннотации.

#rule(<annotation.arguments.named>)
Именованные аргументы задают значения параметров с соответствующими именами.

#rule(<annotation.arguments.named.end>)
Именованные аргументы должны располагаться в конце.
#sema-err-def[Расположение именованного аргумента аннотации перед неименованным][Расположение его перед неименованным — семантическая ошибка.]

#rule(<annotation.arguments.duplicate>)
#sema-err-def[Повторение аргумента аннотации][Наличие нескольких аргументов для одного и того же параметра — семантическая ошибка.]

#note[
  Это может возникнуть в следующих случаях:

  + У двух именованных аргументов одно и то же имя:

    ```libsl
    define annotation example(x: int32)
    @example(x = 42, x = 24)
    ```

  + Именованный аргумент задаёт значение параметра, для которого уже есть неименованный аргумент:

    ```libsl
    define annotation example(x: int32)
    @example(42, x = 24)
    ```
]

#rule(<annotation.arguments.missing>)
Для всех обязательных параметров аннотации должны быть предоставлены аргументы.
#sema-err-def[Недостаточное количество аргументов аннотации][Отсутствие аргумента для обязательного параметра — семантическая ошибка.]

#rule(<annotation.arguments.extraneous>)
#sema-err-def[Указание аргументов для несуществующих параметров аннотации][Наличие аргументов, не соответствующих каким-либо параметрам аннотации, — семантическая ошибка.]

#note[
  Данная ошибка соответствует следующим случаям:

  + Число неименованных аргументов превышает количество параметров:

    ```libsl
    define annotation example(x: int32)
    @example(1, 2, 3)
    ```

  + Имя именованного параметра не соответствует какому-либо параметру:

    ```libsl
    define annotation example(x: int32)
    @example(missing = 42)
    ```
]

#rule(<annotation.arguments.typing>)
Аргументы должны @def:expr-conformity[соответствовать] типам параметров.

#rule(<annotation.sites>)
В следующей таблице приведены места, где могут встречаться аннотации, а также @def:current-scope[текущая область видимости] для их аргументов и время их инициализации (@rt.init.annotation):

#{
  let anno-init = [Инициализация модуля]
  table(
    columns: 3,

    align: left + horizon,

    table.header[*Место*][*Текущая область видимости*][*Время инициализации*],

    [В @def:semantic-types-decl[объявлении семантического типа]],
    [Текущая область видимости для секции семантических типов],
    anno-init,

    [В @def:type-alias-decl[объявлении псевдонима типа]],
    [Текущая область видимости объявления],
    anno-init,

    [В @def:struct-decl[объявлении структурного типа]],
    [Текущая область видимости объявления],
    anno-init,

    [В @def:enum-decl[объявлении перечислимого типа]],
    [Текущая область видимости объявления],
    anno-init,

    [В @def:action-decl[объявлении семантического действия]],
    [Текущая область видимости объявления],
    anno-init,

    [У параметра в @def:action-decl[объявлении семантического действия]],
    [Текущая область видимости объявления],
    anno-init,

    [В @def:automaton-decl[объявлении автомата]],
    [Текущая область видимости объявления],
    anno-init,

    [У переменной конструктора в @def:automaton-decl[объявлении автомата]],
    [Текущая область видимости объявления автомата],
    anno-init,

    [В @def:function-decl[объявлении функции]],
    table.cell(breakable: false, rowspan: 6)[
      Если @def:fn-entity[функциональная сущность] является @def:method[методом], текущая область видимости объемлющего объявления.

      В противном случае текущая область видимости объявления функциональной сущности.
    ],
    anno-init,

    [В @def:constructor-decl[объявлении функции-конструктора]],
    anno-init,

    [В @def:destructor-decl[объявлении функции-деструктора]],
    anno-init,

    [В @def:proc-decl[объявлении процедуры]],
    anno-init,

    [В @def:pred-decl[объявлении функционального предиката]],
    anno-init,

    [У параметра @def:fn-entity[функциональной сущности]],
    anno-init,

    [В @def:variable-decl[объявлении переменной]],
    [
      Если переменная является @def:field[полем], текущая область видимости объемлющего объявления.

      В противном случае текущая область видимости объявления переменной.
    ],
    [
      Если переменная является @def:local-variable[локальной], исполнение @def:variable-decl-stmt[команды] или @def:pred-eval[вычисление] @def:variable-decl-pred[предиката].

      В противном случае инициализация модуля.
    ]
  )
}

#rule(<annotation.sites.restriction>)
У отдельных аннотаций этот список может быть сужен.
#sema-err-def[Использование аннотаций вне разрешённых синтаксических позиций][Использование таких аннотаций вне разрешённых позиций — семантическая ошибка.]

#rule-h(<annotation.builtin>)
== Встроенные аннотации

По умолчанию LibSL определяет следующие аннотации:
- `@intrinsic` (@annotation.builtin.intrinsic)

#rule-h(<annotation.builtin.intrinsic>)
=== Аннотация `@intrinsic`

#rule(<annotation.builtin.intrinsic.intro>)
Аннотация `@intrinsic` применяется для указания, что определение сущности предоставляется @def:processor[процессором].

#impl-spec(impls.rs)[
  Аннотация игнорируется и не проверяется.
]

#rule(<annotation.builtin.intrinsic.sites>)
Аннотация может применяться только в следующих позициях:

#rule(<annotation.builtin.intrinsic.sites.struct>)
/ @def:struct-decl:
  Применение аннотации означает, что содержание структурного типа задаётся @def:processor[процессором].

  #rule(<annotation.builtin.intrinsic.sites.struct.constructor>)
  Объявление структурного типа с аннотацией `@intrinsic` не имеет @def:struct-constructor[конструктора], а также доступных полей для @def:field-expr[выражения обращения к полю].

  #rule(<annotation.builtin.intrinsic.sites.struct.fields>)
  #sema-err-def[Объявление полей структурного типа с аннотацией `@intrinsic`][Объявление @def:variable-decl[полей] для такого структурного типа — семантическая ошибка.]

  #rule(<annotation.builtin.intrinsic.sites.struct.methods>)
  Аннотация не распространяется на определяемые @def:method[методы] структурного типа.

#rule(<annotation.builtin.intrinsic.sites.fn>)
/ Объявление @def:fn-entity[функциональной сущности]:
  Применение аннотации означает, что тело функциональной сущности задаётся @def:processor[процессором].

  #rule(<annotation.builtin.intrinsic.sites.fn.body>)
  #sema-err-def[Наличие тела у функциональной сущности с аннотацией `@intrinsic`][Присутствие непустого @def:fn-body[тела функциональной сущности] или @def:pred-body[тела функционального предиката] у такой функциональной сущности — семантическая ошибка.]

  #TODO[имеет ли смысл аннотация для функций?]
