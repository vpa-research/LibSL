#import "../meta.typ": *
#import "../railroad.typ": railroad
#import "../types.typ": type-expr, builtin-types

#rule-h(<decl>)
= Объявления

#rule(<decl.intro>)
#def("decl")[Объявление] — элемент спецификации, выступающий в роли директивы @def:processor[процессору] или для введения новых @def:entity[сущностей].

#figure(
  ```antlr
  globalDecl
      :   importDecl # GlobalDeclImport
      |   includeDecl # GlobalDeclInclude
      |   semanticTypeSectionDecl # GlobalDeclSemanticTypeSection
      |   typeAliasDecl # GlobalDeclTypeAlias
      |   structDecl # GlobalDeclStruct
      |   enumDecl # GlobalDeclEnum
      |   annotationDecl # GlobalDeclAnnotation
      |   actionDecl # GlobalDeclAction
      |   automatonDecl # GlobalDeclAutomaton
      |   functionDecl # GlobalDeclFunction
      |   procDecl # GlobalDeclProc
      |   predDecl # GlobalDeclPred
      |   variableDecl # GlobalDeclVariable
      ;
  ```
)

#figure(
  railroad(
    ```
    [
      `global-decl`
      <
        'import-decl',
        'include-decl',
        'semantic-type-section-decl',
        'type-alias-decl',
        'struct-decl',
        'enum-decl',
        'annotation-decl',
        'action-decl',
        'automaton-decl',
        'function-decl',
        'proc-decl',
        'pred-decl',
        'variable-decl'
      >
    ]
    ```,
  )
)

#rule(<decl.global>)
#def("global-decl")[Глобальное объявление] указывается на верхнем уровне @def:source-file[исходного файла].
Следующие объявления могут быть глобальными:
- @def:import-decl[объявление импорта]\;
- @def:include-decl[объявление включения]\;
- @def:semantic-types-decl[объявление секции семантических типов]\;
- @def:type-alias-decl[объявление псевдонима типа]\;
- @def:struct-decl[объявление структурного типа]\;
- @def:enum-decl[объявление перечислимого типа]\;
- @def:annotation-decl[объявление аннотации]\;
- @def:action-decl[объявление семантического действия]\;
- @def:automaton-decl[объявление автомата]\;
- @def:function-decl[объявление функции]\;
- @def:proc-decl[объявление процедуры]\;
- @def:pred-decl[объявление функционального предиката]\;
- @def:variable-decl[объявление переменной].

#rule(<decl.global.current-scope>)
@def:current-scope[Текущей областью видимости] для глобальных объявлений является @def:file-scope[область видимости файла], соответствующая @def:source-file[исходному файлу], в котором расположено объявление.

#rule(<decl.object>)
#def("object")[Объект] — значение типа, вводимого объявлением сущности, которая определяет @def:instance-scope[область видимости элементов экземпляра].
Такая сущность называется #def("object-entity")[Объектная сущность][объектной].

#rule(<decl.object.this>)
Выражения в сущностях, находящихся в @def:instance-scope[области видимости элементов экземпляра], имеют доступ к #def("this-var")[Переменная объекта][переменной объекта].
Она объявляется в области видимости элементов экземпляра, а также в @def:param-scope[области видимости] параметров @def:fn-entity[функциональных сущностей], являющихся @def:static-method[нестатическими методами].

#impl-spec(impls.rs)[
  Переменная недоступна в области видимости элементов экземпляра.
]

Переменная объекта имеет имя `this` и является @def:immutable-variable[неизменяемой].
Значение переменной — объект, к которому относится выражение.

#rule-h(<decl.import>)
== Объявление импорта

#figure(
  ```antlr
  importDecl
      :   IMPORT path SEMICOLON
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `import-decl`
      "import"
      'path'
      ";"
    ]
    ```,
  )
)

#rule(<decl.import.intro>)
#def("import-decl")[Объявление импорта] загружает файл по указанному @def:file-path[пути] в модуль и включает объявленные в нём сущности в @def:import-scope[область импортов] текущего файла (@name.import).

#rule-h(<decl.include>)
== Объявление включения

#figure(
  ```antlr
  includeDecl
      :   INCLUDE path SEMICOLON
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `include-decl`
      "include"
      'path'
      ";"
    ]
    ```,
  )
)

#rule(<decl.include.intro>)
#def("include-decl")[Объявление включения] указывает, что файл библиотеки, соответствующий текущему исходному файлу LibSL, требует зависимости по указанному пути для компиляции или исполнения.
Интерпретация конструкции задаётся @def:processor[процессором].

#rule-h(<decl.semantic-types>)
== Объявление секции семантических типов

#figure(
  ```antlr
  semanticTypeSectionDecl
      :   TYPES
          L_BRACE decls+=semanticTypeDecl* R_BRACE
      ;

  semanticTypeDecl
      :   annotations+=annotation*
          typeName=qualifiedTypeName
          L_PAREN realType=typeExpr R_PAREN
          semanticTypeDef
      ;

  semanticTypeDef
      :   SEMICOLON # SemanticTypeDefSimple
      |   L_BRACE values+=enumSemanticTypeValue* R_BRACE # SemanticTypeDefEnum
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `semantic-type-section-decl`
      "types"
      "{"
      ['semantic-type-decl'*[]]?
      "}"
    ]
    ```,
  )
)

#figure(
  railroad(
    ```
    {
      [
        `semantic-type-decl`
        ['annotation'*[]]?
      ],
      [
        'qualified-type-name'
        "("
        'type-expr'
        ")"
        'semantic-type-def'
      ]
    }
    ```,
  )
)

#figure(
  railroad(
    ```
    [
      `semantic-type-def`
      <
        ";"#`simple semantic type`,
        ["{" ['enum-semantic-type-value'*[]]? "}"]#`enum semantic type`
      >
    ]
    ```,
  )
)

#rule(<decl.semantic-types.intro>)
#def("semantic-types-decl")[Объявление секции семантических типов] вводит новые @def:semantic-type[семантические типы] в спецификацию.

#unresolved[
  Смысл семантических типов требует прояснения.
  Некоторые из вопросов, которые нужно понять:

  #set terms(separator: [.#h(0.5em)], hanging-indent: 0em)

  + / Представление в системе типов:
      Являются ли они типами в принципе?
      Как они соотносятся с "реальными" типами: приводимы ли они друг к другу (или только в одном направлении), либо же являются равными, либо только эквивалентными?

  + / Ограничения на использование:
      Где можно использовать семантический тип?
      Можно ли задать переменную такого типа, передать его в генерик или параметр функции?
      Какие операции допускаются над значениями семантического типа?

  + / Runtime:
      Какие значения у семантического типа?
      Каковы их динамические типы?
]

#impl-spec(impls.rs)[
  Семантический анализ семантических типов не поддерживается.
]

#rule-h(<decl.type-alias>)
== Объявление псевдонима типа

#figure(
  ```antlr
  typeAliasDecl
      :   annotations+=annotation*
          TYPEALIAS typeName=qualifiedTypeName
          EQ def=typeExpr
          SEMICOLON
      ;
  ```,
)

