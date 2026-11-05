#import "../meta.typ": *
#import "../railroad.typ": railroad
#import "../types.typ": type-expr, builtin-types, ctor, ptr

#rule-h(<expr>)
= Выражения

#rule(<expr.intro>)
#def("expr")[Выражение] — синтаксическая конструкция, которое производит @def:value[значение] в процессе #def("expr-eval")[Вычисление выражения][вычисления].

#rule(<expr.operand>)
Некоторые выражения содержат подвыражения.
Они называются его #def("expr-operand")[Операнд выражения][операндами].
Операнды нумеруются в порядке их следования в @def:source-file[исходном файле].

#rule(<expr.place>)
#def("place-eval")[Вычисление места] выражения производится для получения @def:assignee[места для присваивания].
Ряд выражений является #def("place-expr")[Выражение места][выражениями места]\; вычисление места для них выполняется по особым правилам:

#table(
  columns: (1fr, auto),

  table.header[*Выражение*][*Правило*],
  
  [@def:name-expr], [@expr.name.place],
  [@def:field-expr], [@expr.field.place],
  [@def:index-expr], [@expr.index.place],
)

#rule(<expr.place.derived>)
Часть выражений места получают место на основе места операнда.
Это место называется #def("derived-place")[Производное место][производным].

#rule(<expr.place.temporary>)
Для остальных выражений вычисление места производит вычисление значения.
Оно записывается во временную переменную.
Получаемое в результате место указывает на временную переменную.
Временная переменная имеет смысл только в пределах команды присваивания.

#explanation[
  Это правило применяется, когда выражение места вычисляет место операнда, который сам не является выражением места, как в следующем примере:

  ```libsl
  foo().field = 42;
  ```

  Для присваивания необходимо вычислить место выражения `foo().field`, для чего требуется место выражения `foo()`.
  Ему не соответствует какого-либо места в @def:exec-ctx[контексте исполнения], поэтому в соотвествии с правилом заводится временная переменная, как будто код был написан следующим образом:

  ```libsl
  var tmp = foo();
  tmp.field = 42;
  ```

  Однако @def:processor[процессору] позволяется, при сохранении прочих наблюдаемых эффектов вычисления, не выделять фактически места для переменной и игнорировать присваивание.
]

#rule(<expr.mutability>)
Выражения места могут быть #def("expr-mutability")[Изменяемое выражение][изменяемыми].
Это свойство контролирует возможность присваивания.

#rule(<expr.value-semantics>)
@def:expr-eval[Вычисление выражений] всегда порождает независимые значения.

#example[
  ```libsl
  struct Foo {
    val field: int32;
  }

  proc inner(y: Foo): int32 {
    y.field = 42;
    result = y.field;
  }

  proc outer(x: Foo): int32 {
    x.field = 24;
    result = inner(x);
    result += x.field;
  }
  ```

  Вызов `outer` со @def:struct-value[структурой] типа #type-expr(`Foo`) вернёт $24 + 42 = 66$.
  Вложенный вызов `inner` не изменяет содержимого `x` (значение `y` — независимое от `x`).
  Также присваивание внутри `outer` не изменяет значение, переданное в `outer` в качестве аргумента.

  Такое поведение называется семантикой значений (value semantics).
  Оно отличается от ссылочной семантики (reference semantics), как, например, у значений ссылочных типов в Java.
  В LibSL нет ссылочной семантики.
]

#rule(<expr.purity>)
Ряд выражений размещаются в #def("pure-context")[Чистый контекст][чистых контекстах], которые ограничивают сторонние эффекты вычислений.
В чистых контекстах разрешается использоваться только #def("pure-expr")[Чистое выражение][чистые] выражения.
Следующие выражения могут быть чистыми (быть может, при определённых условиях):
#let pure-exprs = state("pure-exprs", ())
#let pure-expr(lbl) = pure-exprs.update(exprs => exprs + (lbl,))
#context enum(tight: true, ..pure-exprs.final().map(it => [#it.]))

#rule(<expr.pred-permissible>)
Ряд выражений может составлять часть @def:pred[предикатов].
Такие выражения называются #def("pred-permissible-expr")[Допустимое в предикатах выражение][допустимыми в предикатах].
Следующие выражения могут быть допустимыми в предикатах (быть может, при определённых условиях):
#let pred-permissible-exprs = state("pred-permissible-exprs", ())
#let pred-permissible-expr(lbl) = pred-permissible-exprs.update(exprs => exprs + (lbl,))
#context enum(tight: true, ..pred-permissible-exprs.final().map(it => [#it.]))

#rule(<expr.simple>)
Ряд выражений называются #def("simple-expr")[Простое выражение][простыми].
Они могут использоваться как инициализирующие выражения глобальных переменных и аргументы аннотаций (@wf.init-expr).
Следующие выражения могут быть простыми (быть может, при определённых условиях):
#let simple-exprs = state("simple-exprs", ())
#let simple-expr(lbl) = simple-exprs.update(exprs => exprs + (lbl,))
#context enum(tight: true, ..simple-exprs.final().map(it => [#it.]))

#rule(<expr.kinds>)
В LibSL имеются следующие виды выражений (см. @expr-syntax):
#let exprs = state("exprs", ())
#let expr-def(name, ..args) = {
  def(name, ..args)
  exprs.update(exprs => exprs + (ref(label("def:" + name)),))
}
#context enum(tight: true, ..exprs.final().map(it => [#it.]))

#figure(
  ```antlr
  atomicExpr
      :   L_PAREN inner=atomicExpr R_PAREN # AtomicExprParen
      |   lit=primitiveLit # AtomicExprPrimitiveLit
      |   signedNumLit # AtomicExprSignedNumLit
      |   arrayLitExpr # AtomicExprArrayLit
      |   setLitExpr # AtomicExprSetLit
      |   name=ident # AtomicExprName
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `atomic-expr`
      <
        'paren-expr',
        'primitive-lit-expr',
        'signed-num-lit-expr',
        'array-lit-expr',
        'set-lit-expr',
        'name-expr'
      >
    ]
    ```,
  )
)

#rule(<expr.atomic>)
Следующие выражения являются #def("atomic-expr")[Атомарное выражение][атомарными]:
+ @def:primitive-lit-expr;
+ @def:signed-num-lit-expr;
+ @def:array-lit-expr;
+ @def:set-lit-expr;
+ @def:name-expr.

#unresolved[
  Атомарные выражения в грамматике используются только для значений перечислимого семантического типа, которые сейчас не описаны.
  Нужны ли нам они как синтаксическая подкатегория?
  Возможно, стоит сделать атомарность семантическим свойством (в смысле проверяемого не в грамматике).
]

#TODO[потребовать атомарности у операндов]

#let un-ops = (`+`, `-`, `~`, `!`)
#let mul-bin-ops = (`*`, `/`, `%`)
#let add-bin-ops = (`+`, `-`)
#let bit-shift-ops = (`<<`, `>>`, `<<<`, `>>>`)
#let rel-ops = (`<`, `<=`, `>`, `>=`, `==`, `!=`, `in`, `!in`)

#rule(<expr.precedence>)
Приоритеты и ассоциативность выражений и операторов в LibSL следующие (в порядке уменьшения приоритетов):

