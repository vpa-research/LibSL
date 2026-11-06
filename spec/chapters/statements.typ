#import "../meta.typ": *
#import "../railroad.typ": railroad
#import "../types.typ": type-expr, builtin-types

#rule-h(<stmt>)
= Команды

#rule(<stmt.intro>)
#def("stmt")[Команда] (statement) — синтаксическая конструкция, содержащаяся в теле функциональной сущности (@decl.fn.body).
Она задаёт императивное поведение при её @def:function-execution[исполнении] (для функций) или вызове (для остальных сущностей).

#figure(
  ```antlr
  block
      :   stmt # BlockLoneStmt
      |   L_BRACE stmts+=stmt* R_BRACE # BlockBraced
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `block`
      <
        'stmt',
        [
          "{"
          ['stmt'*[]]?
          "}"
        ]
      >
    ]
    ```,
  )
)

#rule(<stmt.block>)
Команды группируются в #def("block")[Блок команд][блоки].
Тело функции также является блоком.
Исполнение команд в блоке происходит последовательно.

#figure(
  ```antlr
  stmt
      :   variableDecl # StmtVariableDecl
      |   ifStmt # StmtIf
      |   assignStmt # StmtAssign
      |   cancelStmt # StmtCancel
      |   inner=expr SEMICOLON # StmtExpr
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `stmt`
      <
        'variable-decl-stmt',
        'if-stmt',
        'assign-stmt',
        'cancel-stmt',
        'expr-stmt'
      >
    ]
    ```,
  )
)

#rule(<stmt.kinds>)
Имеются следующие виды команд:
+ @def:variable-decl-stmt
+ @def:if-stmt
+ @def:assign-stmt
+ @def:cancel-stmt
+ @def:expr-stmt

#rule-h(<stmt.variable-decl>)
== Объявление локальной переменной

#figure(
  railroad(
    ```
    [
      `variable-decl-stmt`
      'variable-decl'
    ]
    ```,
  )
)

#rule(<stmt.variable-decl.intro>)
#def("variable-decl-stmt")[Команда объявления локальной переменной] вводит новую @def:scope[область видимости] (@decl.variable.scope), в которой объявляет @def:local-variable[локальную переменную].
Синтаксически идентична @def:variable-decl[объявлению переменной].

#rule(<stmt.variable-decl.scopes>)
Введённая область видимости становится @def:current-scope[текущей] для последующих команд в пределах блока, в котором содержится данная команда.

#rule-h(<stmt.if>)
== Условная команда

#figure(
  ```antlr
  ifStmt
      :   IF
          L_PAREN condition=expr R_PAREN
          thenBranch=block
          (ELSE elseBranch=block)?
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `if-stmt`
      "if"
      "("
      'expr'#`condition`
      ")"
      'block'#`then branch`
      [
        "else"
        'block'#`else branch`
      ]?
    ]
    ```,
  )
)

#rule(<stmt.if.intro>)
#def("if-stmt")[Условная команда] позволяет выполнить @def:block[блок] в зависимости от значения условия.
Она состоит из выражения условия, ветки then и опциональной ветки else.

#rule(<stmt.if.condition>)
Выражение-условие должно иметь тип #type-expr(builtin-types.bool).
При исполнении команды оно вычисляется в первую очередь.

#rule(<stmt.if.condition.true>)
Если значение выражения — `true`, то исполнение команды продолжается исполнением ветки then.
Ветка else (при её наличии) пропускается.

#rule(<stmt.if.condition.false>)
Если значение выражения — `false`, то ветка then пропускается.
При наличии ветки else исполнение команды продолжается исполнением этой ветки.

#rule(<stmt.if.scopes>)
Команда создаёт следующие области видимости:
- @def:block-scope для ветки then
- @def:block-scope для ветки else

#rule(<stmt.if.scopes.current>)
@def:current-scope[Текущей областью видимости] является:
- для ветки then — @def:block-scope[область видимости блока] для ветки then
- для ветки else — @def:block-scope[область видимости блока] для ветки else

#rule-h(<stmt.assign>)
== Команда присваивания

#figure(
  ```antlr
  assignStmt
      :   lhs=assignee
          op=assignOp
          rhs=expr
          SEMICOLON
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `assign-stmt`
      'assignee'
      'assign-op'
      'expr'
      ";"
    ]
    ```,
  )
)

#rule(<stmt.assign.intro>)
#def("assign-stmt")[Команда присваивания] устанавливает новое значение по указанному месту.
Синтаксически она состоит из @def:assignee[места для присваивания], @def:assign-operator[оператора присваивания] и выражения присваиваемого значения.

#figure(
  ```antlr
  assignee
      :   name=ident # AssigneeName
      |   base=expr DOT field=ident # AssigneeField
      |   base=expr L_BRACKET index=expr R_BRACKET # AssigneeIndex
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `assignee`
      <
        'ident'#`name expression`,
        ['expr' "." 'ident']#`field expression`,
        ['expr' "[" 'expr' "]"]#`index expression`
      >
    ]
    ```
  )
)

