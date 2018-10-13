module R = Jsoo_reactjs
module T = Jsoo_reactjs_transition_group
open Mocha_of_ocaml
open Mocha_of_ocaml_async

let prepare () =
  let div = Dom_html.createDiv Dom_html.document in
  div##setAttribute (Js.string "id") (Js.string "js") ;
  match Dom_html.getElementById_opt "test" with
  | Some v -> ignore @@ Dom.removeChild Dom_html.document v
  | None ->
    () ;
    let body =
      let nl = Dom_html.document##getElementsByTagName (Js.string "body") in
      match nl##item 0 |> Js.Opt.to_option with
      | None -> failwith "Not found body tag"
      | Some v -> v
    in
    Dom.appendChild body div

let () =
  "React CSSTransition Group"
  >::: [ ( "can create CSSTransition group"
           >:- fun () ->
             prepare () ;
             let group =
               T.css_transition ~_in:true ~timeout:200 ~class_name:"transition-group" (fun _ ->
                   [%e input ~default_value:"input"] )
             in
             let index = Dom_html.getElementById "js" in
             R.dom##render group index ;
             let open Lwt.Infix in
             Lwt_js.sleep 300.0
             >>= fun () ->
             let group = Dom_html.document##querySelector Js.(string "input") in
             assert_ok (group |> Js.Opt.to_option <> None) |> Lwt.return ) ]
