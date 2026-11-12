#import "@preview/curryst:0.6.0"

#import "../meta.typ": *
#import "../railroad.typ": railroad
#import "../types.typ": type-expr, builtin-types

#rule-h(<contract>)
= Контракты и предикаты

#figure(
  ```antlr
  contract
      :   requiresContract # ContractRequires
      |   ensuresContract # ContractEnsures
      |   assignsContract # ContractAssigns
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `contract`
      <
        'requires-contract',
        'ensures-contract',
        'assigns-contract'
      >
    ]
    ```,
  )
)

#rule(<contract.intro>)
@def:function-decl[Функции] (а также @def:constructor-decl[функции-конструкторы] и @def:destructor-decl[функции-деструкторы]) могут обладать контрактами.
#def("contract")[Контракт][Контракты] — условия, которые проверяются при их @def:function-execution[исполнении].

#unresolved[
  Какой смысл несут контракты для процедур?
  Нужны ли они там?
]

Тело контракта составляет @def:pred[предикат] — отдельная синтаксическая категория.
Предикаты позволяют задавать логические условия в структурированном виде.
Также предикаты составляют тело @def:pred-decl[функционального предиката].

#rule-h(<contract.kinds>)
== Контракты

В языке имеются следующие виды контрактов:

- @def:requires-contract (`requires`).
- @def:ensures-contract (`ensures`).
- @def:assigns-contract (`assigns`).

#deficiency[
  Контракты имеют имена, семантика которых не определена.
  Их следует исключить и заменить на именованные предикаты.
]

#rule-h(<contract.requires>)
=== Предусловия

#figure(
  ```antlr
  requiresContract
      :   REQUIRES
          (name=ident COLON)?
          spec=contractPredicate
      ;
  ```,

)

#figure(
  railroad(
    ```
    [
      `requires-contract`
      "requires"
      [
        'ident'
        ":"
      ]?
      'contract-predicate'
    ]
    ```
  )
)

#rule(<contract.requires.intro>)
#def("requires-contract")[Предусловие] задаёт условие, которое проверяется перед исполнением тела функции.

#rule(<contract.requires.name>)
Контракт может иметь имя.
Такой контракт интерпретируется как @def:named-pred[именованный предикат] с заданным именем.

#rule(<contract.requires.eval>)
@def:pred-eval[Вычисление] предиката производится в @def:exec-ctx[контексте], в котором @def:current-exec-state[текущим состоянием] является @def:prev-exec-state[предыдущее].

#rule(<contract.requires.vars>)
Предикат может обращаться к нелокальным @def:variable-decl[переменным], а также параметрам функции.
Разрешается обращение к @def:this-var[переменной объекта] в методах.

#rule(<contact.requires.result>)
Переменная `result` недоступна в предикате.
#sema-err-def[Обращение к переменной `result` в предусловии][Обращение к ней — семантическая ошибка.]

#rule-h(<contract.ensures>)
=== Постусловия

#figure(
  ```antlr
  ensuresContract
      :   ENSURES
          (name=ident COLON)?
          spec=contractPredicate
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `ensures-contract`
      "ensures"
      [
        'ident'
        ":"
      ]?
      'contract-predicate'
    ]
    ```,
  )
)

#rule(<contract.ensures.intro>)
#def("ensures-contract")[Постусловие] задаёт условиве, которое проверяется после исполнения тела функции.

#rule(<contract.ensures.name>)
Контракт может иметь имя.
Такой контракт интерпретируется как @def:named-pred[именованный предикат] с заданным именем.

#rule(<contract.ensures.eval>)
@def:pred-eval[Вычисление] предиката производится в @def:exec-ctx[контексте], в котором @def:current-exec-state[текущим состоянием] является @def:next-exec-state[следующее].

#rule(<contract.ensures.vars>)
Предикат может обращаться к нелокальным @def:variable-decl[переменным], а также параметрам функции.
Разрешается обращение к @def:this-var[переменной объекта] в методах.

#rule(<contract.ensures.result>)
К переменной `result` обращение позволяется только при вычислении в @def:next-exec-state[следующем состоянии].
#sema-err-def[Обращение к `result` в выражении постусловия, вычисляющегося в предыдущем состоянии][Обращение в @def:prev-exec-state[предыдущем] — семантическая ошибка.]