#figure(
  railroad(
    ```
    {
      [`type-alias-decl` ['annotation'*[]]?],
      ["typealias" 'qualified-type-name' "=" 'type-expr' ";"]
    }
    ```,
  )
)

#rule(<decl.type-alias.intro>)
#def("type-alias-decl")[Объявление псевдонима типа] вводит новое имя для существующего типа в @def:namespace[пространство имён] типов @def:current-scope[текущей области видимости].

#rule(<decl.type-alias.identity>)
Тип, записанный при помощи введённого псевдонима, идентичен его определению.
Два варианта неотличимы в системе типов.

#rule(<decl.type-alias.scopes>)
Объявление псевдонима типа вводит следующие @def:scope[области видимости]:
- @def:param-scope

#rule(<decl.type-alias.scopes.current>)
@def:current-scope[Текущей областью видимости] является:
- для @def:type-expr[типового выражения] после знака `=` и типовых параметров псевдонима типа — @def:param-scope[область видимости параметров]

#rule-h(<decl.struct>)
== Объявление структурного типа

#figure(
  ```antlr
  structDecl
      :   annotations+=annotation*
          TYPE typeName=qualifiedTypeName
          targetType=structTargetType?
          typeConstraints=whereClause?
          (L_BRACE decls+=structDefDecl* R_BRACE)?
      ;

  structTargetType
      :   (IS isType=typeExpr)?
          FOR forTypes=typeExprList COMMA?
      ;

  structDefDecl
      :   variableDecl # StructDefDeclVariable
      |   functionDecl # StructDefDeclFunction
      |   procDecl # StructDefDeclProc
      |   predDecl # StructDefDeclPred
      ;
  ```,
)

#figure(
  railroad(
    ```
    {
      [`struct-decl` ['annotation'*[]]?],
      ["type" 'qualified-type-name' 'struct-target-type'?],
      ['where-clause'?],
      ["{" ['struct-def-decl'*[]]? "}"]?
    }
    ```,
  )
)

#figure(
  railroad(
    ```
    [
      `struct-target-type`
      ["is" 'type-expr']?
      "for" 'type-expr'*"," ","?
    ]
    ```,
  )
)

#figure(
  railroad(
    ```
    [
        `struct-def-decl`
        <
          'variable-decl',
          'function-decl',
          'proc-decl',
          'pred-decl'
        >
    ]
    ```,
  )
)

#rule(<decl.struct.intro>)
#def("struct-decl")[Объявление структурного типа] вводит новый именованный структурный тип в @def:namespace[пространство имён] типов @def:current-scope[текущей области видимости].
Структурный тип состоит из полей, задаваемых с помощью @def:variable-decl[объявлений переменных].
С типом также ассоциированы @def:function-decl[функции], @def:proc-decl[процедуры] и @def:pred-decl[функциональные предикаты].

#rule(<decl.struct.constructor>)
Объявление структурного типа также вводит новую @def:pure-proc[чистую процедуру] с теми же именем и типовыми параметрами, что у структурного типа.
Параметрами функции являются объявленные поля в том же порядке.
Она является #def("struct-constructor")[Конструктор структуры][конструктором структуры].

#unresolved[
  Что означает конструкция `struct-target-type`?
  Если она не влияет на семантику, не стоит ли её указать аннотацией?
]

#impl-spec(impls.rs)[
  Конструкция `struct-target-type` игнорируется при семантическом анализе.
]

#rule(<decl.struct.constructor.call>)
@def:call[Вызов] конструктора приводит к созданию новой @def:struct-value[структуры] данного типа.
Поля структуры соответственно инициализируются переданными аргументами.

#example[
  ```libsl
  struct Foo<T> {
    val x: int32;
    var y: T;
  }
  ```

  Данное объявление неявно также вводит следующую процедуру:

  ```libsl
  pure proc Foo<T>(x: int32, y: T): Foo<T>
  ```

  Следующий вызов создаст значение структуры `Foo`:

  ```libsl
  Foo(42, false)
  ```

  Поле `x` будет инициализировано значением `42`, а `y` — `false`.
]

#rule(<decl.struct.scopes>)
Объявление структурного типа вводит следующие @def:scope[области видимости]:
- @def:param-scope
  - @def:member-scope
  - @def:instance-scope

#rule(<decl.struct.scopes.current>)
@def:current-scope[Текущей областью видимости] является:
- для типовых параметров и ограничений — @def:param-scope[область видимости параметров]
- для @def:static-method[статических методов] — @def:member-scope[область видимости ассоциированных сущностей]
- для полей и нестатических методов — @def:instance-scope[область видимости элементов экземпляра]

#rule-h(<decl.enum>)
== Объявление перечислимого типа

#figure(
  ```antlr
  enumDecl
      :   annotations+=annotation*
          ENUM typeName=fullName
          L_BRACE variants+=enumDeclVariant* R_BRACE
      ;

  enumDeclVariant
      :   name=ident EQ value=signedIntLit SEMICOLON
      ;

  signedIntLit
      :   sign?
          lit=IntegerLit
      ;

  sign
      :   MINUS # MinusSign
      |   PLUS # PlusSign
      ;
  ```
)

#figure(
  railroad(
    ```
    {
      [`enum-decl` ['annotation'*[]]?],
      ["enum" 'full-name' "{" ['enum-decl-variant'*[]]? "}"]
    }
    ```
  )
)

#figure(
  railroad(
    ```
    [
      `enum-decl-variant`
      'ident'
      "="
      <!, "-", "+">
      'integer-lit'
      ";"
    ]
    ```
  )
)

#rule(<decl.enum.intro>)
#def("enum-decl")[Объявление перечислимого типа] вводит новый именованный перечислимый тип в @def:namespace[пространство имён] типов @def:current-scope[текущей области видимости].
Перечислимый тип является @def:integral-type[целочисленным типом].

#rule(<decl.enum.variants>)
Перечислимый тип содержит набор именованных значений этого типа, называемых его #def("enum-variant")[Вариант перечислимого типа][вариантами].
Каждому варианту соответствует целочисленный литерал, определяющий его #def("enum-underlying-value")[Нижележащее значение перечислимого типа][нижележащее значение].

#rule(<decl.enum.non-injective>)
Литералы, соответствующие двум разным вариантам, могут совпадать.

#example[
  ```libsl
  enum Foo {
    FIRST = 0;
    SECOND = 0;
  }
  ```
]

#rule(<decl.enum.equality>)
Два значения одного и того же перечислимого типа равны, если равны их нижележащие значения.

#note[
  В частности, в примере выше `Foo.FIRST` равен `Foo.SECOND`.
]

#rule(<decl.enum.underlying-type>)
Перечислимый тип имеет #def("enum-underlying-type")[Определяющий тип][определяющий тип].
Он задаёт @def:integral-type-width[ширину], @def:integral-type-signedness[знаковость] и область значений перечислимого типа.
Определяющий тип является @def:primitive-integer-type[примитивным целочисленным типом] наименьшей ширины, к которому приводимы литералы в вариантах.