#table(
  columns: 2,

  table.header[*Операторы и выражения*][*Ассоциативность*],

  [@def:prev-expr], [—],
  [@def:call-expr], [—],
  [@def:field-expr], [—],
  [@def:deref-expr], [—],
  [@def:index-expr], [—],
  [@def:unary-expr[Унарные] #un-ops.join[, ]], [—],
  [@def:has-concept-expr], [—],
  [@def:type-comparison-expr], [—],
  [@def:cast-expr], [—],
  [@def:binary-expr[Бинарные] #mul-bin-ops.join[, ]], [Левая],
  [@def:binary-expr[Бинарные] #add-bin-ops.join[, ]], [Левая],
  [@def:binary-expr[Бинарные] #bit-shift-ops.join[, ]], [Левая],
  [@def:binary-expr[Бинарный] `&`], [Левая],
  [@def:binary-expr[Бинарный] `^`], [Левая],
  [@def:binary-expr[Бинарный] `|`], [Левая],
  [@def:binary-expr[Бинарные] #rel-ops.join[, ]], [Левая],
  [@def:binary-expr[Бинарный] `&&`], [Левая],
  [@def:binary-expr[Бинарный] `||`], [Левая],
)

#rule(<expr.paren>)
В выражении могут произвольным образом использоваться скобки для группировки подвыражений независимо от приоритетов.
Они имеют значение только для синтаксического разбора; на семантические свойства они не влияют.

#rule(<expr.top-level>)
Выражение находится #def("top-level-expr")[Верхнеуровневое][на верхнем уровне], если оно не является подвыражением другого выражения.

#rule-h(<expr.primitive-lit>)
== Примитивнолитеральное выражение

#figure(
  ```antlr
  expr:
      ...
      |   lit=primitiveLit # ExprPrimitiveLit
      ...
  ```,
)

#figure(
  railroad(
    ```
    [
      `primitive-lit-expr`
      'primitive-lit'
    ]
    ```,
  )
)

#rule(<expr.primitive-lit.intro>)
#expr-def("primitive-lit-expr")[Примитивнолитеральное выражение] состоит из @def:primitive-lit[примитивного литерала], которое непосредственно задаёт @def:value[значение].

#rule(<expr.primitive-lit.eval>)
Результат @def:expr-eval[вычисления] выражения — значение примитивного литерала.

#rule(<expr.primitive-lit.typing>)
Типом выражения является @def:literal-type-widening[расширение] соответствующего @def:literal-type[литерального типа].

#rule(<expr.primitive-lit.purity>)
#pure-expr[@def:primitive-lit-expr]
Выражение является @def:pure-expr[чистым].

#rule(<expr.primitive-lit.pred-permissible>)
#pred-permissible-expr[@def:primitive-lit-expr]
Выражение @def:pred-permissible-expr[допустимо в предикатах].

#rule(<expr.primitive-lit.simple>)
#simple-expr[@def:primitive-lit-expr]
Выражение является @def:simple-expr[простым].

#rule-h(<expr.array-lit>)
== Литерал массива

#figure(
  ```antlr
  arrayLitExpr
    :   L_BRACKET (elems=exprList COMMA?)? R_BRACKET
    ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `array-lit-expr`
      "["
      ['expr'*"," ","?]?
      "]"
    ]
    ```,
  )
)

#rule(<expr.array-lit.intro>)
#expr-def("array-lit-expr")[Литерал массива] создаёт новый @def:array-value[массив] с заданными элементами.

#rule(<expr.array-lit.eval>)
Выражение вычисляет операнды по порядку.
Результат @def:expr-eval[вычисления] выражения — @def:array-value[массив] значений операндов в том же порядке.

#rule(<expr.array-lit.typing>)
Тип выражения — #type-expr(ctor(builtin-types.array)($T$)).
Операнды должны @def:expr-conformity[соответствовать] типу #type-expr($T$).

#rule(<expr.array-lit.purity>)
#pure-expr[@def:array-lit-expr]
Выражение является @def:pure-expr[чистым], если все его операнды чисты.

#rule(<expr.array-lit.pred-permissible>)
#pred-permissible-expr[@def:array-lit-expr]
Выражение @def:pred-permissible-expr[допустимо в предикатах], если допустимы в предикатах все его операнды.

#rule(<expr.array-lit.simple>)
#simple-expr[@def:array-lit-expr]
Выражение является @def:simple-expr[простым], если все его операнды просты.

#rule-h(<expr.set-lit>)
== Литерал множества

#figure(
  ```antlr
  setLitExpr
      :   L_BRACE (elems=exprList COMMA?)? R_BRACE
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `set-lit-expr`
      "{"
      ['expr'*"," ","?]?
      "}"
    ]
    ```,
  )
)

#rule(<expr.set-lit.intro>)
#expr-def("set-lit-expr")[Литерал множества] создаёт новое @def:set-value[множество] с заданными элементами.

#rule(<expr.set-lit.eval>)
Выражение вычисляет операнды по порядку.
Результат @def:expr-eval[вычисления] выражения — @def:set-value[множество] значений операндов.

#rule(<expr.set-lit.duplicates>)
Среди значений операндов могут быть повторяющиеся.
В результирующем множестве останется только один экземпляр.

#rule(<expr.set-lit.types>)
Тип выражения — #type-expr(ctor(builtin-types.set)($T$)).
Операнды должны @def:expr-conformity[соответствовать] типу #type-expr($T$).

#rule(<expr.set-lit.hashable>)
В качестве типа #type-expr($T$) допускаются только следующие, называемые #def("hashable-type")[Хэшируемый тип][хэшируемыми]:
- #type-expr(builtin-types.bool)\;
- #type-expr(builtin-types.char)\;
- #type-expr(builtin-types.string)\;
- @def:integral-type[целочисленные типы]\;
- #type-expr(builtin-types.null).

#sema-err-def[Создание множества с нехэшируемым типом элемента][Использование отличного от перечисленных выше типов — семантическая ошибка.]

#impl-spec(impls.rs)[
  Проверка отсутствует.
]

#rule(<expr.set-lit.purity>)
#pure-expr[@def:set-lit-expr]
Выражение является @def:pure-expr[чистым], если все его операнды чисты.

#rule(<expr.set-lit.pred-permissible>)
#pred-permissible-expr[@def:set-lit-expr]
Выражение @def:pred-permissible-expr[допустимо в предикатах], если допустимы в предикатах все его операнды.

#rule(<expr.set-lit.simple>)
#simple-expr[@def:set-lit-expr]
Выражение является @def:simple-expr[простым], если все его операнды просты.

#rule-h(<expr.call>)
== Выражение вызова

#figure(
  ```antlr
  expr:
      ...
      |   name=ident typeArgs=typeArgSpec? L_PAREN (args=exprList COMMA?)? R_PAREN # ExprCallUnqualified
      |   base=expr DOT name=ident typeArgs=typeArgSpec? L_PAREN (args=exprList COMMA?)? R_PAREN # ExprCallQualified
      ...
  ```,
)

#figure(
  railroad(
    ```
    [
      `call-expr`
      <
        'ident'#`unqualified`,
        [
          ['ident' "."]*[]
          'ident'
        ]#`scope-qualified`,
        [
          'expr'
          "."
          'ident'
        ]#`receiver-qualified`
      >
      {
        'type-arg-spec'?,
        [
          "("
          ['expr'*"," ","?]?
          ")"
        ]
      }
    ]
    ```,
  )
)

#rule(<expr.call.intro>)
#expr-def("call-expr")[Выражение вызова] производит вызов @def:proc-decl[процедуры] или @def:pred-decl[функционального предиката] с заданными аргументами.

#rule(<expr.call.kinds>)
Имеются следующие виды выражения:

#rule(<expr.call.unqualified>)
/ Неквалифицированный:
  Вызываемая @def:fn-entity[функциональная сущность] задаётся при помощи @def:ident[идентификатора].

#rule(<expr.call.scope-qualified>)
/ Квалифицированный @def:scope[областью видимости]:
  Имя @def:fn-entity[функциональной сущности] предваряет префикс из имён сущностей.
  Вызываемая @def:fn-entity[функциональная сущность] ищется в заданной префиксом @def:scope[области видимости].
  Разрешение области видимости происходит так же, как в @expr.field.member.

