#import "meta.typ": *
#import "style.typ": style

#set document(
  title: [Спецификация LibSL 2],
  description: [Нормативная спецификация языка LibSL 2],
  date: none,
)

#{
  show: style.with(kind: "title")

  title()

  include "intro.typ"

  pagebreak(weak: true)
  outline()
}

#{
  show: style.with(kind: "main")

  include "chapters/lexical-structure.typ"
  include "chapters/modules.typ"
  include "chapters/declarations.typ"
  include "chapters/annotations.typ"
  include "chapters/statements.typ"
  include "chapters/expressions.typ"
  include "chapters/predicates.typ"
  include "chapters/names.typ"
  include "chapters/types.typ"
  include "chapters/well-formedness.typ"
  include "chapters/runtime.typ"
  include "chapters/std.typ"
}

#{
  show: style.with(kind: "appendix")

  context counter(heading).update(0)

  include "appendices/syntax.typ"
  include "appendices/defs.typ"
  include "appendices/errors.typ"
  include "appendices/future-directions.typ"
}

#include "debug.typ"