#example[
  ```libsl
  enum I32 {
    FIRST = 1;
    SECOND = 2;
  }
  ```

  Оба литерала имеют тип #type-expr(builtin-types.int32).
  Поэтому определяющий тип — #type-expr(builtin-types.int32).

  ```libsl
  enum U64 {
    U8 = 1ux;
    U16 = 2us;
    U32 = 3u;
    U64 = 4uL;
  }
  ```

  Типы литералов — #type-expr(builtin-types.unsigned8), #type-expr(builtin-types.unsigned16), #type-expr(builtin-types.unsigned32) и #type-expr(builtin-types.unsigned64).
  Таким образом, определяющий тип — #type-expr(builtin-types.unsigned64).
]

#rule(<decl.enum.underlying-type.empty>)
При отсутствии вариантов определяющим типом является #type-expr(builtin-types.int32).

#rule(<decl.enum.underlying-type.non-existence>)
#sema-err-def[Невозможность вывести определяющий тип у перечислимого типа][Несуществование подходящего определяющего типа является семантической ошибкой.]

#example[
  ```libsl
  enum Erroneous {
    SIGNED = -42;
    UNSIGNED = 42u;
  }
  ```

  Так как приведение типов обязано сохранить знаковость типов, не существует какого-либо примитивного целочисленного типа, к которому одновременно приводимы и знаковый (`-42`), и беззнаковый (`42u`) литералы вариантов.
  Объявление поэтому ошибочно.
]

#rule(<decl.enum.non-exhaustive>)
Список вариантов в общем случае не исчерпывает набор значений перечислимого типа.
Набор значений определяется областью значения определяющего типа.
Таким образом, путём @def:cast-expr[преобразований типов] можно получить значение, не равное ни одному из вариантов.

#rule(<decl.enum.scopes>)
Объявление перечислимого типа вводит следующие @def:scope[области видимости]:
- @def:param-scope
  - @def:member-scope

#rule(<decl.enum.scopes.current>)
@def:current-scope[Текущей областью видимости] является:
- для типовых вариантов — @def:param-scope[область видимости параметров]
- для вариантов ­— @def:member-scope[область видимости ассоциированных сущностей]

#rule-h(<decl.annotation>)
== Объявление аннотации

#figure(
  ```antlr
  annotationDecl
      :   ANNOTATION name=ident
          L_PAREN (params=annotationParamList COMMA?)? R_PAREN
          SEMICOLON
      ;

  annotationParamList
      :   params+=annotationParam
          (COMMA params+=annotationParam)*
      ;

  annotationParam
      :   name=ident
          COLON type=typeExpr
          (EQ default=expr)?
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `annotation-decl`
      "annotation"
      "("
      [
        'annotation-param'*[","]
        ","?
      ]?
      ")"
      ";"
    ]
    ```,
  )
)

#figure(
  railroad(
    ```
    [
      `annotation-param`
      'ident'
      ":"
      'type-expr'
      ["=" 'expr']?
    ]
    ```,
  )
)

#rule(<decl.annotation.intro>)
#def("annotation-decl")[Объявление аннотации] вводит новую @def:annotation[аннотацию] в @def:namespace[пространство имён] аннотаций @def:current-scope[текущей области видимости].

#rule(<decl.annotation.default.optional>)
У параметра аннотации может быть указано #def("annotation-default-expr")[Выражение по умолчанию параметра аннотации][выражение по умолчанию].
Такой параметр является опциональным при использовании аннотации.
При его отсутствии значение параметра вычисляется на основании выражения по умолчанию.

#rule(<decl.annotation.default.eval>)
Вычисление выражения по умолчанию производится в каждом месте использования аннотации, если параметр не указан.
На месте объявления выражение не вычисляется.
Также не производится вычисление, если в месте использования для параметра указан аргумент.

#rule(<decl.annotation.default.position>)
Опциональные параметры обязаны располагаться в конце списка.
#sema-err-def[Размещение обязательного параметра аннотации после опционального][Расположение обязательного параметра после опционального — семантическая ошибка.]

#rule(<decl.annotation.scopes>)
Объявление аннотации вводит следующие @def:scope[области видимости]:
- @def:param-scope

#rule(<decl.annotation.scopes.current>)
@def:current-scope[Текущей областью видимости] является:
- для параметров и их выражений по умолчанию — @def:param-scope[область видимости параметров]

#rule-h(<decl.action>)
== Объявление семантического действия

#figure(
  ```antlr
  actionDecl
      :   annotations+=annotation*
          DEFINE ACTION name=ident
          typeParams=generics?
          L_PAREN (params=actionParamList COMMA?)? R_PAREN
          (COLON retType=typeExpr)?
          typeConstrants=whereClause?
          SEMICOLON
      ;

  actionParamList
      :   params+=actionParam
          (COMMA params+=actionParam)*
      ;

  actionParam
      :   annotations+=annotation*
          name=ident
          COLON type=typeExpr
      ;
  ```
)

#figure(
  railroad(
    ```
    [
      {
        [
          `action-decl`
          "define"
          "action"
          'ident'
          'generics'?
        ],
        [
          "("
          [
            'action-param'*","
            ","
          ]?
          ")"
          ":"
          'type-expr'
        ],
        [
          'where-clause'?
        ]
      }
      ";"
    ]
    ```,
  )
)

#figure(
  railroad(
    ```
    [
      `action-param`
      ['annotation'*[]]?
      'ident'
      ":"
      'type-expr'

    ]
    ```,
  )
)

#rule(<decl.action.intro>)
#def("action-decl")[Объявление семантического действия] вводит новое семантическое действие в @def:namespace[пространство имён] семантических действий @def:current-scope[текущей области видимости].
Объявленное семантическое действие может использоваться в @def:action-call-expr[выражении вызова семантического действия] для обозначения поведения, определяемого @def:processor[процессором].

#rule(<decl.action.processor>)
Смысл семантического действия определяется @def:processor[процессором].
Процессор может вводить ограничения на объявление семантических действий.
#sema-err-def[Объявление недопустимого семантического действия][Нарушение таких ограничений — семантическая ошибка.]

#note[
  Например, процессор может требовать определённых имён и сигнатур либо вовсе запрещать объявление семантических действий.
]

#rule(<decl.action.scopes>)
Объявление семантического действия вводит следующие @def:scope[области видимости]:
- @def:param-scope

#rule(<decl.action.scopes.current>)
@def:current-scope[Текущей областью видимости] является:
- для параметров (включая @def:type-param[типовые]), @def:type-expr[типового выражения] типа возврата и типовых ограничений — @def:param-scope[область видимости параметров]

#rule-h(<decl.automaton>)
== Объявление автомата

