; extends

; Distinguish declarations from references so definitions can be bolded
; without changing every use of a Python function or type.
(function_definition
  name: (identifier) @function.definition)

(class_definition
  name: (identifier) @type.definition)
