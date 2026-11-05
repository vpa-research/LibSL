#import "../meta.typ": *
#import "../types.typ": *

#rule-h(<name>)
= Имена

#rule(<name.intro>)
#def("entity")[Сущность][Сущностью] является языковая конструкция, к которой можно обратиться каким-либо образом из @def:module[модуля].
@def:decl[Объявления] позволяют присвоить сущностям #def("name")[Имя][имена] — их символическое обозначение.

Имена определяются только в пределах @def:scope[областей видимости], внутри которых они позволяют обратиться к обозначаемой сущности.
В LibSL имеется несколько @def:namespace[пространств имён], соответствующие различным контекстам использования имён.
В разных пространствах имён одно и то же имя может соответствовать различным сущностям.

#rule-h(<name.ns>)
== Пространства имён

#rule(<name.ns.intro>)
#def("namespace")[Пространство имён] — категория @def:name[имён], соответствующая определённому контексту их использования.
Различные пространства имён содержат различные виды сущностей.
Одно и то же имя может использоваться в различных пространствах имён для обозначения различных сущностей.

#rule(<name.ns.kinds>)
Существуют следующие пространства имён:

#rule(<name.ns.kinds.type>)
/ Пространство имён типов:
  - Встроенные @def:type-constructor[конструкторы типов] (@name.builtin.types)
  - @def:semantic-types-decl[Объявления семантических типов]
  - @def:type-alias-decl[Объявления псевдонимов типов]
  - @def:struct-decl[Объявления структурных типов]
  - @def:enum-decl[Объявления перечислимых типов]
  - @def:type-param[Типовые параметры]

#rule(<name.ns.kinds.automaton>)
/ Пространство имён автоматов:
  - @def:automaton-decl[Объявления автоматов]

#rule(<name.ns.kinds.function>)
/ Пространство имён функциональных сущностей:
  - @def:struct-constructor[Конструкторы значений типов]
  - @def:function-decl[Объявления функций]
  - @def:constructor-decl[Объявления функций-конструкторов]
  - @def:destructor-decl[Объявления функций-деструкторов]
  - @def:proc-decl[Объявления процедур]
  - @def:pred-decl[Объявления функциональных предикатов]

#rule(<name.ns.kinds.variable>)
/ Пространство имён переменных:
  - Параметры @def:fn-entity[функциональных сущностей]
  - Значения @def:enum-decl[перечислимых типов]
  - @def:variable-decl[Объявления переменных], включая @def:field[поля]
  - Параметры @def:annotation-decl[аннотаций]
  - Параметры @def:action-decl[семантических действий]

#rule(<name.ns.kinds.annotation>)
/ Пространство имён аннотаций:
  - Встроенные @def:annotation[аннотации] (@annotation.builtin)
  - @def:annotation-decl[Объявления аннотаций]

#rule(<name.ns.kinds.action>)
/ Пространство имён семантических действий:
  - @def:action-decl[Объявления семантических действий]

#rule(<name.ns.kinds.state>)
/ Пространство имён состояний:
  - @def:state-decl[Объявления состояний]

#rule(<name.ns.kinds.contract>)
/ Пространство имён контрактов:
  - @def:named-pred[Именованные предикаты]

#rule-h(<name.scope>)
== Область видимости

#rule(<name.scope.intro>)
#def("scope")[Область видимости] задаёт отображение между @def:name[именами] из @def:namespace[пространств имён] и соответствующими им @def:entity[сущностями].

#rule(<name.scope.duplicates>)
В пределах одной области видимости может иметься не более одного соответствия между @def:name[именем] в некотором @def:namespace[пространстве имён] и @def:entity[сущностью], за исключением пространства имён функциональных сущностей.
#sema-err-def[Повторное объявление][Попытка объявить сущность, нарушающая это требование, — семантическая ошибка.]

#rule(<name.scope.nesting>)
Область видимости может быть вложена в другую.
Область видимости $A$ #def("scope-containment")[Отношение содержания областей видимости][содержит] область видимости $C$, если выполняется любое из требований:
+ $A = C$;
+ $C$ вложена в $A$;
+ $A$ содержит область видимости $B$, в которую вложена $C$.

#note[
  Иначе говоря, отношение содержания областей видимости — транзитивное замыкание отношения вложенности.

  Отношение содержания является отношением частичного порядка.
]