#figure(
  ```antlr
  automatonDecl
      :   annotations+=annotation*
          AUTOMATON concept=CONCEPT? name=qualifiedTypeName
          (L_PAREN (constructorVariables=constructorVariableList COMMA?)? R_PAREN)?
          COLON type=typeExpr
          (implements=implementedConcepts COMMA?)*
          typeConstraints=whereClause?
          L_BRACE decls+=automatonDefDecl* R_BRACE
      ;

  constructorVariableList
      :   variables+=constructorVariable
          (COMMA variables+=constructorVariable)*
      ;

  implementedConcepts
      :   IMPLEMENTS concepts+=ident
          (COMMA concepts+=ident)*
      ;
  ```
)

#figure(
  railroad(
    ```
    [
      {
        [
          `automaton-decl`
          ['annotation'*[]]?
        ],
        [
          "automaton"
          "concept"?
          'qualified-type-name'
        ],
        [
          "("
          [
            'constructor-variable'*","
            ","
          ]?
          ")"
        ]?,
        [
          ":"
          'type-expr'
        ],
        [
          "implements"
          'ident'*","
          ","?
        ]?,
        'where-clause'?
      }
      [
        "{"
        ['automaton-def-decl'*[]]?
        "}"
      ]
    ]
    ```,
  )
)

#rule(<decl.automaton.intro>)
#def("automaton-decl")[Объявление автомата] вводит новый автомат в @def:namespace[пространство имён] автоматов @def:current-scope[текущей области видимости].
Автоматы обладают @def:automaton-state[состоянием], объявленными между ними @def:shift-decl[правилами перехода], а также @def:variable-decl[полями] и методами.

#rule-h(<decl.automaton.state>)
=== Состояние автомата

#rule(<decl.automaton.state.named>)
Автомату присуще #def("automaton-state")[Именованное состояние автомата][именованное состояние].
Возможные состояния задаются явно посредством @def:state-decl[объявлений состояний].
В каждый момент времени автомат может пребывать только в одном из этих состояний.

#rule(<decl.automaton.state.transition>)
Переходы между состояниями осуществляются неявно вследствие исполнения @def:function-decl[функций].
Исходное состояние и исполненная функция однозначно определяют следующее состояние автомата на основе @def:shift-decl[правил перехода].
Переход производится после вычисления функции.

#rule(<decl.automaton.state.final>)
Переход автомата в @def:final-state[конечное состояние] обозначает конец его времени жизни.
#runtime-err-def[Исполнение функций автомата после перехода в конечное состояние][Исполнение функций автомата после этого — ошибка времени исполнения.]

#unresolved[
  Что конкретно это означает с точки зрения семантики?
  Можно ли обращаться к полям, звать процедуры?
]

#rule(<decl.automaton.state.extended>)
#def("extended-automaton-state")[Расширенное состояние автомата] состоит из именованного состояния автомата и значения его @def:variable-decl[полей].

#rule-h(<decl.automaton.constructor>)
=== Конструктор автомата
#figure(
  ```libsl
  constructorVariable
      :   annotations+=annotation*
          kind=variableKind
          name=ident
          COLON type=typeExpr
          (EQ init=expr)?
      ;
  ```,
)

#figure(
  railroad(
    ```
    {
      [
        `constructor-variable`
        ['annotation'*[]]?
      ],
      [
        <"var", "val">
        'ident'
        ":"
        'type-expr'
        ["=" 'expr']?
      ]
    }
    ```,
  )
)

#rule(<decl.automaton.constructor.intro>)
Часть полей автомата могут быть объявлены как #def("constructor-variable")[Переменная конструктора автомата][переменные конструктора].
Значения этих полей могут быть заданы при @def:instantiation-expr[инстанцировании автомата] наряду с начальным состоянием.

#rule(<decl.automaton.constructor.default.optional>)
Переменные конструктора, у которых указано #def("constructor-variable-default-expr")[Выражение по умолчанию переменной конструктора автомата][выражение по умолчанию], могут отсутствовать в @def:instantiation-expr[выражении инстанцирования].
В этом случае переменные конструктора получат значение в результате вычисления выражения по умолчанию.

#rule(<decl.automaton.constructor.default.eval>)
Вычисление выражения по умолчанию производится в каждом месте инстанцирования автомата, если значение переменной не указано.
На месте объявления выражение не вычисляется.
Также не производится вычисление, если в месте инстанцирования для переменной указано значение.

#rule(<decl.automaton.constructor.required-param>)
Переменные конструктора могут не иметь выражения по умолчанию.
В этом случае их значение требуется явно задавать при @def:instantiation-expr[инстанцировании].

#rule-h(<decl.automaton.underlying>)
=== Нижележащий тип

#rule(<decl.automaton.underlying.intro>)
После переменных конструктора в объявлении автомата указывается его #def("automaton-underlying-type")[Нижележащий тип автомата][нижележащий тип].

#unresolved[
  Как соотносится нижележащий тип с автоматом?

  Насколько смог понять, в LibSL 1 автомат был "оверлеем" над нижележащим типом, но тогда @def:instantiation-expr[выражение инстанцирования] теряет смысл, так как значение этого нижележащего типа негде указывать.

  Также непонятно, как автомат привязан к значению.
  Например, если `x` ­— это `int32` с автоматом `SOCKET`, то что будет, если я сделаю `x + 1`?
  А `x + x`?

  Есть подозрение, что наиболее прямолинейно автоматы считать новым типом.

]

#rule-h(<decl.automaton.concept>)
=== Концепты

Ключевое слово `concept` в объявлении создаёт #def("automaton-concept")[Автоматный концепт][автоматный концепт].

#unresolved[
  Что значит автоматный концепт?
]

#TODO[описать `implements`]

#impl-spec(impls.rs)[
  Семантический анализ игнорирует концепты.
]

#rule-h(<decl.automaton.nested-decls>)
=== Вложенные объявления

#figure(
  ```antlr
  automatonDefDecl
      :   stateDecl # AutomatonDefDeclState
      |   shiftDecl # AutomatonDefDeclShift
      |   constructorDecl # AutomatonDefDeclConstructor
      |   destructorDecl # AutomatonDefDeclDestructor
      |   procDecl # AutomatonDefDeclProc
      |   predDecl # AutomatonDefDeclPred
      |   functionDecl # AutomatonDefDeclFunction
      |   variableDecl # AutomatonDefDeclVariable
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `automaton-def-decl`
      <
        'state-decl',
        'shift-decl',
        'constructor-decl',
        'destructor-decl',
        'proc-decl',
        'pred-decl',
        'function-decl',
        'variable-decl'
      >
    ]
    ```,
  )
)

#rule(<decl.automaton.nested-decls.intro>)
Внутри объявления автомата могут встречаться следующие объявления:
- @def:state-decl[объявления состояний] — задают состояния автомата;
- @def:shift-decl[объявления правил перехода] — задают возможные переходы между состояниями автомата;
- @def:constructor-decl[объявления функций-конструкторов] — #TODO[неизвестно, зачем они]\;
- @def:destructor-decl[объявления функций-деструкторов] — #TODO[неизвестно, зачем они]\;
- @def:proc-decl[объявления процедур] — задают процедуры-методы;
- @def:pred-decl[объявления функциональных предикатов] — задают функциональные предикаты-методы;
- @def:function-decl[объявления функций] — задают функции-методы;
- @def:variable-decl[объявления переменных] — задают поля расширенного состояния автомата.