#rule-h(<contract.assigns>)
=== Контракт `assigns`

#figure(
  ```antlr
  assignsContract
      :   ASSIGNS
          (name=ident COLON)?
          spec=expr
          SEMICOLON
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `assigns-contract`
      "assigns"
      [
        'ident'
        ":"
      ]?
      'expr'
      ";"
    ]
    ```,
  )
)

#rule(<contract.assigns.intro>)
#def("assigns-contract")[Контракт `assigns`] определяет нелокальную переменную, в которую происходит присваивание в процессе @def:function-execution[исполнения] функции.

#unresolved[
  Нужен ли такой тип контрактов?
  Как именно определяется нелокальная переменная?
  Какова его семантика в терминах языка?
]

#impl-spec(impls.rs)[
  Семантический анализ игнорирует такие контракты.
]

#rule-h(<contract.pred>)
== Предикаты

#figure(
  ```antlr
  predicate
      :   blockPredicate # PredicateBlock
      |   name=ident COLON predicate # PredicateNamed
      |   variableDecl # PredicateVariableDecl
      |   ifPredicate # PredicateIf
      |   cancelPredicate # PredicateCancel
      |   expr SEMICOLON # PredicateExpr
      ;

  contractPredicate
      :   blockPredicate # ContractPredicateBlock
      |   ifPredicate # ContractPredicateIf
      |   cancelPredicate # ContractPredicateCancel
      |   expr SEMICOLON # ContractPredicateExpr
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `predicate`
      <
        'block-predicate',
        'named-predicate',
        'variable-decl-predicate',
        'if-predicate',
        'cancel-predicate',
        'expr-predicate'
      >
    ]
    ```
  )
)

#figure(
  railroad(
    ```
    [
      `contract-predicate`
      <
        'block-predicate',
        'if-predicate',
        'cancel-predicate',
        'expr-predicate'
      >
    ]
    ```,
  )
)

#rule(<contract.pred.intro>)
#def("pred")[Предикат] — синтаксическая категория языка, позволяющая задавать логические условия в структурированной форме.
Предикаты составляют тела @def:contract[контрактов] и @def:pred-decl[функциональных предикатов].

#rule(<contract.pred.blocks>)
#def("pred-block")[Блок предикатов] составляет тело @def:contract[контракта], @def:pred-body[функционального предиката] либо @def:block-pred[блоковый предикат].

#rule(<contract.pred.eval>)
#def("pred-eval")[Вычисление предиката] заключается в установлении его истинности.
В результате вычисления предикат может оказаться либо выполненным, либо невыполненным.

#note[
  Правила выполненности описываются текстом, а также в виде правил вывода в генценовской нотации, например:

  #context query(<eq:p-block>).first()

  Над чертой указываются условия, при выполнении которых справедливо следствие.
  Знак #sym.tack понимается как выполненность предиката.
  Предикаты обозначаются греческими буквами.
]

#rule(<contract.pred.unsat>)
Вычисление предиката осуществляется @def:processor[процессором].
Он же задаёт поведение в случае невыполнения предиката.

#note[
  В частности, невыполнение может считаться ошибкой времени исполнения, порождать диагностическое сообщение или вовсе игнорироваться.
]

#rule(<contract.pred.eval-order>)
Предикаты (в том числе вложенные) могут вычисляться @def:processor[процессором] в произвольном порядке.
Расположение предикатов в @def:pred-block[блоке] не имеет значения.

#note[
  Порядок предикатов в блоке влияет на видимость объявляемых в нём @def:variable-decl-pred[локальных переменных].
]

#rule(<contract.pred.pure>)
Некоторые предикаты могут содержать в себе @def:expr[выражения].
Такие выражения обязаны быть @def:pred-permissible-expr[допустимыми в предикатах].
#sema-err-def[Использование в предикате недопустимого в предикатах выражения][Нарушение этого требования — семантическая ошибка.]

#impl-spec(impls.rs)[
  Проверка отсутствует.
]

