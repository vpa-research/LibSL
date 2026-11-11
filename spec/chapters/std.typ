#import "../meta.typ": *
#import "../types.typ": type-expr, builtin-types, ctor, fn-sig

#rule-h(<std>)
= Встроенные сущности

#rule(<std.intro>)
Язык LibSL определяет ряд встроенных сущностей, например методов встроенных типов.
Они описываются в данном разделе.

#rule(<std.processor-defined>)
@def:processor[Процессор] может определять сущности помимо представленных в данном разделе.

#rule(<std.preconditions>)
Встроенные функциональные сущности могут задавать #def("builtin-preconditions")[Требования к аргументам встроенной сущности][требования к аргументам].
#runtime-err-def[Невыполнение требований к аргументам вызова встроенной функциональной сущности][Их невыполнение — ошибка времени исполнения.]

#rule-h(<std.array>)
== Операции с массивами

Для удобства работы с @def:array-value[массивами] языком предоставляется несколько встроенных сущностей.

#rule-h(<std.array.length>)
=== Метод `array.length`

#rule(<std.array.length.intro>)
@def:pure-proc[Чистая процедура] `length` позволяет получить @def:array-len[длину] @def:array-value[массива]-@def:object[объекта].

#rule(<std.array.length.scope>)
Определяется в @def:instance-scope[области видимости элементов экземпляра] сущности #type-expr(builtin-types.array).

#rule(<std.array.length.sig>)
@def:fn-sig:

$
  #fn-sig(recv: ctor(builtin-types.array)($T$), "length")()(builtin-types.unsigned64).
$

#rule(<std.array.length.call>)
При @def:call[вызове] метода он возвращает @def:array-len[длину массива] — @def:object[объекта] вызова.

#rule-h(<std.array.slice>)
=== Метод `array.slice`

#rule(<std.array.slice.intro>)
@def:pure-proc[Чистая процедура] `slice` позволяет создать копию @def:array-value[массива], содержащую часть элементов исходного.

#rule(<std.array.slice.scope>)
Определяется в @def:instance-scope[области видимости элементов экземпляра] сущности #type-expr(builtin-types.array).

#rule(<std.array.slice.sig>)
@def:fn-sig:

$
  #fn-sig(recv: ctor(builtin-types.array)($T$), "slice")(
    from: builtin-types.unsigned64,
    to: builtin-types.unsigned64
  )(ctor(builtin-types.array)($T$))
$

#rule(<std.array.slice.preconditions>)
К аргументам вызова предъявляется следующее @def:builtin-preconditions[требование]: если $l$ — @def:array-len[длина] исходного массива, то должно выполняться соотношение

$ 0 <= "from" <= "to" < l. $

#rule(<std.array.slice.call>)
При @def:call[вызове] метода он создаёт новый @def:array-value[массив] @def:array-len[длиной] $"to" - "from"$.
Созданный массив последовательно заполняется элементами исходного массива по индексам $"from", "from" + 1, ..., "to" - 1$.
Созданный массив является возвращаемым значением.