#rule(<name.scope.current>)
#def("current-scope")[Текущая область видимости] определяет, какие имена доступны в @def:expr[выражениях], @def:type-expr[типовых выражениях] и @def:stmt[командах] при использовании @def:recursive-name-resolution[рекурсивного разрешения имён], а также область видимости, в которую добавляются @def:decl[объявления].

#rule(<name.scope.method>)
Следующие области видимости называются #def("method-scope")[Область видимости методов][областями видимости методов]:
- @def:member-scope
- @def:instance-scope

#rule-h(<name.scope.prelude>)
=== Область видимости встроенных объявлений

#def("prelude-scope")[Область видимости встроенных объявлений] содержит объявления, встроенные в язык (@name.builtin).
Она является корневой для остальных областей видимости.

#rule-h(<name.scope.import>)
=== Область видимости импортов

Для каждого @def:source-file[исходного файла] создаётся отдельная #def("import-scope")[Область видимости импортов][область видимости импортов].
В неё вносятся все импортированные объявления (@name.import).

#rule(<name.scope.import.parent>)
Область видимости импортов вложена в @def:prelude-scope[область видимости встроенных объявлений].

#rule-h(<name.scope.file>)
=== Область видимости файла

Для каждого @def:source-file[исходного файла] создаётся отдельная #def("file-scope")[Область видимости файла][область видимости файла].
В неё вносятся сущности, создаваемые @def:global-decl[глобальными объявлениями].

#rule(<name.scope.file.parent>)
Область видимости файла вложена в @def:import-scope[область видимости импортов] этого файла.

#rule-h(<name.scope.member>)
=== Область видимости ассоциированных сущностей

#def("member-scope")[Область видимости ассоциированных сущностей] содержит сущности, связанные с другими сущностями в @def:namespace[пространстве имён] типов.
Доступ к сущностям, расположенным в данной области видимости, осуществляется посредством @def:member-expr[выражения обращения к ассоциированной сущности].

#rule-h(<name.scope.instance>)
=== Область видимости элементов экземпляра

#def("instance-scope")[Область видимости элементов экземпляра] содержит сущности, связанные с @def:object[объектом] какой-либо сущности.
@def:fn-entity[Функциональные сущности], объявленные в ней, являются нестатическими @def:method[методами] объекта, а @def:variable-decl[объявления переменных] — его полями.
Доступ к ним осуществляется посредством выражений @def:call-expr[вызова] и @def:field-expr[обращения к полю].

#rule-h(<name.scope.params>)
=== Область видимости параметров

#def("param-scope")[Область видимости параметров] содержит параметры (в том числе @def:type-param[типовые]) сущностей.

#rule-h(<name.scope.block>)
=== Область видимости блока

#def("block-scope")[Область видимости блока] содержит локальные определения, например @def:local-variable[локальные переменные].

#rule-h(<name.import>)
== Импорты

#rule(<name.import.intro>)
Посредством @def:import-decl[объявлений импортов] сущности, объявленные в другом файле по заданному пути, могут быть импортированы в текущий.

Импортирование означает размещение в @def:import-scope[области видимости импортов] файла, содержащего объявление импорта, нового соответствия между именем и сущностью.
Имя, сущность и пространство имён, с которыми соответствие добавляется, те же, что и для объявления импортируемой сущности.

#rule(<name.import.export-scope>)
Сущности импортируются из @def:file-scope[области видимости файла] по заданному пути.

#note[
  Это означает, что импортирование нетранзитивно: если файл A импортирует B, а файл B импортирует C, то первому файлу не будут доступны определения последнего.
]

#rule(<name.import.duplicates>)
На импорты распространяется ограничение из @name.scope.duplicates.

#note[
  Если два файла определяют сущность с тем же именем (в одном и том же пространстве имён), импортировать их одновременно не получится.
]

#rule(<name.import.cycle>)
Циклическое импортирование файлов позволяется.

#note[
  В частности, допускается импортирование файла в самого себя.
]

#rule-h(<name.builtin>)
== Встроенные объявления

В @def:prelude-scope[области видимости встроенных объявлений] язык объявляет следующие сущности:

