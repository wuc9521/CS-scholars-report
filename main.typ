#set page(
  paper: "a4",
  margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
  numbering: "1",
)

#set text(font: "Times New Roman", size: 11pt)
#set heading(numbering: "1.1.")
#set raw(tab-size: 4)
#show link: it => {
  set text(fill: rgb(0, 0, 128))
  underline(it)
}

#[
  #set align(center)
  #set text(font: "Times New Roman")
  #block(height: 40%)
  #block(text(weight: 700, size: 20pt)[Final Report])
  #v(1cm)
  #text(size: 14pt)[Arda Gurcan, Chentian Wu]
  #v(0.5cm)
  #text(size: 12pt)[Date: #datetime.today().display()]
]

#pagebreak()

#outline(
  title: "Table of Contents",
  indent: true,
)

#pagebreak()

#let _DIR = "sections/"
#let _EXT = ".typ"
#let _FILES = ("intro", "impl", "conclusion")

#for __ in _FILES {
  include _DIR + __ + _EXT
}