#rule(<expr.call.receiver-qualified>)
/ Квалифицированный @def:object[объектом] метода:
  Вызываемая @def:fn-entity[функциональная сущность] является методом явно указанного @def:object[объекта].

  #rule(<expr.call.receiver-qualified.priority>)
  Синтаксис квалифицированного областью видимости выражения вызова — частный случай синтаксиса данного вида выражения.
  Различие устанавливается в ходе семантического анализа.
  Данный вид имеет приоритет над квалифицированным областью видимости.

#rule(<expr.call.callee>)
Вызываемая @def:fn-entity[функциональная сущность] определяется при помощи @def:overload-resolution[разрешения перегрузок] в зависимости от вида выражения.

#rule(<expr.call.pred>)
Если выражение вызова присутствует в @def:expr-pred[предикате-выражении] на @def:top-level-expr[верхнем уровне], в разрешении перегрузок @def:overload-applicability[допустимыми] функциональными сущностями являются только @def:proc-decl[процедуры] и @def:pred-decl[функциональные предикаты].
В остальных случаях допустимыми являются только процедуры.

#rule(<expr.call.eval>)
Операнды выражения вычисляются по порядку.
В частности, в квалифицированном объектом метода выражении вызова первым вычисляется объект, затем аргументы.
После вычисления операндов происходит @def:call[вызов] $"call"_(f chevron.l P_1, ..., P_m chevron.r (p_1, ..., p_n)) chevron.l Q_1, ..., Q_m chevron.r (A)$, где:

- $f$ — вызываемая функциональная сущность;

- $P_1, ..., P_m$ — @def:type-param[типовые параметры] $f$;

- $p_1, ..., p_n$ — параметры $f$;

- $Q_1, ..., Q_m$ — @def:type-arg[типовые аргументы] вызова, включая неявно выведенные в результате анализа типов;

- $A$ — аргументы, определяемые следующим образом:

  - Пусть $a_1, ..., a_n$ — аргументы выражения.
    
    Если $f$ является @def:static-method[нестатическим] @def:method[методом], то $A = a_0, ..., a_n$, где $a_0$ — @def:object[объект]:

      - при неквалифицированном вызове — @def:current-exec-state[текущее] значение @def:this-var[переменной объекта];

      - при квалифицированном объектом метода вызове — результат вычисления выражения объекта.

    В противном случае $A = a_1, ..., a_n$.

Результатом @def:expr-eval[вычисления] выражения является возвращённое значение.

#rule(<expr.call.arg-count-mismatch>)
Число аргументов должно совпадать с числом параметров вызываемой функциональной сущности.
#sema-err-def[Вызов функциональной сущности с неверным числом аргументов][Несовпадение является семантической ошибкой.]

#rule(<expr.call.typing>)
Каждый аргумент должен @def:expr-conformity[соответствовать] типу параметра.
Типом выражения вызова является тип возвращаемого значения вызванной функциональной сущности.

#rule(<expr.call.purity>)
#pure-expr[@def:call-expr]
Выражение является @def:pure-expr[чистым], если все его операнды чисты, а вызываемая функциональная сущность — @def:pred-decl[функциональный предикат] либо @def:pure-proc[чистая процедура].

#rule(<expr.call.pred-permissible>)
#pred-permissible-expr[@def:call-expr]
Выражение @def:pred-permissible-expr[допустимо в предикатах], если допустимы в предикатах все его операнды, а вызываемая функциональная сущность — @def:pred-decl[функциональный предикат] либо @def:pure-proc[чистая процедура].

#rule-h(<expr.action-call>)
== Выражение вызова семантического действия

#figure(
  ```antlr
  actionCallExpr
      :   ACTION name=ident
          typeArgs=typeArgSpec?
          L_PAREN (args=exprList COMMA?)? R_PAREN
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `action-call-expr`
      "action"
      'ident'
      'type-arg-spec'
      "("
      ['expr'*"," ","?]?
      ")"
    ]
    ```,
  )
)

#rule(<expr.action-call.intro>)
#expr-def("action-call-expr")[Выражение вызова семантического действия] производит исполнение @def:action-decl[семантического действия] с заданными аргументами.

#rule(<expr.action-call.eval>)
Операнды выражения вычисляются по порядку.
Затем происходит исполнение семантического действия (@rt.action).
Результатом @def:expr-eval[вычисления] выражения является возвращённое значение.

#rule(<expr.action-call.typing>)
Каждый аргумент должен @def:expr-conformity[соответствовать] типу параметра.
Типом выражения является тип возвращаемого значения семантического действия.

#rule-h(<expr.instantiation>)
== Выражение инстанцирования

#figure(
  ```antlr
  instantiationExpr
      :   NEW name=fullName
          typeArgs=typeArgSpec?
          L_PAREN (args=constructorArgList COMMA?)? R_PAREN
      ;
  
  constructorArgList
      :   args+=constructorArg
          (COMMA args+=constructorArg)*
      ;
  
  constructorArg
      :   STATE EQ state=ident # ConstructorArgState
      |   name=ident EQ value=expr # ConstructorArgVar
      ;
  ```,
)

#figure(
  railroad(
    ```
    {
      [
        `instantiation-expr`
        "new"
        'full-name'
        'type-arg-spec'
      ],
      [
        "("
        [
          <
            [
              "state"
              "="
              'ident'
            ],
            [
              'ident'
              "="
              'expr'
            ]
          >*","
          ","?
        ]?
        ")"
      ]
    }
    ```,
  )
)

#rule(<expr.instantiation.intro>)
#expr-def("instantiation-expr")[Выражение инстанцирования] создаёт новый экземпляр @def:automaton-decl[автомата] с заданным начальным @def:extended-automaton-state[расширенным состоянием].

#rule(<expr.instantiation.args>)
Аргументы определяют @def:extended-automaton-state[расширенное состояние] порождаемого автомата.
Все аргументы именуются.
Аргументы могут быть двух видов:

#rule(<expr.instantiation.state>)
/ Аргумент состояния:
  При помощи формы `state =` задаётся @def:automaton-state[именованное состояние] порождаемого экземпляра автомата.
  Имя @def:state-decl[состояния] автомата указывается после знака `=`.

  #rule(<expr.instantiation.state.final>)
  #sema-err-def[Инстанцирование автомата в конечном состоянии][Указание @def:final-state[конечного состояния] в аргументе состояния — семантическая ошибка.]

#rule(<expr.instantiation.var>)
/ Аргумент переменной конструктора:
  Состоит из имени и выражения.
  Указывает значение @def:constructor-variable[переменной конструктора] с данным именем у порождаемого экземпляра автомата.

#rule(<expr.instantiation.duplicate>)
#sema-err-def[Повторное использование одного и того же параметра при инициализации автомата][Наличие нескольких аргументов переменных конструктора с одинаковым именем, а также нескольких аргументов состояния — семантическая ошибка.]

#rule(<expr.instantiation.missing>)
Все обязательные @def:constructor-variable[переменные конструктора] должны иметь аргументы; обязательным также является аргумент состояния.
#sema-err-def[Отсутствие обязательных аргументов при инициализации автомата][Отсутствие аргумента для какой-либо переменной конструктора, а также отсутствие аргумента состояния — семантическая ошибка.]