#rule(<name.builtin.types>)
/ Пространство имён типов:
  - #type-expr(builtin-types.int8)
  - #type-expr(builtin-types.int16)
  - #type-expr(builtin-types.int32)
  - #type-expr(builtin-types.int64)
  - #type-expr(builtin-types.unsigned8)
  - #type-expr(builtin-types.unsigned16)
  - #type-expr(builtin-types.unsigned32)
  - #type-expr(builtin-types.unsigned64)
  - #type-expr(builtin-types.float32)
  - #type-expr(builtin-types.float64)
  - #type-expr(builtin-types.bool)
  - #type-expr(builtin-types.char)
  - #type-expr(builtin-types.string)
  - #type-expr(builtin-types.void)
  - #type-expr(builtin-types.any)
  - #type-expr(builtin-types.nothing)
  - #type-expr(builtin-types.array)
  - #type-expr(builtin-types.set)

#rule(<name.builtin.annotations>)
/ Пространство имён аннотаций:
  - `@intrinsic` (@annotation.builtin.intrinsic)

#rule-h(<name.resolution>)
== Разрешение имён

#rule(<name.resolution.intro>)
#def("name-resolution")[Разрешение имён] — процесс, определяющий соответствие между именем @def:ident[идентификатора] и @def:entity[сущностью], на которую он указывает.

Разрешение имён в @def:namespace[пространствах имён] функциональных сущностей производится на основании информации об их использовании: типов аргументов, их количестве, способу вызова и т. д.
Данный механизм называется @def:overload-resolution[разрешением перегрузок] (@name.resolution.overload).
Этот же механизм применяется для разрешения перегрузок операторных выражений (@expr.op.resolution).

Разрешение остальных имён производится при помощи @def:local-name-resolution[локального разрешения] и @def:recursive-name-resolution[рекурсивного разрешения].

#rule(<name.resolution.fail>)
Разрешение имён может завершиться с ошибкой.
В таком случае оно считается #def("failed-name-resolution")[Неудачное разрешение имени][неудачным].
#sema-err-def[Неудачное разрешение имени][Неудачное разрешение имени — семантическая ошибка.]

#rule-h(<name.resolution.local>)
=== Локальное разрешение имён

#rule(<name.resolution.local.intro>)
#def("local-name-resolution")[Локальное разрешение имени] производит разрешение имени в пределах одной @def:scope[области видимости].
Механизм используется в @def:call-expr[выражении вызова], @def:field-expr[выражении обращения к полю] и @def:member-expr[выражении обращения к ассоциированной сущности].

#rule(<name.resolution.local.fn>)
Локальное разрешение имён не определено для @def:namespace[пространства имён] функциональных сущностей.

#rule(<name.resolution.local.procedure>)
Локальное разрешение имени $"name"$ в @def:namespace[пространстве имён] $"ns"$ @def:scope[области видимости] $"scope"$ осуществляется следующим образом:

#algorithm(
  {
    import algorithmic: *

    Procedure(
      "local-resolve",
      ("name", "ns", "scope"),
      {
        IfElseChain(
          $"scope"(("ns", "name")) != tack.t$,
          {
            Return[$"scope"(("ns", "name"))$]
          },
          {
            Fail
          },
        )
      }
    )
  }
)

#rule(<name.resolution.local.fail>)
Если алгоритм завершается с результатом #Fail.at(0), локальное разрешение имени считается @def:failed-name-resolution[неуспешным].

#rule-h(<name.resolution.recursive>)
=== Рекурсивное разрешение имён

#rule(<name.resolution.recursive.intro>)
#def("recursive-name-resolution")[Рекурсивное разрешение имени] производит разрешение имени в @def:scope[областях видимости], @def:scope-containment[содержащих] данную.

#rule(<name.resolution.recursive.fn>)
Рекурсивное разрешение имён не определено для @def:namespace[пространства имён] функциональных сущностей.

#rule(<name.resolution.recursive.procedure>)
Рекурсивное разрешение имени $"name"$ в @def:namespace[пространстве имён] $"ns"$ начальной @def:scope[области видимости] $"scope"$ осуществляется следующим образом:

#algorithm(
  {
    import algorithmic: *

    Procedure(
      "recursive-resolve",
      ("name", "ns", "scope"),
      {
        IfElseChain(
          $"scope"(("ns", "name")) != tack.t$,
          {
            Return[$"scope"(("ns", "name"))$]
          },
          $exists p: "scope" "вложена в" p$,
          {
            Return(Call("recursive-resolve", ("name", "ns", $p$)))
          },
          {
            Fail
          },
        )
      }
    )
  }
)

