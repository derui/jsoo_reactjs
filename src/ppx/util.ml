open Ppxlib

(** [parse_list exp acc] traverse [exp] as list and get expression in list. *)
let rec parse_list (exp:Parsetree.expression) acc =
  match exp.pexp_desc with
  | Pexp_construct ({txt = Lident "[]"; _}, None) ->
    List.rev acc
  | Pexp_construct ({Loc.txt = Lident "::";_ }, Some arg) -> begin
      match arg.pexp_desc with
      | Pexp_tuple [hd; tl] -> parse_list tl (hd :: acc)
      | _ -> failwith "list's constructor arguments must be tuple"

    end
  | _ -> failwith "can not traverse with expression that is not list"

(** [expand_children loc children] convert string in children to text element.  *)
let expand_children loc children =
  let has_txt_attr attrs =
    List.exists (fun ({txt;_}, _) ->
        match txt with
        | "txt" -> true
        | _ -> false
      ) attrs
  in

  let children = parse_list children [] in
  List.fold_right (fun child ret ->
      match child.pexp_desc with
      | Pexp_constant (Pconst_string (text, _)) ->
        [%expr Jsoo_reactjs.text [%e Ast_builder.Default.(pexp_constant ~loc (Pconst_string (text, None)))]] :: ret
      | _ -> begin
          if has_txt_attr child.pexp_attributes then
            [%expr Jsoo_reactjs.text [%e child ]] :: ret
          else
            child :: ret
        end
    )
    children
    []

  |> Ast_builder.Default.elist ~loc