#rule-h(<decl.automaton.scopes>)
=== Области видимости

Объявление автомата вводит следующие @def:scope[области видимости]:
- @def:member-scope
  - @def:param-scope
    - @def:instance-scope

#rule(<decl.automaton.scopes.current>)
@def:current-scope[Текущей областью видимости] является:
- для @def:static-method[статических методов], @def:state-decl[объявлений состояний] — @def:member-scope[область видимости ассоциированных сущностей]
- для @def:param-scope[типовых параметров] и типовых ограничений — @def:param-scope[область видимости параметров]
- для полей (включая переменные конструктора) и нестатических методов — @def:instance-scope[область видимости параметров]

#rule-h(<decl.fn>)
== Функциональные сущности

#rule(<decl.fn.intro>)
Ряд сущностей в LibSL являются #def("fn-entity")[Функциональная сущность][функциональными].
Они добавляются в @def:scope[область видимости] функциональных сущностей, и для них действуют @def:overload-resolution[специальные правила] разрешения имён, так как для них допускается перегрузка.

#rule(<decl.fn.entity-list>)
Функциональными сущностями являются:
- @def:function-decl[функции]\;
- @def:constructor-decl[функции-конструкторы]\;
- @def:destructor-decl[функции-деструкторы]\;
- @def:proc-decl[процедуры]\;
- @def:pred-decl[функциональные предикаты].

#rule(<decl.fn.global>)
Функциональная сущность, объявленная на верхнем уровне, называется #def("global-fn-entity")[Глобальная функциональная сущность][глобальной].

#rule(<decl.fn.method>)
Функциональная сущность, вложенная в объявление @def:struct-decl[структурного типа] или @def:automaton-decl[автомата], называется #def("method")[Метод][методом].

#rule(<decl.fn.method.static>)
Некоторые функциональные сущности позволяют пометить метод как #def("static-method")[Статический метод][статический].
Такой метод не привязан к экземпляру объемлющего объявления.

#rule(<decl.fn.result>)
Ряд функциональных сущностей определяют #def("result-var")[Переменная возвращемого значения][переменную возвращаемого значения].
Она имеет имя `result`, является @def:mutable-variable[изменяемой] и определяется в @def:param-scope[области видимости параметров] функциональной сущности.

#rule(<decl.fn.result.prev-inaccessible>)
Переменная возвращаемого значения является @def:prev-inaccessible-local[недоступной в предыдущем состоянии].

#rule-h(<decl.fn.function>)
=== Объявление функции

#context query(<fun-syntax-railroad>).at(0).value.map(figure).join(parbreak())

#rule(<decl.fn.function.intro>)
#def("function-decl")[Объявление функции] (см. @fun-syntax) вводит новую функцию в @def:namespace[пространство имён] функциональных сущностей @def:current-scope[текущей области видимости].
Функция является @def:fn-entity[функциональной сущностью].

#rule(<decl.fn.function.execution>)
Функция не может быть вызвана.
Вычисление её тела производится в ходе её @def:function-execution[исполнения].
Момент исполнения функции определяется @def:processor[процессором].
Язык не предусматривает способов запуска исполнения функции изнутри спецификации.

#note[
  Функция LibSL моделирует некоторую внешнюю функцию описываемой библиотеки.
  Исполнение функции LibSL тогда соответствует вызову внешней функции.
]

#rule(<decl.fn.function.global>)
@def:global-fn-entity[Глобальная] функция добавляется в @def:file-scope[область видимости текущего файла].

#rule(<decl.fn.function.global.static>)
#sema-err-def[Использование модификатора `static` в объявлении глобальной функции][Наличие модификатора `static` в объявлении @def:global-fn-entity[глобальной] функции — семантическая ошибка.]

#impl-spec(impls.rs)[
  Проверка отсутствует.
]

#rule(<decl.fn.function.method>)
Функция-@def:method[метод], объявленная без модификатора `static`, добавляется в @def:instance-scope[область видимости элементов экземпляра].

#rule(<decl.fn.function.method.static>)
Функция-@def:method[метод], объявленная с модификатором `static`, добавляется в @def:member-scope[область видимости ассоциированных сущностей].
Такой метод является @def:static-method[статическим].

#rule(<decl.fn.function.extension>)
Функция, в объявлении которой присутствует спецификатор расширения, называется #def("extension-function")[Функция-расширение][функцией-расширением].

#unresolved[
  Имеет ли это вообще смысл в LibSL, если расширение возможно только у функций, которые вызвать изнутри LibSL всё равно не получится?
]

#impl-spec(impls.rs)[
  Функции-расширения в семантическом анализе обрабатываются так же, как обычные функции.
]

#rule(<decl.fn.function.method-spec>)
#unresolved[
  Каков смысл `*.`?
  Как он соотносится с модификатором `static`?
  Стоит ли последний обобщить до остальных функциональных сущностей (сейчас статичекими могут быть только функции)?
]

#rule(<decl.fn.function.result>)
Функция имеет возвращаемое значение указанного типа.
Функция определяет @def:result-var[переменную возвращаемого значения] с этим типом.

#rule(<decl.fn.function.implicit-return>)
Если тип возвращаемого значения не указан, он принимается за `void`.

#rule-h(<decl.fn.constructor>)
=== Объявление функции-конструктора

#figure(
  ```antlr
  constructorDecl
      :   annotations+=annotation*
          CONSTRUCTOR
          method=methodSpec?
          name=ident?
          L_PAREN (params=functionParamList COMMA?)? R_PAREN
          (COLON retType=typeExpr)?
          def=functionDef
      ;
  ```,
)

#figure(
  railroad(
    ```
    {
      [
        `constructor-decl`
        ['annotation'*[]]?
      ],
      [
        "constructor"
        [
          "*"
          "."
        ]?#`method specifier`
        'ident'?#`name`
      ],
      [
        "("
        [
          'function-param'*","
          ","?
        ]?
        ")"
        [
          ":"
          'type-expr'
        ]?#`result type`
      ],
      <
        ["{" 'function-body' "}"],
        ";"?
      >
    }
    ```,
  )
)

#rule(<decl.fn.constructor.intro>)
#def("constructor-decl")[Объявление функции-конструктора] вводит новую функцию в @def:namespace[пространство имён] функциональных сущностей @def:current-scope[текущей области видимости].

#rule(<decl.fn.constructor.implicit-name>)
Если в объявлении имя не задано, в качестве него берётся `constructor`.

#rule(<decl.fn.constructor.method-spec>)
#TODO[прояснить природу `.*`, как в функциях]

#unresolved[
  Какова семантика функций-конструкторов?
  Нужны ли они вообще в LibSL: может, лучше сделать аннотации или модификаторы функций, чтобы не плодить сущности?
]

#rule-h(<decl.fn.destructor>)
=== Объявление деструктора