#rule(<contract.pred.kinds>)
В языке имеются следующие виды предикатов:
#let preds = state("preds", ())
#let pred-def(name, ..args) = {
  def(name, ..args)
  preds.update(preds => preds + (ref(label("def:" + name)),))
}
#context enum(tight: true, ..preds.final().map(it => [#it.]))

#rule-h(<contract.pred.block>)
=== Блоковый предикат

#figure(
  ```antlr
  blockPredicate
      :   L_BRACE predicates+=predicate* R_BRACE
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `block-predicate`
      "{"
      [
        'predicate'*[]
      ]?
      "}"
    ]
    ```,
  )
)

#rule(<contract.pred.block.intro>)
#pred-def("block-pred")[Блоковый предикат] — предикат, выражающий конъюнкцию предикатов, расположенных между фигурными скобками.

#rule(<contract.pred.block.eval>)
При @def:pred-eval[вычислении] предиката он считается выполненным, если выполнены все перечисленные предикаты:

$
  #curryst.prooftree({
    import curryst: *

    rule(
      name: [P-Block],
      $tack φ_1$,
      $...$,
      $tack φ_n$,
      $tack #`{` φ_1" "..." "φ_n #`}`$
    )
  })
$ <eq:p-block>

Частные случаи:

- Если список предикатов пуст, предикат считается выполненным.

- Если список предикатов содержит единственный предикат, выполнимость вложенного предиката равносильна выполнимости блокового.

#rule(<contract.pred.block.scopes>)
Блоковый предикат вводит в @def:current-scope[текущей] новую @def:block-scope[область видимости блока].
Она является @def:current-scope[текущей] для вложенных предикатов.

#rule-h(<contract.pred.named>)
=== Именованный предикат

#figure(
  ```antlr
  predicate:
      ...
      |   name=ident COLON predicate # PredicateNamed
      ...
  ```,
)

#figure(
  railroad(
    ```
    [
      `named-predicate`
      'ident'
      ":"
      'predicate'
    ]
    ```
  )
)

#rule(<contract.pred.named.intro>)
#pred-def("named-pred")[Именованный предикат] объявляет новое имя в @def:namespace[пространстве имён] контрактов @def:scope[области видимости] тела @def:fn-body[функциональной сущности] или @def:pred-body[функционального предиката].

#note[
  В отличие от большинства других конструкций языка, имя может вводиться не в @def:current-scope[текущую область видимости].

  Имена являются глобальными для @def:fn-entity[функциональной сущности].
  В частности, предикаты в различных контрактах одной и той же функциональной сущности не могут иметь одни и те же имена.
]

#rule(<contract.pred.named.eval>)
При @def:pred-eval[вычислении] предиката его выполнимость равносильна выполнимости вложенного предиката:

$
  #curryst.prooftree({
    import curryst: *

    rule(
      name: [P-Named],
      $tack φ$,
      $tack n#`:` φ$
    )
  })
$

#rule-h(<contract.pred.variable-decl>)
=== Объявление локальной переменной

#figure(
  ```antlr
  predicate:
      ...
      |   variableDecl # PredicateVariableDecl
      ...
  ```,
)

#figure(
  railroad(
    ```
    [
      `variable-decl-predicate`
      'variable-decl'
    ]
    ```,
  )
)

#rule(<contract.pred.variable-decl.intro>)
#pred-def("variable-decl-pred")[Предикат объявления локальной переменной] вводит новую @def:scope[область видимости] (@decl.variable.scope), в @def:namespace[пространстве имён] переменных которой объявляет @def:local-variable[локальную переменную].

#rule(<contract.pred.variable-decl.eval>)
При @def:pred-eval[вычислении] предиката он считается выполненным:

$
  #curryst.prooftree({
    import curryst: *

    rule(
      name: [P-VarDecl],
      $tack "variable decl"$
    )
  })
$

#rule(<contract.pred.variable-decl.scopes>)
Введённая область видимости становится @def:current-scope[текущей] для последующих предикатов в пределах @def:pred-block[блока], в котором содержится данный предикат.

#rule-h(<contract.pred.if>)
=== Условный предикат

#figure(
  ```antlr
  ifPredicate
      :   IF
          L_PAREN condition=expr R_PAREN
          thenBranch=predicate
          (ELSE elseBranch=predicate)?
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `if-predicate`
      "if"
      "("
      'expr'
      ")"
      'predicate'
      [
        "else"
        'predicate'
      ]?
    ]
    ```,
  )
)