#rule(<name.resolution.recursive.fail>)
Если алгоритм завершается с результатом #Fail.at(0), локальное разрешение имени считается @def:failed-name-resolution[неуспешным].

#rule-h(<name.resolution.overload>)
=== Разрешение перегрузок

#rule(<name.resolution.overload.intro>)
В @def:namespace[пространстве имён] функциональных сущностей позволяется определять несколько сущностей с одинаковым именем.
Сущности одним и тем же именем называются #def("overload")[Перегрузка имени][перегрузками] имени.

#def("overload-resolution")[Разрешение перегрузок] производит поиск и выбор перегрузки среди найденных в каждом месте использования.
Оно состоит из двух последовательных этапов:

+ поиска перегрузок-кандидатов (@name.resolution.overload.search);
+ выбора перегрузки (@name.resolution.overload.selection).

#rule-h(<name.resolution.overload.signature>)
==== Сигнатура перегрузки

#rule(<name.resolution.overload.signature.intro>)
Каждая перегрузка характеризуется #def("overload-signature")[Сигнатура перегрузки][сигнатурой перегрузки], состоящей из:
+ опциональной @def:object-entity[объектной сущности]\;
+ набора @def:type-param[типовых параметров]\;
+ типов параметров.

#rule(<name.resolution.overload.signature.fn>)
Для @def:fn-entity[функциональных сущностей] сигнатура определяется следующим образом:

/ @def:object-entity:
  Присутствует и равна $E_"obj"$, если функциональная сущность является @def:method[методом] $E_"obj"$.
  Иначе отсутствует.

/ @def:type-param[Типовые параметры]:
  Те же, что и у функциональной сущности.

/ Типы параметров:
  Те же, что и у функциональной сущности.

#rule(<name.resolution.overload.signature.op>)
Для перегрузок операторов операторных выражений (@expr.op) сигнатура определяется следующим образом:

/ @def:object-entity:
  Отсутствует.

/ @def:type-param[Типовые параметры]:
  Задаются перегрузкой.

/ Типы параметров:
  Задаются перегрузкой.

#rule-h(<name.resolution.overload.candidates>)
==== Кандидаты

#rule(<name.resolution.overload.candidates.intro>)
Поиск перегрузок происходит с учётом места их использования.
Место использования характеризуется #def("overload-use-signature")[Сигнатура места использования перегрузки][сигнатурой места использования перегрузки], состоящей из:
+ @def:receiver[указания объекта]\;
+ @def:extended-type-arg[расширенных типовых аргументов]\;
+ @def:extended-type[расширенных типов] аргументов.

#rule(<name.resolution.overload.candidates.receiver>)
#def("receiver")[Указание объекта] в месте использования может отсутствовать либо иметь один из следующих видов:
+ явный;
+ неявный.

В случае наличия указание объекта характеризуется @def:extended-type[расширенным типом] @def:object[объекта].

#rule(<name.resolution.overload.candidates.applicability>)
@def:overload[Перегрузка] с @def:overload-signature[сигнатурой] $s$ #def("overload-applicability")[Подходимость перегрузки к месту использования][подходит] к месту использования с @def:overload-use-signature[сигнатурой] $t$, если выполнены все нижеперечисленные условия:

+ Число @def:type-param[типовых параметров] $s$ не меньше числа @def:extended-type-arg[расширенных типовых аргументов] $t$.

+ Число параметров $s$ равно числу аргументов $t$.

+ Если $s$ содержит тип @def:object[объекта], $t$ содержит @def:receiver[указание объекта].

+ Если $s$ не содержит тип @def:object[объекта], $t$ не содержит @def:receiver[указание объекта] либо указание объекта имеет неявный вид.