#figure(
  ```antlr
  destructorDecl
      :   annotations+=annotation*
          DESTRUCTOR
          method=methodSpec?
          name=ident?
          L_PAREN (params=functionParamList COMMA?)? R_PAREN
          (COLON retType=typeExpr)?
          def=functionDef
      ;
  ```,
)

#figure(
  railroad(
    ```
    {
      [
        `destructor-decl`
        ['annotation'*[]]?
      ],
      [
        "destructor"
        [
          "*"
          "."
        ]?#`method specifier`
        'ident'?#`name`
      ],
      [
        "("
        [
          'function-param'*","
          ","?
        ]?
        ")"
      ],
      [
        ":"
        'type-expr'
      ]?#`result type`,
      <
        ["{" 'function-body' "}"],
        ";"?
      >
    }
    ```,
  )
)

#rule(<decl.fn.destructor.intro>)
#def("destructor-decl")[Объявление деструктора] вводит новую функцию в @def:namespace[пространство имён] функциональных сущностей @def:current-scope[текущей области видимости].

#rule(<decl.fn.destructor.implicit-name>)
Если в объявлении имя не задано, в качестве него берётся `destructor`.

#rule(<decl.fn.destructor.method-spec>)
#TODO[прояснить природу `.*`, как в функциях]

#unresolved[
  Какова семантика функций-деструкторов?
  Нужны ли они вообще в LibSL: может, лучше сделать аннотации или модификаты функций, чтобы не плодить сущностей?
  И что в принципе может означать тип результата у деструктора?
]

#rule-h(<decl.fn.proc>)
=== Объявление процедуры

#figure(
  ```antlr
  procDecl
      :   annotations+=annotation*
          modifiers+=procModifier*
          PROC
          method=methodSpec?
          name=ident
          typeParams=generics?
          L_PAREN (params=functionParamList COMMA?)? R_PAREN
          (COLON retType=typeExpr)?
          typeConstraints=whereClause?
          def=functionDef
      ;

  procModifier
      :   PURE # ProcModifierPure
      |   STATIC # ProcModifierStatic
      ;
  ```,
)

