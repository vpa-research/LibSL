#import "@preview/codly:1.3.0"
#import "@preview/algorithmic:1.0.7"

#let page-margin = 1.5cm
#let page-margin-left = 6cm
#let page-margin-right = 1cm
#let left-padding = 5cm

#let highlight-bg = luma(0, 3%)

#let highlight-box(body, fill: white, radius: 0.4em, ..args) = highlight(
  fill: fill,
  extent: radius / 2,
  radius: radius / 2,
  top-edge: 1.15em,
  bottom-edge: -0.5em,
  ..args,
  body
)

#let raw-box = box.with(
  fill: highlight-bg,
  inset: (x: 0.4em),
  outset: (y: 0.4em),
  radius: 0.5em,
)

#let __skip-raw-box = state("skip-raw-box", false)
#let skip-raw-box(it) = {
  __skip-raw-box.update(_ => true)
  it
}

#let recorded-todos = state("recorded-todos", ())

#let TODO(..args) = context {
  let body = args.at(0, default: none)
  let body = if body == none {
    [*TODO*]
  } else {
    [*TODO:* #body]
  }

  let loc = here()
  recorded-todos.update(todos => todos + ((loc, body),))
  highlight-box(fill: oklch(90%, 30%, 90deg, 100%), body)
}

#let recorded-defs = state("recorded-defs", (:))

#let def(tag, desc, ..args) = context {
  let body = args.at(0, default: desc)
  let loc = here()
  recorded-defs.update(defs => defs + ((tag): (desc: desc, loc: loc)))
  [#metadata(loc)#label("def:" + tag)]
  [*#body*]
}

#let last-rule = state("last-rule", none)

#let rule-inner(lbl) = {
  set text(6pt, fill: luma(30%), font: "Fira Code", costs: (:))
  set par(justify: false)
  [#metadata("__rule__")#lbl]

  last-rule.update(_ => lbl)

  context {
    if query(lbl).len() > 1 {
      panic("duplicate rule " + str(lbl))
    }
  }

  {
    show ".": sym.zws + "."
    [[#str(lbl)]]
  }
}

#let rule(lbl) = context {
  let x = here().position().x
  let shift = calc.max(0pt, x - page-margin-left)

  block(
    sticky: true,
    below: 0pt,
    width: left-padding - 0.5cm,
    place(
      dx: -left-padding - shift,
      dy: 0.2em,
      right,
      align(right, rule-inner(lbl))
    ),
  )
}

#let pending-rule-h = state("pending-rule-h")

#let rule-h(lbl) = {
  pending-rule-h.update(_ => {
    rule-inner(lbl)
  })
}

#let recorded-errors = state("recorded-errors", (syntax: (), sema: (), runtime: ()))

#let err-def(kind, desc, body) = {
  context {
    let loc = here()
    recorded-errors.update(errs => {
      errs.at(kind).push((desc: desc, loc: loc))
      errs
    })
  }

  body
}

#let syntax-err-def(desc, body) = err-def("syntax", desc, body)
#let sema-err-def(desc, body) = err-def("sema", desc, body)
#let runtime-err-def(desc, body) = err-def("runtime", desc, body)

#let custom-outline(
  entries,
  entry: block,
  page-number: (desc, loc) => counter(page).display(at: loc),
  inner: (desc, fill, page) => [#desc #fill #page],
) = {
  set par(spacing: 0.65em, justify: false)

  for (desc, loc) in entries {
    link(loc, entry(inner(desc, box(width: 1fr, outline.entry.fill), [#sym.wj#page-number(desc, loc)])))
  }
}

#let rule-at(loc) = {
  let rule = last-rule.at(loc)

  if rule != none {
    set text(fill: luma(30%))
    [[#str(rule)]]
  }
}

#let custom-outline-list = custom-outline.with(
  entry: e => [+ #e],
  page-number: (desc, loc) => box({
    let rule = rule-at(loc)

    if rule != none {
      [#rule ]
    }

    counter(page).display(at: loc)
  }),
)

#let info-block(fill: highlight-bg, kind: [Примечание], body) = block(
  fill: fill,
  stroke: 1pt + luma(0, 10%),
  inset: 10pt,
  radius: 5pt,
  width: 100%,
  [
    #block(sticky: true)[*#kind*]

    #pad(left: 2em, body)
  ]
)

#let note = info-block.with(kind: [Примечание])
#let example = info-block.with(kind: [Пример])
#let explanation = info-block.with(kind: [Пояснение])

#let unresolved-blocks = state("unresolved-blocks", ())
#let unresolved(body, outline: true) = {
  if outline {
    context {
      let loc = here()
      unresolved-blocks.update(it => it + (loc,))
    }
  }

  info-block(kind: [Необходимо уточнение спецификации], fill: oklch(90%, 50%, 90deg, 5%), body)
}

#let deficiencies = state("deficiencies", ())
#let deficiency(body, outline: true) = {
  if outline {
    context {
      let loc = here()
      deficiencies.update(it => it + (loc,))
    }
  }

  info-block(kind: [Несовершенство языка], fill: oklch(90%, 50%, 10deg, 5%), body)
}

#let impls = (
  rs: [libsl-rs],
)

#let impl-spec(impl, body) = info-block(
  kind: [Реализация #impl],
  fill: oklch(90%, 50%, 150deg, 5%),
  body,
)

#let link-underline = underline.with(
  stroke: (paint: black, thickness: 0.8pt, dash: ("dot", 1pt)),
  offset: 2pt,
)

#let error-underline = underline.with(
  stroke: 1pt + red,
  offset: 2pt,
)

#let unresolved-refs = state("unresolved-refs", (:))

#let algorithm = algorithmic.algorithm.with(vstroke: 1pt + luma(0, 20%))

#let Fail = (smallcaps[fail],)