+ Пусть:

  - $F_1, ..., F_k$ — @def:type-param[типовые параметры] $s$;

  - $α_1, ..., α_k = "instantiate"(F_1, ..., F_k)$, где $"instantiate"$ обозначает операцию @def:type-param-instantiation[инстанцирования типовых параметров]\;

  - $T_1, ..., T_l$ — @def:extended-type-arg[расширенные типовые аргументы] $t$;

  - если $s$ имеет @def:object-entity[объектную сущность] $E_"obj"$:

    - $O = "object-type"(E_"obj", "Var")$, где $"object-type"$ обозначает операцию @def:object-type[получения типа объекта]\;

  - если $t$ имеет @def:receiver[указание объекта]:

    - $R$ — @def:extended-type[расширенный тип] указания объекта;

  - $P_1, ..., P_m$ — типы параметров $s$;

  - $Q_i = P_i [F_1 mapsto α_1, ..., F_k mapsto α_k]$ для $i in {1, ..., m}$, где квадратные скобки обозначают операцию @def:type-subst[подстановки типов]\;

  - $A_1, ..., A_m$ — @def:extended-type[расширенные типы] аргументов $t$.

  Тогда @def:specific-type-constr-system[частная система типовых ограничений], дополненная следующими @def:type-constr[ограничениями], @def:type-constr-system-satisfiability[выполнима]:

  + $α_i = T_i$ для $i in {1, ..., l}$.

  + Если $s$ имеет @def:object-entity[объектную сущность] и $t$ имеет @def:receiver[указание объекта]:

    + $R <: O$.

  + $A_i => P_i [F_1 mapsto α_1, ..., F_k mapsto α_k]$ для $i in {1, ..., m}$.

+ Перегрузка удовлетворяет требованиям на вид сущности.

  #explanation[
    Например, @def:call-expr[выражение вызова] требует, чтобы сущность была @def:proc-decl[процедурой] или @def:pred-decl[функциональным предикатом].
    Тогда если перегрузка соответствует @def:function-decl[функции], то она не будет подходить ни к какому месту использования, соответствующему такому выражению.
  ]

#def("overload-candidate")[Перегрузка-кандидат] — @def:overload[перегрузка], которая @def:overload-applicability[подходит] к месту использования.

#note[
  Тип возвращаемого значения не имеет значения при разрешении перегрузок.
]

#rule-h(<name.resolution.overload.search>)
==== Поиск кандидатов

#rule(<name.resolution.overload.search.intro>)
Этап поиска кандидатов осуществляет построение #def("candidate-set")[Множество кандидатов][множества кандидатов], содержащего все @def:overload-candidate[кандидаты], среди которых осуществляется выбор.
Процедура поиска зависит от контекста, который вызывает разрешение перегрузок.

#rule-h(<name.resolution.overload.search.unqual-callee>)
===== Поиск кандидатов для неквалифицированного вызова

#rule(<name.resolution.overload.search.unqual-callee.intro>)
Поиск кандидатов для неквалифицированного вызова применяется для построения @def:candidate-set[множества кандидатов] неквалифицированной формы @def:call-expr[выражения вызова] (@expr.call.unqualified).
Перегрузками в этом случае могут являться @def:proc-decl[процедуры] и @def:pred-decl[функциональные предикаты].

#rule(<name.resolution.overload.search.unqual-callee.use-signature>)
@def:overload-use-signature[Сигнатура места использования перегрузки] для такого выражения $e$ задаётся следующим образом:

