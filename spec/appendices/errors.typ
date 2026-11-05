#import "../meta.typ": *

= Список ошибок

== Синтаксические ошибки <syntax-errors>

#context custom-outline-list(recorded-errors.get().syntax)

== Семантические ошибки <semantic-errors>

#context custom-outline-list(recorded-errors.get().sema)

== Ошибки времени исполнения <runtime-errors>

#context custom-outline-list(recorded-errors.get().runtime)