#rule(<expr.instantiation.eval>)
Операнды выражения вычисляются по порядку.
После этого производится вычисление @def:constructor-variable-default-expr[выражений по умолчанию] переменных конструктора, которые не указаны в выражении инстанциирования, в порядке, в котором они указаны в @def:automaton-decl[объявлении автомата].
Затем происходит @def:automaton-instantiation[инстанцирование автомата], @def:extended-automaton-state[расширенное состояние] которого определяется на основании аргументов.
Результат @def:expr-eval[вычисления] выражения — созданный экземпляр автомата.

#unresolved[
  @expr.instantiation.eval предполагает, что экземпляр автомата — значение.
  Действительно ли это так?
]

#rule(<expr.instantiation.typing>)
Каждый аргумент переменной конструктора должен @def:expr-conformity[соответствовать] типу параметра.

#unresolved[
  Сейчас автоматы не являются типом и не могут именоваться в типовых выражениях.
  Соответственно, непонятно, какой тип имеет выражение.
]

#rule-h(<expr.name>)
== Выражение имени

#figure(
  ```antlr
  expr:
      ...
      |   name=ident # ExprName
      ...
  ```,
)

#figure(
  railroad(
    ```
    [
      `name-expr`
      'ident'
    ]
    ```,
  )
)

#rule(<expr.name.intro>)
#expr-def("name-expr")[Выражение имени] производит обращение к сущности по заданному имени.

#rule(<expr.name.resolution>)
Сущность, к которой обращается выражение имени, @def:recursive-name-resolution[разрешается рекурсивно] в @def:namespace[пространстве имён] переменных.

#rule(<expr.name.implicit-field>)
Данное выражение может также производить обращение к полям объемлющей сущности.
В таком случае выражение называется #def("implicit-field-expr")[Выражение неявного обращения к полю][выражением неявного обращения к полю].

#rule(<expr.name.implicit-field.eval>)
Выражение неявного обращения к полю @def:expr-eval[вычисляется] так же, как @def:field-expr[выражение обращения к полю], где в качестве объекта выражения выступает @def:this-var[переменная объекта].

#rule(<expr.name.mutability>)
Выражение имени является @def:expr-mutability[изменяемым], если оно обращается к @def:mutable-variable[изменяемой] переменной (в т. ч. полю).

#rule(<expr.name.inaccessible>)
#runtime-err-def[Обращение в предыдущем состоянии к переменной, недоступной в предыдущем состоянии][Если @def:current-exec-state[текущим состоянием] является @def:prev-exec-state[предыдущее], а переменная, к которой обращается выражение имени, не являющееся выражением неявного обращения к полю, @def:prev-inaccessible-local[недоступна в предыдущем состоянии], то @def:expr-eval[вычисление] выражения — ошибка времени исполнения.]

#rule(<expr.name.eval>)
Результат @def:expr-eval[вычисления] выражения имени, не являющегося выражением неявного обращения к полю, — @def:current-exec-state[текущее] значение соответствующей переменной.

#rule(<expr.name.place>)
Результат @def:place-eval[вычисления места] выражения — место, обозначающее соответствующую переменную.

#rule(<expr.name.typing>)
Выражение имеет тип сущности, к которой оно обращается.

#rule(<expr.name.purity>)
#pure-expr[@def:name-expr]
Выражение имени, в том числе выражение неявного обращения к полю, является @def:pure-expr[чистым], если оно обращается к локальным переменным (включая параметры).

#rule(<expr.name.pred-permissible>)
#pred-permissible-expr[@def:name-expr]
Выражение @def:pred-permissible-expr[допустимо в предикатах].

#rule(<expr.name.simple>)
#simple-expr[@def:name-expr]
Выражение является @def:simple-expr[простым].

#rule-h(<expr.prev>)
== Выражение предыдущего значения

#figure(
  ```antlr
  expr:
      ...
      |   base=expr QUOTE # ExprPrev
      ...
  ```,
)

#figure(
  railroad(
    ```
    [
      `prev-expr`
      'expr'
      "'"
    ]
    ```,
  )
)

#rule(<expr.prev.intro>)
#expr-def("prev-expr")[Выражение предыдущего значения] позволяет явно обозначить вычисление в @def:prev-exec-state[предыдущем состоянии].

#rule(<expr.prev.eval>)
Выражение производит вычисление операнда в @def:exec-ctx[контексте], в котором @def:current-exec-state[текущим состоянием] является @def:prev-exec-state[предыдущее].
Полученное значение операнда является результатом @def:expr-eval[вычисления] выражения.

#rule(<expr.prev.sites>)
Выражение предыдущего значения может использоваться только в теле @def:function-decl[функций], @def:pred-decl[функциональных предикатов], а также в @def:contract[контрактах] функциональных сущностей.
#sema-err-def[Использование выражения предыдущего значения в недопустимых местах][Использование его в других местах — семантическая ошибка.]

#rule(<expr.prev.typing>)
Выражение имеет тип операнда.

#rule(<expr.prev.pred-permissible>)
#pred-permissible-expr[@def:prev-expr]
Выражение @def:pred-permissible-expr[допустимо в предикатах], если допустим в предикатах его операнд.

#rule-h(<expr.field>)
== Выражение обращения к полю

#figure(
  ```antlr
  expr:
      ...
      |   base=expr DOT field=ident # ExprField
      ...
  ```,
)

#figure(
  railroad(
    ```
    [
      `field-expr`
      'expr'
      "."
      'ident'
    ]
    ```,
  )
)

#rule(<expr.field.intro>)
#expr-def("field-expr")[Выражение обращения к полю] позволяет получить значение поля объекта, определяемого операндом.

#rule(<expr.field.eval>)
Операнд вычисляется в первую очередь.
Результат @def:expr-eval[вычисления] выражения — значение поля с заданным именем у объекта.

#rule(<expr.field.resolution>)
Разрешение имени поля происходит @def:local-name-resolution[локально] в @def:namespace[пространстве имён] переменных @def:instance-scope[области видимости элементов экземпляра] объекта.

#rule(<expr.field.place>)
При @def:place-eval[вычислении места] выражения обращения к полю происходит вычисление места операнда.
Результат вычисления места — @def:derived-place[производное место], указывающее на поле объекта.

#rule(<expr.field.mutability>)
Выражение является @def:expr-mutability[изменяемым], если поле @def:mutable-variable[изменяемое].

#rule(<expr.field.typing>)
Объект должен быть @def:struct-decl[структурного типа].
Выражение имеет тип поля.

#unresolved[
  У автоматов также есть поля.
  Как происходит обращение к ним?
]

#rule(<expr.field.purity>)
#pure-expr[@def:field-expr]
Выражение является @def:pure-expr[чистым], если чист его операнд.

#rule(<expr.field.pred-permissible>)
#pred-permissible-expr[@def:field-expr]
Выражение @def:pred-permissible-expr[допустимо в предикатах], если допустим в предикатах его операнд.

#rule(<expr.field.simple>)
#simple-expr[@def:field-expr]
Выражение является @def:simple-expr[простым], если его операнд прост.

#rule-h(<expr.field.member>)
=== Обращение к ассоциированной сущности

#figure(
  railroad(
    ```
    [
      `member-expr`
      'ident'*"."#`prefix`
      'ident'
    ]
    ```,
  )
)

#rule(<expr.field.member.intro>)
Частным случаем синтаксической формы выражения обращения к полю является #expr-def("member-expr")[Выражение обращения к ассоциированной сущности][выражение обращения к ассоциированной сущности].
Оно позволяет обратиться к сущности с указанным именем в заданной префиксом @def:scope[области видимости].

#rule(<expr.field.member.disambiguation>)
Выражение обращения к ассоциированной сущности не является выражением обращения к полю.
Различие между двумя видами выражений устанавливается в процессе разрешения сущности.
Приоритет имеет выражение обращения к полю.

