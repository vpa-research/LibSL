#import "meta.typ": *

#let __render-def-ref(it, target) = {
  let tag = target.slice(4)

  return if it.element == none {
    unresolved-refs.update(refs => {
      if target in refs {
        refs
      } else {
        refs.insert(target, it.location())
        refs
      }
    })

    let rule-raw = skip-raw-box(raw("[@" + target + "]"))

    if it.supplement == auto {
      error-underline(rule-raw)
    } else {
      error-underline(it.supplement)
      sub(typographic: false, baseline: 0.35em, rule-raw)
    }
  } else {
    let body = if it.supplement == auto {
      context {
        let def = recorded-defs.final().at(tag, default: none)
  
        if def != none {
          def.desc
        }
      }
    } else {
      it.supplement
    }

    set text(style: "italic")
    link(
      it.element.value,
      link-underline(body),
    )
  }
}

#let __render-rule-ref(it, target) = {
  show ".": sym.zws + "."
  show "-": "-" + sym.zws
  link(it.element.location(), link-underline(target))
}

#let __render-raw(it) = {
  if __skip-raw-box.get() {
    it
    __skip-raw-box.update(_ => false)
  } else {
    raw-box(it)
  }
}

#let __render-heading-ref(it) = {
  let el = it.element

  let numbering = el.numbering

  if numbering == none {
    numbering = "1.1"
  }

  let count = counter(heading).at(el.location())
  let nr = std.numbering(numbering, ..count)

  if nr == none {
    nr = std.numbering("1.1", ..count)
  }

  let supplement = if it.supplement != none and it.supplement != auto {
    it.supplement + [ ]
  } else if el.supplement != none and el.supplement != auto and el.supplement != [] {
    el.supplement + [ ]
  } else {
    [§]
  }

  link(el.location(), supplement + nr)
}

#let style(it, kind: "main") = {
  set text(lang: "ru")
  set par(justify: true)
  set outline(indent: 1.2em)
  set table(stroke: 0.5pt + black)
  set terms(separator: linebreak())

  show outline.entry: it => link(
    it.element.location(),
    it.indented(
      {
        if it.element.supplement != none {
          [#it.element.supplement #counter(it.element.func()).display(at: it.element.location())]
        } else {
          it.prefix()
        }
        [.]
      },
      it.inner(),
    )
  )

  set page(
    margin: (
      left: if kind == "main" {
        page-margin-left
      } else {
        page-margin
      },
      rest: page-margin,
      right: page-margin-right,
    ),
    numbering: "1",
  )

  show raw.where(block: false): __render-raw

  show figure: if kind == "main" { pad.with(left: -left-padding) } else { it => it }
  show divider: if kind == "main" { pad.with(left: -left-padding) } else { it => it }

  show: codly.codly-init
  codly.codly(
    number-align: right + top,
    number-placement: "outside",
    zebra-fill: luma(0%, 4%),
  )

  show ref.where(form: "normal"): it => {
    let el = it.element
    let target = str(it.target)

    if target.starts-with("def:") {
      return __render-def-ref(it, target)
    }

    if el != none and el.func() == metadata and el.value == "__rule__" {
      return __render-rule-ref(it, target)
    }

    if el != none and el.func() == heading {
      return __render-heading-ref(it)
    }

    it
  }

  show heading: it => {
    if kind in ("main", "appendix") and it.level == 1 {
      pagebreak(weak: true)
    }

    if kind == "main" {
      block({
        let pad-left = 0cm

        let body = {
          if it.outlined {
            let nr = numbering(it.numbering, ..counter(heading).get()) + [.]
            let width = measure(nr).width
            pad-left += width + 0.5cm
            
            nr
            h(0.5cm)
          }

          it.body
        }

        let rule = pending-rule-h.get()

        if rule != none {
          let remaining-width = left-padding - pad-left - 0.5cm
          let rule-box = box(width: remaining-width, align(right, rule))
          body = {
            {
              set text(weight: "regular")
              rule-box
              h(0.5cm)
            }
            pending-rule-h.update(_ => none)
            body
          }
          pad-left = left-padding
        }

        pad(left: -pad-left, body)
      })
    } else if kind == "appendix" {
      if it.level == 1 and it.numbering != none {
        [#it.supplement #numbering(it.numbering, ..counter(heading).get()).]
      } else if it.numbering != none {
        [#counter(heading).display().]
      }

      h(0.25cm)
      it.body
    } else {
      it

      if kind == "title" {
        counter(heading).update(0)
      }
    }
  }

  set heading(
    numbering: if kind in ("main", "appendix") {
      (..numbers) => {
        let numbering = if kind == "main" {
          "1.1"
        } else {
          "A.1"
        }
  
        std.numbering(numbering, ..numbers)
      }
    } else {
      none
    },

    supplement: none,

    outlined: kind != "title",
  )

  show heading.where(level: 1): set heading(
    supplement: if kind == "appendix" {
      [Приложение]
    } else {
      none
    },
  )

  show heading: set block(above: 2em)

  show heading.where(level: 1): set text(1.7em / 1.4)
  show heading.where(level: 2): set text(1.35em / 1.2)
  show heading.where(level: 3): set text(1.2em)

  show heading: it => {
    set text(weight: if it.level == 1 {
      900
    } else if it.level >= 2 and it.level <= 4 {
      700
    } else {
      "regular"
    })

    set text(fill: if it.level == 1 or it.level == 2 {
      black
    } else if it.level == 3 {
      luma(25%)
    } else {
      luma(35%)
    })

    it
  }

  show "—": sym.wj + "—"

  show title: set text(1.25em)

  it
}
