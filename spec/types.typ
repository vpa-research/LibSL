#import "meta.typ": *

#let safe-link(loc, body) = context {
  if query(loc).len() > 0 {
    link-underline(link(loc, body))
  } else {
    error-underline(body)
  }
}

#let builtin-types = (
  bool: <type.builtin.bool>,
  char: <type.builtin.char>,
  string: <type.builtin.string>,
  null: <type.types.literal>,
  int8: <type.builtin.int>,
  int16: <type.builtin.int>,
  int32: <type.builtin.int>,
  int64: <type.builtin.int>,
  unsigned8: <type.builtin.int>,
  unsigned16: <type.builtin.int>,
  unsigned32: <type.builtin.int>,
  unsigned64: <type.builtin.int>,
  float32: <type.builtin.float>,
  float64: <type.builtin.float>,
  array: <type.builtin.array>,
  "set": <type.builtin.set>,
  void: <type.builtin.void>,
  any: <type.builtin.any>,
  nothing: <type.builtin.nothing>,
).pairs().map(((name, lbl)) => {
  (name, (
    kind: "atom",
    value: [#safe-link(lbl, skip-raw-box(raw(name)))]
  ))
}).to-dict()

#let arg-to-type(arg) = {
  if type(arg) == content and arg.func() == math.equation {
    (
      kind: "atom",
      value: arg,
    )
  } else if type(arg) == content and arg.func() == raw {
    (
      kind: "atom",
      value: skip-raw-box(arg),
    )
  } else if type(arg) == str {
    (
      kind: "atom",
      value: skip-raw-box(raw(arg)),
    )
  } else if type(arg) == dictionary and "kind" in arg {
    arg
  } else {
    panic("unknown type argument: " + repr(arg))
  }
}

#let ctor(c) = (..args) => {
  let args = args.pos().map(arg-to-type)

  (
    kind: "ctor",
    ctor: arg-to-type(c),
    args: args,
  )
}

#let ptr(b) = {
  (
    kind: "ptr",
    inner: arg-to-type(b),
  )
}

#let union(..args) = {
  (
    kind: "union",
    elems: args.pos().map(arg-to-type),
  )
}

#let type-expr-prec = (
  atom: (self: 10, inner: ((), 10)),
  ctor: (self: 10, inner: ((), 10)),
  ptr: (self: 8, inner: ((), 8)),
  union: (self: 4, inner: (4, 3)),
)

#let display-parens(outer-prec, self-prec, inner) = {
  if outer-prec > self-prec {
    $(#inner)$
  } else {
    inner
  }
}

#let render-type-expr(t, outer-prec) = {
  let (self: self-prec, inner: inner-prec) = type-expr-prec.at(t.kind)

  display-parens(
    outer-prec,
    self-prec,
    if t.kind == "atom" {
      $#t.value$
    } else if t.kind == "ctor" {
      $#render-type-expr(t.ctor, 0)$
      $chevron.l$
      $#t.args.map(arg => render-type-expr(arg, 0)).join($, $)$
      $chevron.r$
    } else if t.kind == "ptr" {
      $#safe-link(<def:pointer-type>, skip-raw-box(`*`))$
      $#render-type-expr(t.inner, inner-prec.at(1))$
    } else if t.kind == "union" {
      let (head, ..tail) = t.elems
      let elems = ($#render-type-expr(head, inner-prec.at(0))$,)
      elems = elems + tail.map(it => $#render-type-expr(it, inner-prec.at(1))$)
      $#elems.join($class("binary", #link-underline(link(<type.types.union>, [∪])))$)$
    } else {
      panic("unknown type: " + repr(t))
    }
  )
}

#let type-expr(t) = raw-box(render-type-expr(arg-to-type(t), 0))

#let fn-sig(recv: none, name, target: none) = (..args) => ret => {
  let recv = if recv != none {
    $#render-type-expr(arg-to-type(recv), 0).$
  } else {
    none
  }

  let name = if target == none {
    skip-raw-box(raw(name))
  } else {
    link-underline(link(target, skip-raw-box(raw(name))))
  }

  let args = args.named().pairs().map(((name, ty)) => $#name: #render-type-expr(arg-to-type(ty), 0)$)

  raw-box($#recv#name;(#args.join($," " $)) -> #render-type-expr(arg-to-type(ret), 0)$)
}