#example[
  ```libsl
  enum x {
    y = 42;
  }

  struct Foo {
    val y: int32;
  }

  proc first(x: Foo) {
    x.y;
  }

  proc second() {
    x.y;
  }
  ```

  - В процедуре `first` выражение `x.y` является выражением обращения к полю `y` объекта `x` структурного типа `Foo`.

  - В процедуре `second` выражение `x.y` является выражением обращения к ассоциированной сущности `y` объявления перечислимого типа `x`.
]

#rule(<expr.field.member.resolution>)
Первый компонент префикса @def:recursive-name-resolution[разрешается рекурсивно] в @def:namespace[пространстве имён] типов.
Последующие компоненты префикса последовательно @def:local-name-resolution[разрешаются локально] в пространстве имён типов @def:member-scope[области видимости ассоциированных сущностей] каждого вновь получаемого типа.
Имя сущности @def:local-name-resolution[разрешается локально] в пространстве имён переменных области видимости ассоциированных сущностей типа.

#rule(<expr.field.member.eval>)
Результат @def:expr-eval[вычисления] выражения обращения к ассоциированной сущности — @def:current-exec-state[текущее] значение переменной (в т. ч. поля).

#rule(<expr.field.member.place>)
Результат @def:place-eval[вычисления места] выражения — место, обозначающее соответствующую сущность.

#rule(<expr.field.member.mutability>)
Выражение является @def:expr-mutability[изменяемым], если указывает на @def:mutable-variable[изменяемую переменную].

#rule(<expr.field.member.typing>)
Выражение имеет тип сущности.

#rule(<expr.field.member.purity>)
#pure-expr[@def:member-expr]
Выражение является @def:pure-expr[чистым], если указывает на @def:immutable-variable[неизменяемую переменную].

#rule(<expr.field.member.pred-permissible>)
#pred-permissible-expr[@def:member-expr]
Выражение @def:pred-permissible-expr[допустимо в предикатах].

#rule(<expr.field.member.simple>)
#simple-expr[@def:member-expr]
Выражение является @def:simple-expr[простым].

#rule-h(<expr.deref>)
== Выражение разыменования

#figure(
  ```antlr
  expr:
      ...
      |   base=expr DOT ASTERISK # ExprDeref
      ...
  ```,
)

#figure(
  railroad(
    ```
    [
      `deref-expr`
      'expr'
      "."
      "*"
    ]
    ```,
  )
)

#rule(<expr.deref.intro>)
#expr-def("deref-expr")[Выражение разыменования] позволяет получить значение по @def:pointer-value[указателю].

#rule(<expr.deref.eval>)
Операнд вычисляется в первую очередь.
Результат @def:expr-eval[вычисления] выражения — @def:current-exec-state[текущее] значение @def:memory-cell[ячейки памяти], @def:memory-address[адресуемой] @def:pointer-value[указателем].

#rule(<expr.deref.eval.restriction>)
@def:processor[Процессор] может ограничивать разыменование определённых указателей.
#runtime-err-def[Разыменование ограниченных указателей][В таком случае разыменование будет являться ошибкой времени исполнения.]

#rule(<expr.deref.typing>)
Операнд должен @def:expr-conformity[соответствовать] типу #type-expr(ptr($T$)).
Тип выражения — #type-expr($T$).

#note[
  LibSL не предоставляет способов изменения значения по указателю: выражение разыменования не допускается в @def:assign-stmt[команде присваивания] и не является выражением места.
]

#rule(<expr.deref.pred-permissible>)
#pred-permissible-expr[@def:deref-expr]
Выражение @def:pred-permissible-expr[допустимо в предикатах], если допустим в предикатах его операнд.

#rule-h(<expr.index>)
== Выражение обращения по индексу

#figure(
  ```antlr
  expr:
      ...
      |   base=expr L_BRACKET index=expr R_BRACKET # ExprIndex
      ...
  ```,
)

#figure(
  railroad(
    ```
    [
      `index-expr`
      'expr'
      "["
      'expr'
      "]"
    ]
    ```,
  )
)

#rule(<expr.index.intro>)
#expr-def("index-expr")[Выражение обращения по индексу] позволяет получить значение по заданному индексу в @def:array-value[массиве].
Первый операнд задаёт массив, второй — индекс.

#rule(<expr.index.eval>)
Операнды выражения вычисляются по порядку.
Результат @def:expr-eval[вычисления] выражения — значение элемента массива по заданному индексу.

#rule(<expr.index.place>)
При @def:place-eval[вычислении места] выражения вычисляется место операнда массива, после чего вычисляется значение операнда индекса.
Результат вычисления места — @def:derived-place[производное место], указывающее на элемент массива по заданному индексу.

#rule(<expr.index.mutability>)
Выражение является @def:expr-mutability[изменяемым], если операнд массива является изменяемым @def:place-expr[выражением места].

#rule(<expr.index.out-of-bounds>)
#runtime-err-def[Обращение за пределы массива][Ситуация, при которой @def:array-len[длина массива] при вычислении @def:expr-eval[значения] или @def:place-eval[места] не превышает индекса, влечёт ошибку времени исполнения.]

#rule(<expr.index.typing>)
Операнд массива должен @def:expr-conformity[соответствовать] типу #type-expr(ctor(builtin-types.array)($T$)).
Операнд индекса должен соответствовать типу #type-expr(builtin-types.unsigned64).
Тип выражения — #type-expr($T$).

#rule(<expr.index.purity>)
#pure-expr[@def:index-expr]
Выражение является @def:pure-expr[чистым], если чисты все его операнды.

#rule(<expr.index.pred-permissible>)
#pred-permissible-expr[@def:index-expr]
Выражение @def:pred-permissible-expr[допустимо в предикатах], если допустимы в предикатах все его операнды.

#rule(<expr.index.simple>)
#simple-expr[@def:index-expr]
Выражение является @def:simple-expr[простым], если все его операнды просты.

#rule-h(<expr.has-concept>)
== `has`-выражение

#figure(
  ```antlr
  expr:
      ...
      |   lhs=expr not=BANG? HAS concept=ident # ExprHasConcept
      ...
  ```,
)

#figure(
  railroad(
    ```
    [
      `has-concept-expr`
      'expr'
      <!, "!">
      "has"
      'ident'
    ]
    ```,
  )
)

#rule(<expr.has-concept.intro>)
#expr-def("has-concept-expr")[`has`-выражение] #TODO()

#unresolved[
  Что именно делает это выражение?
  Может, его стоит исключить из LibSL?
]

#rule-h(<expr.type-cmp>)
== Выражение сравнения типов

#figure(
  ```antlr
  expr:
      ...
      |   lhs=expr not=BANG? IS type=typeExpr # ExprTypeComparison
      ...
  ```,
)

#figure(
  railroad(
    ```
    [
      `type-cmp-expr`
      'expr'
      <!, "!">
      "is"
      'type-expr'
    ]
    ```,
  )
)

#rule(<expr.type-cmp.intro>)
#expr-def("type-comparison-expr")[Выражение сравнения типов] проверяет, удовлетворяет ли @def:dynamic-type[динамический тип] значения операнда статическому типу.

#rule(<expr.type-cmp.negation>)
Форма `!is` является логическим отрицанием `is`.

#rule(<expr.type-cmp.eval>)
Сначала вычисляется операнд.
Результатом @def:expr-eval[вычисления] выражения является `true`, если значение операнда содержится в указанном типе, и `false` в противном случае.

#rule(<expr.type-cmp.typing>)
Операнд может быть произвольного типа.
Тип выражения — #type-expr(builtin-types.bool).

#unresolved[
  Стоит ли ввести дополнительные ограничения на типы операндов?
  Например, если статический тип операнда — #type-expr(builtin-types.bool), он никогда не будет соответствовать #type-expr(builtin-types.string).
]