#rule(<contract.pred.if.intro>)
#pred-def("if-pred")[Условный предикат] — предикат-импликация.
Посылка импликации указывается в скобках.
После скобок указывается предикат-следствие.

#rule(<contract.pred.if.else>)
Условный предикат может содержать `else`-ветку.
Она определяет истинность предиката, если условие ложно.

#rule(<contract.pred.if.eval>)
При @def:pred-eval[вычислении] предиката он считается выполненным, если:
+ результат @def:expr-eval[вычисления] условия — `true` и выполнен предикат-следствие;
+ результат @def:expr-eval[вычисления] условия — `false` и либо `else`-ветка отсутствует, либо предикат в ней выполнен.

#figure(
  $
    &#curryst.prooftree({
      import curryst: *

      rule(
        name: [P-If-Then-True],
        $tack e$,
        $tack φ_"then"$,
        $tack #`if (`e#`)` φ_"then"$,
      )
    })
    &
    #h(2em)
    &#curryst.prooftree({
      import curryst: *

      rule(
        name: [P-If-Then-False],
        $tack.not e$,
        $tack #`if (`e#`)` φ_"then"$,
      )
    }) \

    &#curryst.prooftree({
      import curryst: *

      rule(
        name: [P-If-ThenElse-True],
        $tack e$,
        $tack φ_"then"$,
        $tack #`if (`e#`)` φ_"then" #`else` φ_"else"$,
      )
    })
    &
    #h(2em)
    &#curryst.prooftree({
      import curryst: *

      rule(
        name: [P-If-ThenElse-False],
        $tack.not e$,
        $tack φ_"else"$,
        $tack #`if (`e#`)` φ_"then" #`else` φ_"else"$,
      )
    })
  $
)

#rule(<contract.pred.if.typing>)
Условие должно @def:expr-conformity[соответствовать] типу #type-expr(builtin-types.bool).

#rule-h(<contract.pred.expr>)
=== Предикат-выражение

#figure(
  ```antlr
  predicate:
      ...
      |   expr SEMICOLON # PredicateExpr
      ...
  ```,
)

#figure(
  railroad(
    ```
    [
      `expr-predicate`
      'expr'
      ";"
    ]
    ```
  )
)

#rule(<contract.pred.expr.intro>)
#pred-def("expr-pred")[Предикат-выражение] — предикат, условие которого представляет собой @def:expr[выражение].

#rule(<contract.pred.expr.eval>)
При @def:pred-eval[вычислении] предиката он считается выполненным, если результат @def:expr-eval[вычисления] выражения — `true`.

#rule(<contract.pred.expr.typing>)
Выражение должно @def:expr-conformity[соответствовать] типу #type-expr(builtin-types.bool).

#rule-h(<contract.pred.cancel>)
=== Предикат отмены перехода

#figure(
  ```antlr
  cancelPredicate
      :   CANCEL
          SEMICOLON
      ;
  ```
)

#figure(
  railroad(
    ```
    [
      `cancel-predicate`
      "cancel"
      ";"
    ]
    ```,
  ),
)

#rule(<contract.pred.cancel.intro>)
#pred-def("cancel-pred")[Предикат отмены перехода] — предикат, который отменяет переход между состояниями при @def:function-execution[исполнении функции].

#impl-spec(impls.rs)[
  Предикат не реализован.
]

#rule(<contract.pred.cancel.sites>)
Предикат отмены перехода может располагаться только в контракте @def:function-decl[функции]-@def:method[метода] @def:automaton-decl[автомата].
#sema-err-def[Использование предиката отмены перехода вне контракта функции-метода автомата][Использование его в иных местах — семантическая ошибка.]

#rule(<contract.pred.cancel.eval>)
При @def:pred-eval[вычислении] предиката он считается выполненным.
Он также отменяет переход между состояниями автомата согласно @def:applicable-shift-rule[применимому] правилу перехода (@decl.automaton.state.transition).
В результате по завершении исполнения функции @def:automaton-state[именованное состояние] автомата останется прежним.
