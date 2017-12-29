module R = Reactjs_of_ocaml.Std
open Mocha_of_ocaml

let prepare () =
  let div = Dom_html.createDiv Dom_html.document in
  div##setAttribute (Js.string "id") (Js.string "js");

  match Dom_html.getElementById_opt "test" with
  | Some v -> ignore @@ Dom.removeChild Dom_html.document v
  | None -> ();

    let body =
      let nl = Dom_html.document##getElementsByTagName (Js.string "body") in
      match nl##item 0 |> Js.Opt.to_option with
      | None -> failwith "Not found body tag"
      | Some v -> v
    in
    Dom.appendChild body div

let _ =
  "React element" >::: [
    "can create most simple text element" >:- (fun () ->
        prepare ();
        let span = R.Dom.of_tag `span ~children:[| R.text "foo" |] in
        let index = Dom_html.getElementById "js" in
        R.dom##render span index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let option () = Js.string "" in 
            let text = Js.Opt.get (index##.textContent) option |> Js.to_string in
            Lwt.return @@ assert_ok ("foo" = text)
          )
      );

    "can create original stateless component" >:- (fun () ->
        prepare ();
        let module M = R.Component.Make_stateless(struct
            class type _t = object
              method name: Js.js_string Js.t Js.readonly_prop
            end
            type t = _t Js.t
          end) in
        let component = M.make (fun props ->
            R.Dom.of_tag `span ~children:[|
              R.text @@ Js.to_string props##.name
            |]
          ) in
        let index = Dom_html.getElementById "js" in
        let element = R.create_element component ~props:(object%js
            val name = Js.string "bar"
          end) in
        R.dom##render element index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let option () = Js.string "" in 
            let text = Js.Opt.get (index##.textContent) option |> Js.to_string in
            Lwt.return @@ assert_ok ("bar" = text)
          )
      )
  ];