#rule(<expr.type-cmp.purity>)
#pure-expr[@def:type-comparison-expr]
Выражение является @def:pure-expr[чистым], если чист его операнд.

#rule(<expr.type-cmp.pred-permissible>)
#pred-permissible-expr[@def:type-comparison-expr]
Выражение @def:pred-permissible-expr[допустимо в предикатах], если допустим в предикатах его операнд.

#rule(<expr.type-cmp.simple>)
#simple-expr[@def:type-comparison-expr]
Выражение является @def:simple-expr[простым], если его операнд прост.

#rule-h(<expr.cast>)
== Выражение приведения типов

#figure(
  ```antlr
  expr:
      ...
      |   lhs=expr AS type=typeExpr # ExprCast
      ...
  ```,
)

#figure(
  railroad(
    ```
    [
      `cast-expr`
      'expr'
      "as"
      'type-expr'
    ]
    ```,
  )
)

#rule(<expr.cast.intro>)
#expr-def("cast-expr")[Выражение приведения типов] приводит тип операнда к заданному.

#rule(<expr.cast.eval>)
Операнд вычисляется в первую очередь.
Результат @def:expr-eval[вычисления] выражения — значение, получаемое @def:cast[приведением] значения операнда к указанному типу.
#runtime-err-def[Некорректное приведение типов][Ситуация, при которой операция приведения значения для данных значения и типа не определена, является ошибкой времени исполнения.]

#rule(<expr.cast.typing>)
Операнд может быть произвольного типа.
Тип выражения задаётся типовым выражением.

#unresolved[
  Стоит ли вводить дополнительные ограничения на статические типы операндов?
  Такое ограничение в любом случае можно обойти при помощи `x as any as T`.
  Но было бы неплохо отлавливать `"test" as bool`, который всегда будет ошибкой.
]

#rule(<expr.cast.purity>)
#pure-expr[@def:cast-expr]
Выражение является @def:pure-expr[чистым], если чист его операнд.

#rule(<expr.cast.pred-permissible>)
#pred-permissible-expr[@def:cast-expr]
Выражение @def:pred-permissible-expr[допустимо в предикатах], если допустим в предикатах его операнд.

#rule(<expr.cast.simple>)
#simple-expr[@def:cast-expr]
Выражение является @def:simple-expr[простым], если его операнд прост.

#rule-h(<expr.op>)
== Операторные выражения

#rule(<expr.op.intro>)
LibSL содержит унарные и бинарные операторные выражения, имеющие соответственно один и два операнда.

#rule(<expr.op.eval>)
При @def:expr-eval[вычислении] операторных выражений, за исключением бинарных `||` и `&&`, сначала вычисляются их операнды по порядку.
Затем применяется операция, соответствующая оператору.

#rule(<expr.op.resolution>)
Операторы LibSL являются перегруженными.
Каждый оператор задаёт @def:candidate-set[множество перегрузок].
Перегрузка определяется при помощи @def:overload-resolution[разрешения перегрузки], для чего используется поиск кандидатов операторного выражения (@name.resolution.overload.search.op).

#rule(<expr.op.typing>)
Типы операндов должны @def:expr-conformity[соответствовать] ожидаемым типам в сигнатуре оператора.
Тип операторного выражения — тип возвращаемого значения в сигнатуре перегрузки оператора.

#rule(<expr.op.purity>)
#pure-expr[@def:unary-expr]
#pure-expr[@def:binary-expr]
Операторное выражение является @def:pure-expr[чистым], если все его операнды чисты.

#rule(<expr.op.pred-permissible>)
#pred-permissible-expr[@def:unary-expr]
#pred-permissible-expr[@def:binary-expr]
Выражение @def:pred-permissible-expr[допустимо в предикатах], если допустимы в предикатах все его операнды.

#rule(<expr.op.simple>)
#simple-expr[@def:unary-expr]
#simple-expr[@def:binary-expr]
Выражение является @def:simple-expr[простым], если все его операнды просты.

#let sig(op, note: none) = (..params) => ret => {
  (
    op: op,
    params: params.pos().map(type-expr),
    ret: type-expr(ret),
    note: note,
  )
}

#let overload-table(arity: 2, ..sigs) = {
  show table: set block(width: 100%)

  table(
    columns: arity + 2,
    align: (x, y) => {
      if y == 0 and x > 0 {
        center
      } else {
        left
      }
    },

    table.header(
      ..(
        [*Операция*],
        table.cell(colspan: arity)[*Операнд#{if arity != 1 [ы]}*],
        [*Тип результата*],
      )
    ),
  
    ..sigs.pos()
      .map(sig => {
        (
          if sig.note != none {
            (table.cell(rowspan: 2, breakable: false, sig.op),)
          } else {
            (sig.op,)
          },
          ..sig.params.map(align.with(center + horizon)),
          align(center + horizon, sig.ret),
        )
    
        if sig.note != none {
          (table.cell(align: horizon, colspan: arity + 1, sig.note),)
        }
      })
      .flatten()
  )
}

#let i-ty-note = [#type-expr($I$) — @def:primitive-integer-type[примитивный целочисленный тип]]
#let s-ty-note = [#type-expr($S$) — @def:integral-type-signedness[знаковый] @def:primitive-integer-type[примитивный целочисленный тип]]
#let u-ty-note = [#type-expr($U$) — @def:integral-type-signedness[беззнаковый] @def:primitive-integer-type[примитивный целочисленный тип]]

#rule-h(<expr.op.unary>)
=== Унарное операторное выражение

#figure(
  ```antlr
  expr:
      ...
      |   op=unOp rhs=expr # ExprUnary
      ...

  unOp
      :   PLUS # UnOpPlus
      |   MINUS # UnOpNeg
      |   TILDE # UnOpBitNot
      |   BANG # UnOpNot
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `unary-expr`
      <
        ["+" 'expr'],
        ["-" 'expr'],
        ["~" 'expr'],
        ["!" 'expr']
      >
    ]
    ```,
  )
)

#rule(<expr.op.unary.intro>)
#expr-def("unary-expr")[Унарное операторное выражение] состоит из унарного оператора и операнда.

#rule(<expr.op.unary.kinds>)
Имеются следующие виды унарных операторных выражений:

#rule(<expr.op.unary.plus>)
/ Унарный `+`:
  Является тождественной операцией для @def:primitive-int-value[примитивных целых чисел].

  #rule(<expr.op.unary.plus.overloads>)
  Оператор определяет следующие перегрузки:

  #overload-table(
    arity: 1,
    sig(note: i-ty-note)[Тождественная операция]($I$)($I$),
  )

#rule(<expr.op.unary.neg>)
/ Унарный `-`:
  Для данного @def:primitive-int-value[примитивного целого числа] вычисляет противоположное.

  #rule(<expr.op.unary.neg.overloads>)
  Оператор определяет следующие перегрузки:

  #overload-table(
    arity: 1,
    sig(note: i-ty-note)[Противоположное число]($I$)($I$),
  )

#rule(<expr.op.unary.bit-not>)
/ Унарный `~`:
  Для данного @def:primitive-int-value[примитивного целого числа] вычисляет число того же типа, все биты которого обратны данному.

  #rule(<expr.op.unary.bit-not.overloads>)
  Оператор определяет следующие перегрузки:

  #overload-table(
    arity: 1,
    sig(note: i-ty-note)[Обращение бит]($I$)($I$),
  )

#rule(<expr.op.unary.not>)
/ Унарный `!`:
  Для данного @def:bool-value[булевого значения] вычисляет обратное.

  #rule(<expr.op.unary.not.overloads>)
  Оператор определяет следующие перегрузки:

  #overload-table(
    arity: 1,
    sig[Обращение булевого значения](builtin-types.bool)(builtin-types.bool),
  )

