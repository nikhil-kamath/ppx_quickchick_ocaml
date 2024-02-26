open Ppxlib
open Core
open Ast_builder.Default

let get_constructor_name (cd : constructor_declaration) : string =
  cd.pcd_name.txt

let generate_add_call (cds : constructor_declaration list) ~loc type_name path =
  let constructor_names = List.map cds ~f:get_constructor_name in
  let name_node = Ast_builder.Default.estring ~loc type_name in
  let constructor_node =
    Ast_builder.Default.elist ~loc
      (List.map ~f:(Ast_builder.Default.estring ~loc) constructor_names)
  in
  let path_node = Ast_builder.Default.estring ~loc path in
  pstr_value ~loc Nonrecursive
    [
      {
        pvb_pat = ppat_var ~loc { loc; txt = "()" };
        pvb_expr =
          [%expr
            Quickchick_ocaml.add_type [%e path_node] [%e name_node]
              [%e constructor_node]];
        pvb_attributes = [];
        pvb_loc = loc;
      };
    ]

let generate_impl ~ctxt (_rec_flag, type_declarations) =
  let path =
    Code_path.main_module_name (Expansion_context.Deriver.code_path ctxt)
  in
  let loc = Expansion_context.Deriver.derived_item_loc ctxt in
  List.map type_declarations ~f:(fun (td : type_declaration) ->
      match td with
      | {
       ptype_kind = Ptype_abstract | Ptype_record _ | Ptype_open;
       ptype_loc;
       _;
      } ->
          let ext =
            Location.error_extensionf ~loc:ptype_loc
              "Cannot derive accessors for non variant types"
          in
          [ Ast_builder.Default.pstr_extension ~loc ext [] ]
      | { ptype_kind = Ptype_variant fields; ptype_name; _ } ->
          [ generate_add_call fields ~loc ptype_name.txt path ])
  |> List.concat

let impl_generator = Deriving.Generator.V2.make_noarg generate_impl
let my_deriver = Deriving.add "quickchick" ~str_type_decl:impl_generator
