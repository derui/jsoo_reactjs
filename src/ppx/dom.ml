(* rewriter for DOM extension *)
open Ppxlib

let name = "jsoo_ocaml.ppx.dom"

(* build props with Jsoo_reactjs.element_spec via labeled arguments *)
let build_props loc args =
  let f = [%expr Jsoo_reactjs.element_spec] in
  let args = (Nolabel, Ast_builder.Default.eunit ~loc) :: List.rev args |> List.rev in
  Some (Labelled "props", Ast_builder.Default.pexp_apply ~loc f args)

(** build argument list for {!Jsoo_reactjs.create_dom_element} *)
let build_args loc args =
  let key = ref None
  and _ref = ref None
  and children = ref None
  and props = ref []
  in

  List.iter (fun (labelled, exp) ->
      match labelled with
      | Ppxlib_ast.Asttypes.Labelled label | Optional label as v -> begin
          match label with
          | "key" -> key := Some (v, exp)
          | "_ref" -> _ref := Some (v, exp)
          | _ -> props := (v, exp) :: !props
        end
      (* Nolabel should be children *)
      | Nolabel -> children := Some (Labelled "children", Util.expand_children loc exp)
    ) args;

  List.fold_right (fun v list -> match v with
      | None -> list
      | Some v -> v :: list)
    [!key;!_ref;build_props loc !props;!children]
    []


let expand ~loc ~path:_ (ident : longident) args =
  let dom = match ident with
    | Lident id -> Some id
    | _ -> None
  in
  match dom with
  | None -> [%expr ident args]
  | Some dom -> begin
      let f = [%expr Jsoo_reactjs.create_dom_element] in
      let args = build_args loc args in
      let root_mod = Ast.Lident "Jsoo_reactjs"
      and tag_mod = "Tags" in
      let ident = Ast_builder.Default.Located.mk ~loc Ast.(Ldot (Ldot (root_mod, tag_mod), dom)) in
      let ident = Ast_builder.Default.pexp_ident ~loc ident in
      let args = (Nolabel, ident) :: List.rev args |> List.rev in
      Ast_builder.Default.pexp_apply ~loc f args
    end

let ext =
  Extension.declare
    "e"
    Extension.Context.expression
    Ast_pattern.(single_expr_payload (pexp_apply (pexp_ident __) __))
    expand

let register () = Driver.register_transformation name ~extensions:[
    ext;
  ]