#unresolved[
  Для вещественных чисел унарные операции не определены.
]

#rule(<expr.op.unary.signed-num-lit>)
Унарное операторное выражение с оператором `-` или `+`, операндом котором является численное @def:primitive-lit-expr[примитивнолитеральное выражение], называется #def("signed-num-lit-expr")[Знаковый целочисленный литерал][знаковым целочисленным литералом].

#rule-h(<expr.op.binary>)
=== Бинарное операторное выражение

#rule(<expr.op.binary.intro>)
#expr-def("binary-expr")[Бинарное операторное выражение] (см. @binary-expr-syntax) состоит из левого операнда, оператора и правого операнда.

#rule(<expr.op.binary.kinds>)
Имеются следующие виды бинарных операторных выражений:

#rule(<expr.op.binary.mul>)
/ Бинарный `*`:
  Производит умножение двух @def:primitive-int-value[примитивных целых чисел].
  Результат операции — младшие биты произведения.

  #rule(<expr.op.binary.mul.overloads>)
  Оператор определяет следующие перегрузки:

  #overload-table(
    sig(note: i-ty-note)[Умножение]($I$, $I$)($I$),
  )

#rule(<expr.op.binary.div>)
/ Бинарный `/`:
  Производит деление двух @def:primitive-int-value[примитивных целых чисел].

  #rule(<expr.op.binary.div.signed>)
  Знаковое деление производит деление с учётом знака операндов.
  Частное округляется по направлению к нулю.
  При делении наименьшего представимого числа на $-1$ возникает переполнение; результатом будет наименьшее представимое число.

  #rule(<expr.op.binary.div.unsigned>)
  Беззнаковое деление производит деление двух неотрицательных чисел.
  Частное округляется вниз.

  #rule(<expr.op.binary.div.by-zero>)
  #runtime-err-def[Деление на $0$][Деление на $0$ — ошибка времени исполнения.]

  #rule(<expr.op.binary.div.overloads>)
  Оператор определяет следующие перегрузки:

  #overload-table(
    sig(note: s-ty-note)[Знаковое деление]($S$, $S$)($S$),
    sig(note: u-ty-note)[Беззнаковое деление]($U$, $U$)($U$),
  )

#rule(<expr.op.binary.mod>)
/ Бинарный `%`:
  Вычисляет остаток от деления двух @def:primitive-int-value[примитивных целых чисел].
  Для операции справедливо:

  $ l #skip-raw-box[`%`] r = l #skip-raw-box[`-`] (l #skip-raw-box[`/`] r) #skip-raw-box[`*`] r $

  #rule(<expr.op.binary.mod.signed>)
  Знаковый остаток производит деление с учётом знака операндов.
  Знак результата совпадает со знаком левого операнда.
  При делении наименьшего представимого числа на $-1$ возникает переполнение; результатом будет $0$.

  #rule(<expr.op.binary.mod.unsigned>)
  Беззнаковый остаток производит деление двух неотрицательных чисел.

  #rule(<expr.opp.binary.mod.by-zero>)
  #runtime-err-def[Взятие остатка от деления на $0$][Взятие остатка от деления на $0$ — ошибка времени исполнения.]

  #rule(<expr.op.binary.mod.overloads>)
  Оператор определяет следующие перегрузки:

  #overload-table(
    sig(note: s-ty-note)[Знаковый остаток]($S$, $S$)($S$),
    sig(note: u-ty-note)[Беззнаковый остаток]($U$, $U$)($U$),
  )

#rule(<expr.op.binary.add>)
/ Бинарный `+`:
  Производит сложение двух @def:primitive-int-value[примитивных целых чисел] или @def:string-value[строк].

  #rule(<expr.op.binary.add.int>)
  Результат целочисленного сложения — младшие биты суммы.

  #rule(<expr.op.binary.add.string>)
  Сложение двух строк производит их конкатенацию.

  #rule(<expr.op.binary.add.overloads>)
  Оператор определяет следующие перегрузки:

  #overload-table(
    sig(note: i-ty-note)[Целочисленное сложение]($I$, $I$)($I$),
    sig[Сложение строк](builtin-types.string, builtin-types.string)(builtin-types.string),
  )

#rule(<expr.op.binary.sub>)
/ Бинарный `-`:
  Производит вычитание двух @def:primitive-int-value[примитивных целых чисел].
  Результат — младшие биты разности.

  #rule(<expr.op.binary.sub.overloads>)
  Оператор определяет следующие перегрузки:

  #overload-table(
    sig(note: i-ty-note)[Целочисленное вычитание]($I$, $I$)($I$),
  )

#rule(<expr.op.binary.arith-shift>)
/ Бинарные `<<<`, `>>>`:
  Производят арифметический сдвиг для двух @def:primitive-int-value[примитивных целых чисел].
  Левый операнд сдвигается на число бит, задаваемое правым операндом.
  Операция `<<<` называется левым арифметическим сдвигом; `>>>` — правым.

  #rule(<expr.op.binary.arith-shift.direction>)
  Если правый операнд неотрицательный, левый сдвиг сдвигает биты в сторону старших; правый — в сторону младших.
  Если правый операнд отрицательный, направление сдвига меняется на противоположное.

  #rule(<expr.op.binary.arith-shift.sign-ext>)
  При направлении сдвига в сторону младших бит в новые старшие биты результата копируется старший бит левого операнда.

  #rule(<expr.op.binary.arith-shift.overloads>)
  Оба оператора определяют следующие перегрузки:

  #overload-table(
    sig(note: i-ty-note)[Арифметический сдвиг]($I$, $I$)($I$),
  )

#rule(<expr.op.binary.logic-shift>)
/ Бинарные `<<`, `>>`:
  Производят логический сдвиг для двух @def:primitive-int-value[примитивных целых чисел].
  Левый операнд сдвигается на число бит, задаваемое правым операндом.
  Операция `<<` называется левым логическим сдвигом; `>>` — правым.

  #rule(<expr.op.binary.logic-shift.direction>)
  Если правый операнд неотрицательный, левый сдвиг сдвигает биты в сторону старших; правый — в сторону младших.
  Если правый операнд отрицательный, направление сдвига меняется на противоположное.

  #rule(<expr.op.binary.logic-shift.sign-ext>)
  При направлении сдвига в сторону младших бит в новые старшие биты результата записывается $0$.

  #rule(<expr.op.binary.logic-shift.overloads>)
  Оба оператора определяют следующие перегрузки:

  #overload-table(
    sig(note: i-ty-note)[Логический сдвиг]($I$, $I$)($I$),
  )