#figure(
  railroad(
    ```
    {
      [
        `proc-decl`
        ['annotation'*[]]?
      ],
      [
        ['proc-modifier'*[]]?
        "proc"
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
  )
)

#figure(
  railroad(
    ```
    [
      `proc-modifier`
      <
        "pure",
        "static"
      >
    ]
    ```,
  )
)

#rule(<decl.fn.proc.intro>)
#def("proc-decl")[Объявление процедуры] вводит новую процедуру в @def:namespace[пространство имён] функциональных сущностей @def:current-scope[текущей области видимости].
Процедура является @def:fn-entity[функциональной сущностью].

Процедура может быть вызвана посредством @def:call-expr[выражения вызова].

#note[
  В отличие от @def:function-decl[функций], процедура не соответствует какой-либо внешней функции описываемой библиотеки.
  Она служит той же роли, что и функции в других языках: используется для структурирования спецификации и избавлении её от повторяющихся частей.
]

#rule(<decl.fn.proc.global>)
@def:global-fn-entity[Глобальная] процедура добавляется в @def:file-scope[область видимости текущего файла].

#rule(<decl.fn.proc.global.static>)
#sema-err-def[Использование модификатора `static` в объявлении глобальной процедуры][Наличие модификатора `static` в объявлении @def:global-fn-entity[глобальной] процедуры — семантическая ошибка.]

#impl-spec(impls.rs)[
  Проверка отсутствует.
]

#rule(<decl.fn.proc.method>)
Процедура-@def:method[метод], объявленная без модификатора `static`, добавляется в @def:instance-scope[область видимости элементов экземпляра].

#rule(<decl.fn.proc.method.static>)
Процедура@def:method[метод], объявленная с модификатором `static`, добавляется в @def:member-scope[область видимости ассоциированных сущностей].
Такой метод является @def:static-method[статическим].

#rule(<decl.fn.proc.method-spec>)
#TODO[прояснить природу `.*`, как в функциях]

#rule(<decl.fn.proc.pure>)
Процедура с модификатором `pure` называется #def("pure-proc")[Чистая процедура][чистой].
Тело такой процедуры находится в @def:pure-context[чистом контексте].

#note[
  Чистые процедуры могут использоваться в @def:pred[предикатах] и других чистых процедурах.
]

#rule(<decl.fn.proc.result>)
Процедура имеет возвращаемое значение указанного типа.
Процедура определяет @def:result-var[переменную возвращаемого значения] с этим типом.

#rule(<decl.fn.proc.implicit-return>)
Если тип возвращаемого значения не указан, он принимается за `void`.

#rule-h(<decl.fn.pred>)
=== Объявление функционального предиката

#figure(
  ```antlr
  predDecl
      :   annotations+=annotation*
          PRED
          name=ident
          typeParams=generics?
          L_PAREN (params=functionParamList COMMA?)? R_PAREN
          typeConstraints=whereClause?
          def=blockPredicate?
      ;
  ```,
)

#figure(
  railroad(
    ```
    {
      [
        `pred-decl`
        ['annotation'*[]]?
        'name'
      ],
      [
        'generics'?
        "("
        [
          'function-param'*","
          ","?
        ]?
        ")"
      ],
      'where-clause'?,
      'block-predicate'?
    }
    ```,
  )
)

#rule(<decl.fn.pred.intro>)
#def("pred-decl")[Объявление функционального предиката] вводит новый функциональный предикат в @def:namespace[пространство имён] функциональных сущностей @def:current-scope[текущей области видимости].
Функциональный предикат является @def:fn-entity[функциональной сущностью].

Функциональный предикат может быть вызван из предикатов при помощи @def:call-expr[выражения вызова].

#note[
  Так же, как @def:proc-decl[процедуры] служат для структурирования и устранения повторяющегося кода в теле @def:function-decl[функций], функциональные предикаты позволяют структурировать и дедублицировать повторяющиеся фрагменты в их @def:contract[контрактах].
]

#rule(<decl.fn.pred.global>)
@def:global-fn-entity[Глобальный] функциональный предикат добавляется в @def:file-scope[область видимости текущего файла].

#rule(<decl.fn.pred.method>)
Функциональный предикат-@def:method[метод] добавляется в @def:instance-scope[область видимости элементов экземпляра].

#rule(<decl.fn.pred.body>)
#def("pred-body")[Тело функционального предиката][Телом функционального предиката] является @def:block-pred[блоковый предикат].
Истинность функционального предиката отождествляется с истинностью тела.

#rule(<decl.fn.pred.body.implicit>)
При отсутствии явного тела функциональный предикат считается тождественно истинным.

#rule-h(<decl.fn.body>)
=== Тело функциональной сущности

#figure(
  ```antlr
  functionBody
      :   contracts+=contract*
          stmts+=stmt*
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `function-body`
      ['contract'*[]]?
      ['stmt'*[]]?
    ]
    ```,
  )
)

#def("fn-body")[Тело функциональной сущности][Тело] @def:function-decl[функций], @def:constructor-decl[функций-конструкторов], @def:destructor-decl[функций-деструкторов] и @def:proc-decl[процедур] состоит из ряда @def:contract[контрактов] и последовательности @def:stmt[команд].

#rule-h(<decl.fn.scopes>)
=== Области видимости функциональной сущности

Объявления функциональных сущностей вводят следующие @def:scope[области видимости]:

- @def:param-scope
  - @def:block-scope (тела функции)

#rule(<decl.fn.scopes.current>)
@def:current-scope[Текущей областью видимости] является:

- для параметров (в том числе @def:type-param[типовых], а также неявные переменные @def:this-var[объекта] и @def:result-var[возвращаемого значения] при их объявлении), @def:type-expr[типового выражения] возвращаемого типа и типовых ограничений — @def:param-scope[область видимости параметров]

- для контрактов и команд — область видимости тела функции

#rule-h(<decl.variable>)
== Объявление переменной

#figure(
  ```antlr
  variableDecl
      :   annotations+=annotation*
          kind=variableKind
          name=ident
          (COLON type=typeExpr)?
          (EQ init=expr)?
          SEMICOLON
      ;

  variableKind
      :   VAR # VariableKindVar
      |   VAL # VariableKindVal
      ;
  ```,
)

#figure(
  railroad(
    ```
    {
      [
        `variable-decl`
        ['annotation'*[]]?
      ],
      [
        <"var", "val">
        'ident'
        [":" 'type-expr']?
        ["=" 'expr']?
        ";"
      ]
    }
    ```,
  )
)

#rule(<decl.variable.intro>)
#def("variable-decl")[Объявление переменной] вводит новую переменную в @def:namespace[пространство имён] переменных.

#rule(<decl.variable.global>)
Переменная, объявленная на верхнем уровне, называется #def("global-variable")[Глобальная переменная][глобальной].

#rule(<decl.variable.field>)
Переменная, объявление которой вложено в объявление @def:struct-decl[структурного типа] или @def:automaton-decl[автомата], называется #def("field")[Поле][полем].
Она добавляется в @def:instance-scope[область видимости элементов экземпляра] объемлющего объявления.

#rule(<decl.variable.local>)
Переменная, объявленная в теле @def:fn-entity[функциональной сущности], называется #def("local-variable")[Локальная переменная][локальной].

#rule(<decl.variable.mutability>)
Переменная может быть объявлена как изменяемая или неизменяемая.
#def("mutable-variable")[Изменяемая переменная] объявляется при помощи ключевого слова `var`; её значение может быть изменено @def:assign-stmt[командой присваивания].
#def("immutable-variable")[Неизменяемая переменная] объявляется при помощи ключевого слова `val`; ей не может быть переприсвоено значение.

#rule(<decl.variable.param>)
Параметры @def:fn-entity[функциональных сущностей] являются неизменяемыми переменными.

#impl-spec(impls.rs)[
  Параметры являются изменяемыми.
]

#rule(<decl.variable.predicate-var>)
Локальные переменные @def:pred[предикатов] неизменяемы.
#sema-err-def[Объявление изменяемой локальной переменной предиката][Объявление переменной с помощью ключевого слова `var` — семантическая ошибка.]

#rule(<decl.variable.inferred-local-type>)
Тип объявляемой локальной переменной может отсутствовать.
Тогда он будет выведен автоматически (@type.infer).

#rule(<decl.variable.explicit-type>)
Тип объявляемой нелокальной переменной обязан задаваться явно.
#sema-err-def[Неуказание типа нелокальной переменной][Отсутствие указания типа переменной — семантическая ошибка.]

#rule(<decl.variable.init>)
В объявлении переменной может быть указано #def("variable-init-expr")[Инициализирующее выражение переменной][инициализирующее выражение].
Его семантика зависит от вида переменной:

#rule(<decl.variable.init.global>)
/ Глобальная переменная:
  Инициализирующее выражение опционально.
  При его наличии оно вычисляется во время инициализации спецификации (@rt.init).
  В случае отсутствия значение должно быть предоставлено @def:processor[процессором].

  Процессор может затребовать инициализирующее выражение для некоторых или всех глобальных переменных.
  #sema-err-def[Неуказание инициализирующего выражения глобальных переменных, для которых процессор его требует][Неуказание его в таком случае — семантическая ошибка.]

#rule(<decl.variable.init.field.struct>)
/ Поле @def:struct-decl[структурного типа]:
  #sema-err-def[Указание инициализирующего выражения поля структурного типа][Наличие инициализирующего выражения — семантическая ошибка.]

  #note[
    Поля структуры инициализируются её @def:struct-constructor[конструктором].
  ]

#rule(<decl.variable.init.field.automaton>)
/ Поле @def:automaton-concept[автомата]:
  Инициализирующее выражение обязательно.
  #sema-err-def[Неуказание инициализирующего выражения поля автомата][Его отсутствие — семантическая ошибка.]

  Инициализирующее выражение вычисляется каждый раз при @def:instantiation-expr[инстанцировании автомата] для инициализации поля.

#rule(<decl.variable.init.local>)
/ Локальная переменная:
  Инициализирующее выражение обязательно только для неизменяемых переменных.
  #sema-err-def[Неуказание инициализирующего выражения неизменяемой локальной переменной][Его отсутствие в этом случае — семантическая ошибка.]
  Для изменяемых переменных инициализирующее выражение опционально.

  Вычисление инициализирующего выражения происходит в момент объявления.

#rule(<decl.variable.uninit-local>)
Если локальная переменная не имеет инициализирующего выражения, она является #def("uninitialized-variable")[Неинициализированная переменная][неинициализированной].
Для такой переменной разрешается только присваивание, после чего она становится инициализированной.
#runtime-err-def[Чтение неинициализированной переменной][Чтение неинициализированной переменной — ошибка времени исполнения.]

#rule(<decl.variable.scope>)
Объявление локальной переменной вводит в @def:current-scope[текущей] новую @def:scope[область видимости], в которую размещается переменная.

#note[
  Таким образом, локальная переменная может затмить ранее объявленную:

  ```libsl
  proc shadowing(foo: int32) {
    val foo = false;
    val foo = 0;
  }
  ```
]

#rule(<decl.variable.scope.current>)
@def:current-scope[Текущей областью видимости] является:
- для @def:type-expr[типового выражения] и инициализирующего выражения — текущая область видимости объявления

#example[
  ```libsl
  proc shadowing(foo: int32) {
    val foo = foo + 1;
  }
  ```

  Здесь в инициализирующем выражении `foo` указывает на параметр.
]

#rule-h(<decl.state>)
== Объявление состояния

#figure(
  ```antlr
  stateDecl
      :   kind=stateKind
          names=stateNameList
          SEMICOLON
      ;

  stateKind
      :   INITSTATE # StateKindInitial
      |   STATE # StateKindRegular
      |   FINISHSTATE # StateKindFinal
      ;

  stateNameList
      :   names+=stateName
          (COMMA names+=stateName)*
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `state-decl`
      <
        "initstate",
        "state",
        "finishstate"
      >
      'state-name'*","
      ";"
    ]
    ```,
  )
)

#rule(<decl.state.intro>)
#def("state-decl")[Объявление состояния] вводит новые именованные состояния в @def:namespace[пространство имён] состояний объемлющего @def:automaton-decl[автомата].

#rule(<decl.state.reserved-name>)
Следующие имена состояний зарезервированы и не могут быть использованы в объявлении:
- `any`
- `self`

#syntax-err-def[Объявление состояния с зарезервированным именем][Объявление состояния с одним из таких имён — синтаксическая ошибка.]

#rule(<decl.state.kinds>)
#def("regular-state")[Обычное именованное состояние] объявляется при помощи ключевого слова `state`.
#def("init-state")[Начальное именованное состояние] объявляется при помощи ключевого слова `initstate`.
#def("final-state")[Конечное именованное состояние] объявляется при помощи ключевого слова `finishstate`.

#unresolved[
  Имеет ли смысл `initstate`, если начальное состояние в @def:instantiation-expr[выражении инстанцирования] всегда задаётся явно?
]

#rule-h(<decl.shift>)
== Объявление правила перехода

#figure(
  ```antlr
  shiftDecl
      :   SHIFT
          from=shiftSourceState
          ARROW to=shiftTargetState
          BY by=shiftBy
          SEMICOLON
      ;

  shiftSourceState
      :   stateName # ShiftSourceStateShorthand
      |   L_PAREN (states=stateNameList COMMA?)? R_PAREN # ShiftSourceStateList
      |   ANY # ShiftSourceStateAny
      ;

  shiftTargetState
      :   stateName # ShiftTargetStateNamed
      |   SELF # ShiftTargetStateSelf
      ;

  shiftBy
      :   signature=functionSignature # ShiftByShorthand
      |   L_BRACKET (signatures=functionSignatureList COMMA?)? R_BRACKET # ShiftByList
      ;

  functionSignatureList
      :   signatures+=functionSignature
          (COMMA signatures+=functionSignature)*
      ;
  ```,
)

#figure(
  railroad(
    ```
    {
      [
        `shift-decl`
        "shift"
      ],
      [
        <
          'state-name',
          [
            "("
            [
              'state-name'*","
              ","?
            ]?
            ")"
          ],
          "any"
        >#`source states`
        <
          ["->" 'state-name'],
          "self"
        >#`target state`
      ],
      [
        "by"
        <
          'function-signature',
          [
            "["
            [
              'function-signature'*","
              ","?
            ]?
            "]"
          ]
        >
      ]#`rule trigger`
    }
    ```
  )
)

#rule(<decl.shift.intro>)
#def("shift-decl")[Объявление правила перехода] добавляет в объемлющий @def:automaton-decl[автомат] новое правило перехода между @def:automaton-state[именованными состояниями].

#impl-spec(impls.rs)[
  Семантический анализ игнорирует объявления правил перехода.
]

#rule(<decl.shift.rule>)
Правило перехода интерпретируется следующим образом: если @def:automaton-state[состояние автомата] — одно из указанных исходных, то @def:function-execution[исполнение] @def:function-decl[функции], указанной в объявлении, приводит к переходу в новое состояние.
Для таких исходных состояний и функций правило называется #def("applicable-shift-rule")[Применимое правило перехода][применимым].

#rule(<decl.shift.source>)
В качестве исходного состояния можно указать либо @def:automaton-state[именованные состояния] автомата, либо @def:keyword-weak[слабое ключевое слово] `any`, которое распространяет правило на все состояния автомата, кроме @def:final-state[конечных].

#rule(<decl.shift.source.final>)
Исходное состояние не может быть @def:final-state[конечным].
#sema-err-def[Использование конечного состояния как исходного в объявлении правила перехода][Указание конечного состояния как исходного — семантическая ошибка.]

#rule(<decl.shift.target>)
В качестве нового состояния можно указать либо @def:automaton-state[именованное состояние] автомата, либо @def:keyword-weak[слабое ключевое слово] `self`, которое означает, что состояние автомата в результате применения правила не изменяется.

#rule(<decl.shift.unknown-state>)
#sema-err-def[Использование необъявленного состояния в объявлении правила перехода][Указание в качестве исходного или нового состояния имени, не @def:state-decl[объявленного] состоянием объемлющего автомата, — семантическая ошибка.]

#figure(
  ```antlr
  functionSignature
      :   name=ident # FunctionSignatureShorthand
      |   name=ident L_PAREN (params=typeExprList COMMA?)? R_PAREN # FunctionSignatureQualified
      ;
  ```,
)

#figure(
  railroad(
    ```
    [
      `function-signature`
      <
        'ident'#`match by name`,
        [
          'ident'
          "("
          [
            'type-expr'*","
            ","?
          ]?
          ")"
        ]#`match specific overload`
      >
    ]
    ```,
  )
)

#rule(<decl.shift.trigger>)
@def:function-decl[Функции], которые вызывают применение правила, задаются указанием их сигнатур.
Для этого предоставляются две формы:

#rule(<decl.shift.trigger.shorthand>)
/ Краткая форма:
  Состоит только из имени функции.
  Она соответствует всем функциям с таким именем, являющимся @def:method[методами] (в том числе @def:static-method[статическими]) объемлющего автомата.

  #rule(<decl.shift.trigger.shorthand.unknown-name>)
  #sema-err-def[Использование в объявлении правила перехода краткой формы сигнатуры с несуществующим именем функции][Несуществование таких функций — семантическая ошибка.]

#rule(<decl.shift.trigger.qualified>)
/ Полная форма:
  Состоит из имени функции и перечня типов её параметров.
  Она соответствует единственной перегрузке функции с этим именем, у которой нет @def:type-param[типовых параметров], совпадает число параметров и попарно @def:type-eq[равны] их типы, среди функций-@def:method[методов] (в том числе @def:static-method[статических]) объемлющего автомата.

  #rule(<decl.shift.trigger.qualified.unknown-overload>)
  #sema-err-def[Использование в объявлении правила перехода полной формы сигнатуры несуществующей перегрузки][Несуществование такой перегрузки — семантическая ошибка.]

  #rule(<decl.shift.trigger.qualified.multiple-overloads>)
  #sema-err-def[Использование в объявлении правила перехода полной формы сигнатуры, соответствующей нескольким перегрузкам][Если сигнатуре соответствует несколько перегрузок, то это также семантическая ошибка.]

  #deficiency[
    Сейчас невозможно обратиться с перегрузке с генериками.
  ]

#rule(<decl.shift.overlap>)
Для заданных начального состояния и функции может существовать не более одного @def:applicable-shift-rule[применимого правила].
#sema-err-def[Объявление двух правил перехода, оба применимых для некоторых начального состояния и функции][Попытка объявить более одного такого правила приводит к семантической ошибке.]

#rule(<decl.shift.implicit>)
Для некоторых начального состояния и функции может не иметься @def:applicable-shift-rule[применимого правила].
Автомат в таком состоянии оставляет его без изменения при @def:function-execution[исполнении функции].