#rule(<stmt.assign.assignee>)
#def("assignee")[Место для присваивания] является одним из @def:place-expr[выражений места].

#rule(<stmt.assign.assignee.mutable>)
Место для присваивания должно быть @def:expr-mutability[изменяемым].
#sema-err-def[Присваивание в неизменяемое место][Присваивание в неизменяемое место — семантическая ошибка.]

#figure(
  ```antlr
  assignOp
      :   EQ # OpAssign
      |   PLUS_EQ # OpAddAssign
      |   MINUS_EQ # OpSubAssign
      |   ASTERISK_EQ # OpMulAssign
      |   SLASH_EQ # OpDivAssign
      |   PERCENT_EQ # OpModAssign
      |   AMP_EQ # OpBitAndAssign
      |   PIPE_EQ # OpBitOrAssign
      |   CARET_EQ # OpBitXorAssign
      |   L_ANGLE_L_ANGLE_EQ # OpLShiftAssign
      |   R_ANGLE_R_ANGLE_EQ # OpRShiftAssign
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `assign-op`
      <
        "="#`basic assignment`,
        <
          "+=",
          "-=",
          "*=",
          "/=",
          "%=",
          "&=",
          "|=",
          "^=",
          "<<=",
          ">>="
        >#`compound assignment`
      >
    ]
    ```,
  )
)

#rule(<stmt.assign.operator>)
#def("assign-operator")[Оператор присваивания] разделяет место для присваивания и присваемое значение и определяет вид команды присваивания.
Присваивание с оператором `=` называется #def("basic-assignment")[Простое присваивание][простым].
Присваивание с использованием других операторов присваивания называется #def("compound-assignment")[Составное присваивание][составным].

#rule-h(<stmt.assign.basic>)
=== Простое присваивание

#rule(<stmt.assign.basic.execution>)
В простом присваивания сначала происходит вычисление выражения присваиваемого значения, после чего вычисляется место для присваивания.
В вычисленное место записывается присваемое значение.

#rule(<stmt.assign.basic.typing>)
Выражение присваиваемого значения должно @def:expr-conformity[соответствовать] типу места для присваивания.

#rule-h(<stmt.assign.compound>)
=== Составное присваивание

#rule(<stmt.assign.compound.intro>)
Составное присваивание сочетает присваивание с вычислением арифметической или побитовой бинарной операции.

#impl-spec(impls.rs)[
  Составное присваивание не поддерживается семантическим анализом.
]

#rule(<stmt.assign.compound.binary-op>)
Составному присваиванию с оператором присваивания #raw-box[$"op"$#skip-raw-box(`=`)] соответствует бинарная операция с оператором #raw-box[$"op"$].

#rule(<stmt.assign.compound.eval-order>)
При исполнении сначала происходит вычисление выражения присваиваемого значения, после чего вычисляется место для присваивания.

#rule(<stmt.assign.compound.execution>)
В вычисленное место присваивается результат применения бинарной операции:
+ В качестве значения первого операнда используется значение, находящееся по месту для присваивания.
  Повторного вычисления места при этом не происходит.
+ В качестве значения второго операнда используется присваиваемое.

#rule(<stmt.assign.compound.typing>)
На типы места для присваивания и выражения присваиваемого значения накладываются те же типовые ограничения, что и на операнды соответствующей бинарной операции.
Тип результата бинарной операции должен быть @def:type-coerce[неявно приводим] к типу места для присваивания.

#rule-h(<stmt.cancel>)
== Команда отмены перехода

#figure(
  ```antlr
  cancelStmt
      :   CANCEL SEMICOLON
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `cancel-stmt`
      "cancel"
      ";"
    ]
    ```,
  )
)

#rule(<stmt.cancel.intro>)
#def("cancel-stmt")[Команда отмены перехода] отменяет переход между состояниями при @def:function-execution[исполнении функции].

#rule(<stmt.cancel.sites>)
Команда отмены перехода может располагаться только в теле @def:function-decl[функции]-@def:method[метода] @def:automaton-decl[автомата].
#sema-err-def[Использование команды отмены перехода вне тела функции-метода автомата][Использование её в иных местах — семантическая ошибка.]

#impl-spec(impls.rs)[
  Проверка отсутствует.
]

#rule(<stmt.cancel.execution>)
При исполнении команда отменяет переход между состояниями автомата согласно @def:applicable-shift-rule[применимому] правилу перехода (@decl.automaton.state.transition).
В результате по завершении исполнения функции @def:automaton-state[именованное состояние] автомата останется прежним.

#rule-h(<stmt.expr>)
== Команда вычисления выражения

#figure(
  railroad(
    ```
    [
      `expr-stmt`
      'expr'
      ";"
    ]
    ```,
  )
)

#rule(<stmt.expr.intro>)
#def("expr-stmt")[Команда вычисления выражения] производит вычисление выражения и игнорирует его результат.

#rule(<stmt.expr.typing>)
Выражение может быть любого типа.