#rule(<expr.op.binary.bit>)
/ Бинарные `&`, `^`, `|`:
  Производят побитовые операции для двух @def:primitive-int-value[примитивных целых чисел].

  #rule(<expr.op.binary.bit.truth>)
  Для одной пары бит операции имеют следующие таблицы истинности:

  #{
    show table: set block(width: 100%)

    table(
      columns: 5,
      align: center,
      fill: (x, y) => {
        if y > 0 and x < 2 {
          highlight-bg
        } else {
          none
        }
      },
  
      table.header[*Левый*][*Правый*][*`&`*][*`^`*][*`|`*],

      ..{
        let to-int(b) = if b { $1$ } else { $0$ }
        let band(l, r) = to-int(l and r)
        let bor(l, r) = to-int(l or r)
        let bxor(l, r) = to-int(l != r)

        for l in (false, true) {
          for r in (false, true) {
            (
              to-int(l),
              to-int(r),
              table.vline(stroke: stroke(thickness: 2pt, paint: black)),
              band(l, r),
              bxor(l, r),
              bor(l, r),
            )
          }
        }
      }
    )
  }

  #rule(<expr.op.binary.bit.overloads>)
  Операторами определяются следующие перегрузки:

  #overload-table(
    ..(`&`, `^`, `|`).map(op => sig(note: i-ty-note)[Побитовый #op]($I$, $I$)($I$)),
  )

#rule(<expr.op.binary.rel>)
/ Бинарные `<=`, `>=`, `<`, `>`:
  Производят сравнение двух @def:primitive-int-value[примитивных целых чисел].
  Все сравнения учитывают знак операндов (беззнаковые числа считаются неотрицательными).

  #rule(<expr.op.binary.rel.mixed-sign>)
  Если операнды разной @def:integral-type-signedness[знаковости], сравнение производится в $ZZ$ с сохранением знаков операндов.

  #example[
    ```libsl
    -4 < 4u
    ```

    Левый операнд имеет тип #type-expr(builtin-types.int32), правый — #type-expr(builtin-types.unsigned32).
    Оба приводятся к неограниченным целым числам: $-4$ и $4$, — после чего сравниваются (левое меньше правого).
  ]

  #rule(<expr.op.binary.rel.ord-type>)
  Если для типа #type-expr($T$) определены перегрузки операторов `<`, `>`, `<=` и `>=` с типами операндов #type-expr($T$) и #type-expr($T$), тип #type-expr($T$) называется #def("ord-type")[Упорядоченный тип][упорядоченным].

  #rule(<expr.op.binary.rel.overloads>)
  Каждый из операторов сравнения определяет следующие перегрузки:

  #overload-table(
    sig(note: s-ty-note)[Сравнение знаковых чисел]($S$, $S$)(builtin-types.bool),
    sig(note: u-ty-note)[Сравнение беззнаковых чисел]($U$, $U$)(builtin-types.bool),
    sig[Сравнение знакового числа с беззнаковым](builtin-types.int64, builtin-types.unsigned64)(builtin-types.bool),
    sig[Сравнение беззнакового числа со знаковым](builtin-types.unsigned64, builtin-types.int64)(builtin-types.bool),
  )

#rule(<expr.op.binary.eq>)
/ Бинарные `==`, `!=`:
  Производят проверку двух значений на равенство.
  Оператор `!=` является логическим отрицанием оператора `==`.

  #rule(<expr.op.binary.eq.mixed-sign>)
  Для целочисленных операндов разной @def:integral-type-signedness[знаковости] проверка равенства производится в $ZZ$ с сохранением знаков операндов.

  #example[
    ```libsl
    -1 != 4194967295u
    ```

    Левый операнд имеет тип #type-expr(builtin-types.int32), правый — #type-expr(builtin-types.unsigned32).
    Оба приводятся к неограниченным целым числам: $-1$ и $4194967295$, — после чего сравниваются (оказываются неравными).
  ]

  #rule(<expr.op.binary.eq.enum>)
  Равенство двух значений @def:enum-decl[перечислимого типа] устанавливается из равенства их @def:enum-underlying-value[нижележащих значений].

  #rule(<expr.op.binary.eq.ptr>)
  Равенство @def:pointer-value[указателей] устанавливается из равенства их @def:value-identity[идентичностей].

  #rule(<expr.op.binary.eq.eq-type>)
  Если для типа #type-expr($T$) определена перегрузка оператора `==` с типами операндов #type-expr($T$) и #type-expr($T$), тип #type-expr($T$) называется #def("eq-type")[Проверяемый на равенство тип][проверяемым на равенство].

  #rule(<expr.op.binary.eq.overloads>)
  Оба оператора определяют следующие перегрузки:

  #overload-table(
    sig(note: s-ty-note)[Проверка равенства знаковых чисел]($S$, $S$)(builtin-types.bool),
    sig(note: u-ty-note)[Проверка равенства беззнаковых чисел]($U$, $U$)(builtin-types.bool),
    sig[Проверка равенства знакового числа с беззнаковым](builtin-types.int64, builtin-types.unsigned64)(builtin-types.bool),
    sig[Проверка равенства беззнакового числа со знаковым](builtin-types.unsigned64, builtin-types.int64)(builtin-types.bool),

    sig[Проверка равенства булевых значений](builtin-types.bool, builtin-types.bool)(builtin-types.bool),
    sig[Проверка равенства символов](builtin-types.char, builtin-types.char)(builtin-types.bool),
    sig[Проверка равенства строк](builtin-types.string, builtin-types.string)(builtin-types.bool),
    sig(note: [#type-expr($E$) — @def:enum-decl[перечислимый тип]])[Проверка равенства значений перечислимых типов]($E$, $E$)(builtin-types.bool),
    sig(note: [#type-expr($T$) — произвольный тип])[Проверка равенства двух указателей](ptr($T$), ptr($T$))(builtin-types.bool),
  )

#rule(<expr.op.binary.in>)
/ Бинарные `in`, `!in`:
  Производит проверку наличия левого операнда в правом.
  Оператор `!in` является логическим отрицанием оператора `in`.

  #rule(<expr.op.binary.in.array>)
  Если правый операнд — @def:array-value[массив], результат оператора `in` будет равен `true`, если один из элементов массива равен левому операнду.

  #rule(<expr.op.binary.in.set>)
  Если правый операнд — @def:set-value[множество], результат оператора `in` будет равен `true`, если левый операнд принадлежит множеству.

  #impl-spec(impls.rs)[
    Не проверяется, что тип элемента хэшируемый.
  ]

  #rule(<expr.op.binary.in.overloads>)
  Оба оператора определяют следующие перегрузки:

  #overload-table(
    sig(note: [#type-expr($T$) — @def:eq-type[проверяемый на равенство] тип])[Проверка наличия элемента массива]($T$, ctor(builtin-types.array)($T$))(builtin-types.bool),
    sig(note: [#type-expr($T$) — @def:hashable-type[хэшируемый] тип])[Проверка принадлежности значения множеству]($T$, ctor(builtin-types.set)($T$))(builtin-types.bool),
  )

#rule(<expr.op.binary.or>)
/ Бинарный `||`:
  Вычисляет логическую дизъюнкцию двух булевых значений.

  #rule(<expr.op.binary.or.lazy>)
  @def:expr-eval[Вычисление] выражения является ленивым.
  Сначала вычисляется левый операнд.
  Если он оказывается равным `true`, он также становится результатом вычисления всего выражения без вычисления правого операнда.
  В противном случае возвращает значение правого операнда.

  #rule(<expr.op.binary.or.overloads>)
  Оператор определяет следующие перегрузки:

  #overload-table(
    sig[Логическая дизъюнкция](builtin-types.bool, builtin-types.bool)(builtin-types.bool),
  )

#rule(<expr.op.binary.and>)
/ Бинарный `&&`:
  Вычисляет логическую конъюнкцию двух булевых значений.

  #rule(<expr.op.binary.and.lazy>)
  @def:expr-eval[Вычисление] выражения является ленивым.
  Сначала вычисляется левый операнд.
  Если он оказывается равным `false`, он также становится результатом вычисления всего выражения без вычисления правого операнда.
  В противном случае возвращает значение правого операнда.

  #rule(<expr.op.binary.and.overloads>)
  Оператор определяет следующие перегрузки:

  #overload-table(
    sig[Логическая конъюнкция](builtin-types.bool, builtin-types.bool)(builtin-types.bool),
  )

#unresolved[
  Для вещественных чисел арифметические бинарные операции не определены.
  В первую очередь потому, что их семантика не столь однозначна, особенно если один из операндов — `NaN`.
]