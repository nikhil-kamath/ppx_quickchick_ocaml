# Ppx_quickchick_ocaml

Automatically derive `Quickchick_ocaml` setup code via preprocessors. Just add the following stanza to your `dune` file:
```yaml
(preprocess
  (pps ppx_quickchick_ocaml))
```

## Currently supported extensions

### Type definitions (variants)

```ocaml
type bar =
  | A
  | B of int
[@@deriving quickchick]
```
gets turned into 
```ocaml
type bar =
  | A
  | B of int
...
let () = Quickchick_ocaml.add_type "Prop" "bar" ["A"; "B"]
...
```