#rule(<name.resolution.overload.search.unqual-callee.use-signature.recv>)
/ @def:receiver:
  Если определён $"object-type"(e, #smallcaps[Param])$ (где $"object-type"$ обозначает операцию @def:object-type[получения типа объекта]), то указание объекта присутствует в неявной форме, а полученный тип является @def:extended-type[расширенным типом] @def:object[объекта].

  В противном случае указание объекта отсутствует.

#rule(<name.resolution.overload.search.unqual-callee.use-signature.type-args>)
/ @def:extended-type-arg[Расширенные типовые аргументы]:
  Определяются на основании @def:type-arg[типовых аргументов] выражения.

#rule(<name.resolution.overload.search.unqual-callee.use-signature.args>)
/ @def:extended-type[Расширенные типы] аргументов:
  Определяются из анализа типов аргументов выражения.

#rule(<name.resolution.overload.search.unqual-callee.procedure>)
Поиск кандидатов для неквалифицированного вызова с именем $"name"$ для @def:call-expr[выражения вызова], @def:current-scope[текущей областью видимости] которого является $"scope"$, с @def:overload-use-signature[сигнатурой места использования] $t$ происходит следующим образом:

#algorithm(
  {
    import algorithmic: *

    Procedure(
      "method-candidates",
      ($E_"obj"$, "name", $t$),
      {
        Assign[$C$][$emptyset$]
        If(
          [$t$ имеет @def:receiver[указание объекта] типа $R$],
          {
            If(
              [$E_"obj"$ имеет @def:instance-scope[область видимости элементов экземпляра] $"scope"$],
              {
                If(
                  $"scope"(("Function", "name")) != tack.t$,
                  {
                    Assign[$C$][${c in "scope"(("Function", "name")) : c #[@def:overload-applicability[подходит к]] t}$]
                  },
                )
              },
            )
          },
        )

        If(
          [$E_"obj"$ имеет @def:member-scope[область видимости ассоциированных сущностей] $"scope"$],
          {
            If(
              $"scope"(("Function", "name")) != tack.t$,
              {
                Assign[$C$][$C #sym.union {c in "scope"(("Function", "name")) : c #[@def:overload-applicability[подходит к]] t}$]
              },
            )
          },
        )

        Return[$C$]
      },
    )

    LineBreak

    Procedure(
      "build-unqualified-call-candidate-set",
      ("name", "scope", $t$),
      {
        IfElseChain(
          [$"scope"$ — @def:method-scope[область видимости методов] @def:object-entity[объектной сущности] $E_"obj"$],
          {
            Assign($C$, CallInline("method-candidates", ($E_"obj"$, "name", $t$)))
          },
          $"scope"(("Function", "name")) != tack.t$,
          {
            Assign[$C$][${c in "scope"(("Function", "name")) : c #[@def:overload-applicability[подходит к]] t}$]
          },
          {
            Assign[$C$][$emptyset$]
          },
        )

        LineBreak

        IfElseChain(
          $C != emptyset$,
          {
            Return[$C$]
          },
          $exists p: "scope" "вложена в" p$,
          {
            Return(Call("build-unqualified-call-candidate-set", ("name", $p$, $t$)))
          },
          {
            Fail
          }
        )
      }
    )
  }
)

#rule(<name.resolution.overload.search.unqual-callee.fail>)
Если алгоритм завершается с результатом #Fail.at(0) (множество кандидатов пусто), разрешение перегрузок считается @def:failed-name-resolution[неуспешным].

#rule-h(<name.resolution.overload.search.scope-callee>)
===== Поиск кандидатов для вызова, квалифицированного областью видимости

#rule(<name.resolution.overload.search.scope-callee.intro>)
Поиск кандидатов для вызова, квалифицированного областью видимости, применяется для построения @def:candidate-set[множества кандидатов] формы @def:call-expr[выражения вызова], квалифицированной @def:scope[областью видимости] (@expr.call.scope-qualified).
Перегрузками в этом случае могут являться @def:proc-decl[процедуры] и @def:pred-decl[функциональные предикаты].

#rule(<name.resolution.overload.search.scope-callee.use-signature>)
@def:overload-use-signature[Сигнатура места использования перегрузки] для такого выражения задаётся следующим образом:

#rule(<name.resolution.overload.search.scope-callee.use-signature.recv>)
/ @def:receiver:
  Отсутствует.

#rule(<name.resolution.overload.search.scope-callee.use-signature.type-args>)
/ @def:extended-type-arg[Расширенные типовые аргументы]:
  Определяются на основании @def:type-arg[типовых аргументов] выражения.

#rule(<name.resolution.overload.search.scope-callee.use-signature.args>)
/ @def:extended-type[Расширенные типы] аргументов:
  Определяются из анализа типов аргументов выражения.

#rule(<name.resolution.overload.search.scope-callee.procedure>)
Поиск кандидатов для вызова, квалифицированного областью видимости, с именем $"name"$ для @def:call-expr[выражения вызова], разрешённой @def:scope[областью видимости] префикса которого является $"scope"$, с @def:overload-use-signature[сигнатурой места использования] $t$ происходит следующим образом:

#algorithm(
  {
    import algorithmic: *

    Procedure(
      "build-scope-qualified-call-candidate-set",
      ("name", "scope", $t$),
      {
        IfElseChain(
          $"scope"(("Function", "name")) != tack.t$,
          {
            Assign[$C$][${c in "scope"(("Function", "name")) : c #[@def:overload-applicability[подходит к]] t}$]
          },
          {
            Assign[$C$][$emptyset$]
          }
        )

        LineBreak

        IfElseChain(
          $C != emptyset$,
          {
            Return[$C$]
          },
          {
            Fail
          }
        )
      }
    )
  }
)

Процедура #smallcaps[method-candidates] определяется в @name.resolution.overload.search.unqual-callee.procedure.

#rule(<name.resolution.overload.search.scope-callee.fail>)
Если алгоритм завершается с результатом #Fail.at(0) (множество кандидатов пусто), разрешение перегрузок считается @def:failed-name-resolution[неуспешным].

#rule-h(<name.resolution.overload.search.recv-callee>)
===== Поиск кандидатов для вызова, квалифицированного объектом метода

#rule(<name.resolution.overload.search.recv-callee.intro>)
Поиск кандидатов для вызова, квалифицированного объектом метода, применяется для построения @def:candidate-set[множества кандидатов] формы @def:call-expr[выражения вызова], квалифицированной @def:object[объектом] метода (@expr.call.receiver-qualified).
Перегрузками в этом случае могут являться @def:proc-decl[процедуры] и @def:pred-decl[функциональные предикаты].

#rule(<name.resolution.overload.search.recv-callee.use-signature>)
@def:overload-use-signature[Сигнатура места использования перегрузки] для такого выражения задаётся следующим образом:

#rule(<name.resolution.overload.search.recv-callee.use-signature.recv>)
/ @def:receiver:
  Присутствует в явной форме с типом объекта выражения вызова.

#rule(<name.resolution.overload.search.recv-callee.use-signature.type-args>)
/ @def:extended-type-arg[Расширенные типовые аргументы]:
  Определяются на основании @def:type-arg[типовых аргументов] выражения.

#rule(<name.resolution.overload.search.recv-callee.use-signature.args>)
/ @def:extended-type[Расширенные типы] аргументов:
  Определяются из анализа типов аргументов выражения.

#rule(<name.resolution.overload.search.recv-callee.procedure>)
Поиск кандидатов для вызова, квалифицированного объектом метода, с именем $"name"$ для @def:call-expr[выражения вызова], @def:current-scope[текущей областью видимости] которого является $"scope"$, с @def:overload-use-signature[сигнатурой места использования] $t$ происходит следующим образом:

#algorithm(
  {
    import algorithmic: *

    Procedure(
      "build-receiver-qualified-call-candidate-set",
      ("name", "scope", $t$),
      {
        Assign[$R$][тип @def:receiver[указания объекта] $t$]
        IfElseChain(
          [$R$ — тип @def:object[объекта] @def:object-entity[объектной сущности] $E_"obj"$],
          {
            Assign($C$, Call("method-candidates", ($E_"obj"$, "name", $t$)))
          },
          {
            Assign[$C$][$emptyset$]
          }
        )

        LineBreak

        IfElseChain(
          $C != emptyset$,
          {
            Return[$C$]
          },
          {
            Fail
          }
        )
      }
    )
  }
)

Процедура #smallcaps[method-candidates] определяется в @name.resolution.overload.search.unqual-callee.procedure.

#rule(<name.resolution.overload.search.recv-callee.fail>)
Если алгоритм завершается с результатом #Fail.at(0) (множество кандидатов пусто), разрешение перегрузок считается @def:failed-name-resolution[неуспешным].

#rule-h(<name.resolution.overload.search.op>)
===== Поиск кандидатов для операторного выражения

#rule(<name.resolution.overload.search.op.intro>)
Поиск кандидатов для операторного выражения применяется для построения @def:candidate-set[множества кандидатов] операторного выражения (@expr.op).

#rule(<name.resolution.overload.search.op.use-signature>)
@def:overload-use-signature[Сигнатура места использования перегрузки] для такого выражения задаётся следующим образом:

#rule(<name.resolution.overload.search.op.use-signature.recv>)
/ @def:receiver:
  Отсутствует.

#rule(<name.resolution.overload.search.op.use-signature.type-args>)
/ @def:extended-type-arg[Расширенные типовые аргументы]:
  Отсутствуют.

#rule(<name.resolution.overload.search.op.use-signature.args>)
/ @def:extended-type[Расширенные типы] аргументов:
  Определяются из анализа типов операндов выражения.

#rule(<name.resolution.overload.search.op.procedure>)
Поиск кандидатов для операторного выражения, оператор которого определяет множество перегрузок $S$, с @def:overload-use-signature[сигнатурой места использования] $t$ производится следующим образом:

#algorithm(
  {
    import algorithmic: *

    Procedure(
      "build-op-candidate-set",
      ($S$, $t$),
      {
        Assign[$C$][${c in S : c #[@def:overload-applicability[подходит к]] t}$]

        IfElseChain(
          $C != emptyset$,
          {
            Return[$C$]
          },
          {
            Fail
          },
        )
      }
    )
  }
)

#rule(<name.resolution.overload.search.op.fail>)
Если алгоритм завершается с результатом #Fail.at(0) (множество кандидатов пусто), разрешение перегрузок считается @def:failed-name-resolution[неуспешным].

#rule-h(<name.resolution.overload.selection>)
==== Выбор перегрузки

#rule(<name.resolution.overload.selection.intro>)
Этап выбора перегрузки определяет наиболее конкретную @def:overload[перегрузку] из @def:candidate-set[множества кандидатов].
Для этого на перегрузках устанавливается отношение строгого порядка $<$ (@name.resolution.overload.selection.order.strict).

#rule(<name.resolution.overload.procedure>)
Выбор перегрузки из @def:candidate-set[множества кандидатов] $C$ происходит следующим образом:

+ Если в множестве $C$ существует @def:overload-candidate[кандидат] $r$ такой, что

  $ forall c in C : r = c or r < c, $
  
  то выбор перегрузки завершается с результатом $r$.

+ Если в множестве $C$ присутствуют два кандидата $c_1$ и $c_2$ такие, что @def:overload-signature[сигнатура перегрузки] $c_1$ имеет типовые параметры, а $c_2$ — нет, то:

  + Пусть $C' = {c in C : #[сигнатура $c$ не имеет типовых параметров]}$.

  + Если в множестве $C'$ существует кандидат $r$ такой, что
  
    $ forall c in C' : r = c or r < c, $
    
    то выбор перегрузки завершается с результатом $r$.

+ На данном шаге множество кандидатов не содержит элементов или содержит эквивалентные конкретные перегрузки.
  Разрешение перегрузок в таком случае считается @def:failed-name-resolution[неуспешным].

#rule-h(<name.resolution.overload.selection.order>)
===== Отношение порядка на перегрузках

На @def:overload[перегрузках] вводится отношение $lt.tilde$ следующим образом.
Пусть $l$ и $r$ — две перегрузки, а $s_l$ и $s_r$ — их @def:overload-signature[сигнатуры].
$l lt.tilde r$, если $r$ @def:overload-applicability[применима] к $t$, где:

+ $F_1, ..., F_k$ — @def:type-param[типовые параметры] $l$;

+ $T_i = "clone-type-param"(F_i)$ для $i in {1, ..., k}$, где $"clone-type-param"$ обозначает операцию @def:clone-type-param[клонирования типовых параметров]\;

+ $P_1, ..., P_m$ — типы параметров $l$;

+ $Q_i = P_i [F_1 mapsto T_1, ..., F_k mapsto T_k]$ для $i in {1, ..., m}$, где квадратные скобки обозначают операцию @def:type-subst[подстановки типов]\;

+ @def:overload-use-signature[сигнатура места использования перегрузки] $t$ состоит из:

  / @def:receiver:
    Если $l$ имеет @def:object-entity[объектную сущность] $E_"obj"$, то указание объекта присутствует в явной форме с типом $"object-type"(E_"obj", "Param") [F_1 mapsto T_1, ..., F_k mapsto T_k]$, где $"object-type"$ обозначает операцию @def:object-type[получения типа объекта], а квадратные скобки — @def:type-subst[подстановки типов].
  
    В противном случае указание объекта отсутствует.
  
  / @def:extended-type-arg[Расширенные типовые аргументы]:
    Отсутствуют.
  
  / @def:extended-type[Расширенные типы] аргументов:
    $Q_1, ..., Q_m$.

#explanation[
  Определение синтезирует использование перегрузки на основании сигнатуры $l$ и проверяет, подходит ли оно к $r$.
  Например, если $l$ и $r$ — процедуры, то $l lt.tilde r$ означает, что в теле $l$ можно её аргументы перенаправить в вызов $r$.

  Для того, чтобы $l lt.tilde r$, $r$ должна быть не менее общей, чем $l$.
]

#note[
  Отношение $lt.tilde$ рефлексивно и транзитивно.
  Таким образом, оно является отношением предпорядка.
]

#rule(<name.resolution.overload.selection.order.strict>)
На перегрузках вводится строгое отношение порядка $<$ следующим образом: $l < r$, если $l lt.tilde r$, но $r lt.tilde.not l$.