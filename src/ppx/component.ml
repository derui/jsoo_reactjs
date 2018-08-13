(* rewriter for Component extension *)
open Ppxlib

let name = "jsoo_ocaml.ppx.component"

(** build argument list for {!Jsoo_reactjs.create_dom_element} *)
let build_args loc args =
  let children = ref None
  and props = ref [] in

  List.iter (fun (labelled, exp) ->
      match labelled with
      | Ppxlib_ast.Asttypes.Labelled _ | Optional _ as v -> begin
          props := Some (v, exp) :: !props
        end
      (* Nolabel should be children *)
      | Nolabel -> children := Some (Labelled "children", Util.expand_children loc exp)
    ) args;

  List.fold_right (fun v list -> match v with
      | None -> list
      | Some v -> v :: list)
    (!children :: !props)
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
