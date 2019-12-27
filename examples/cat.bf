** A program that outputs the input (file)

,            read one character (into cell value)
             as the default initial value is 0 and EOF does not
             change current value
             
[
  .          print it (cell value content)
  [-]        loop until value is 0
  ,          read next character if EOF leave 0 (unchanged)
]
