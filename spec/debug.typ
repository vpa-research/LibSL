#import "meta.typ": *

#set page(fill: oklch(95%, 20%, 95deg), margin: (rest: page-margin), numbering: none)
#set text(font: "Roboto", 10pt)
#set par(justify: false)

#set heading(outlined: false, numbering: none)
#show heading.where(level: 1): set heading(numbering: none)

= DEBUG

#context {
  let recorded-todos = recorded-todos.final()

  if recorded-todos.len() > 0 [
    == TODO

    #custom-outline(
      recorded-todos.map(((loc, body)) => (loc: loc, desc: body)),
      entry: it => [+ #it]
    )
  ]
}

#context {
  let unresolved-refs = unresolved-refs.final()

  if unresolved-refs.len() > 0 [
    == Неразрешённые ссылки

    #custom-outline(
      unresolved-refs.pairs().map(((target, loc)) => (loc: loc, desc: raw(lang: "typ", "@" + target))),
      entry: e => [+ #e],
    )
  ]
}

#context {
  let unresolved-blocks = unresolved-blocks.final()

  if unresolved-blocks.len() > 0 [
    == Требуется уточнение спецификации

    #custom-outline(
      unresolved-blocks.map(loc => (loc: loc, desc: rule-at(loc))),
      entry: e => [+ #e],
    )
  ]
}

#context {
  let deficiency-blocks = deficiencies.final()

  if deficiency-blocks.len() > 0 [
    == Несовершенства языка

    #custom-outline(
      deficiency-blocks.map(loc => (loc: loc, desc: rule-at(loc))),
      entry: e => [+ #e],
    )
  ]
}