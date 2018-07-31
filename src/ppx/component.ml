(* rewriter for Component extension *)
open Ppxlib

let name = "jsoo_ocaml.ppx.component"

let argument_to_field loc arg =
  let label, exp = arg in
  let module L = Ast_builder.Default.Located in
  let desc = Pcf_val (L.mk ~loc label, Immutable, Cfk_concrete (Fresh, exp)) in
  Ast_helper.Cf.mk ~loc desc

(* build props as object with js_of_ocaml extension. *)
let build_prop_as_object loc args =
  let obj_strc = Ast_builder.Default.(
      class_structure ~self:(ppat_any ~loc)
        ~fields:(List.map (argument_to_field loc) args))
  in
  let module L = Ast_builder.Default.Located in
  let obj = Ast_builder.Default.(pexp_object ~loc obj_strc) in
  let obj_with_ext = Ast_builder.Default.(pexp_extension ~loc
                                            (L.mk ~loc "js", PStr ([pstr_eval ~loc obj []]))
                                         )
  in
  Some (Labelled "props", obj_with_ext)

(** build argument list for {!Jsoo_reactjs.create_dom_element} *)
let build_args loc args =
  let key = ref None
  and children = ref None
  and props = ref []
  in

  List.iter (fun (labelled, exp) ->
      match labelled with
      | Ppxlib_ast.Asttypes.Labelled label | Optional label as v -> begin
          match label with
          | "key" -> key := Some (v, exp)
          | _ -> props := (label, exp) :: !props
        end
      (* Nolabel should be children *)
      | Nolabel -> children := Some (Labelled "children", Util.expand_children loc exp)
    ) args;

  List.fold_right (fun v list -> match v with
      | None -> list
      | Some v -> v :: list)
    [!key;build_prop_as_object loc !props;!children]
    []


let expand ~loc ~path:_ (ident : longident) args =
  let ident = Longident.name ident in
  let f = [%expr Jsoo_reactjs.create_element] in
  let args = build_args loc args in
  let component = (Nolabel, Ast_builder.Default.(pexp_ident ~loc @@ Located.lident ~loc ident)) in
  let args = component :: List.rev args |> List.rev in
  Ast_builder.Default.pexp_apply ~loc f args

let ext =
  Extension.declare
    "c"
    Extension.Context.expression
    Ast_pattern.(single_expr_payload (pexp_apply (pexp_ident __) __))
    expand

let register () = Driver.register_transformation name ~extensions:[
    ext;
  ]
