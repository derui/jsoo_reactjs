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
        let span = R.Dom.of_tag `span ~children:[|
            R.Core.text "foo"
          |] in
        let index = Dom_html.getElementById "js" in
        R.Core.dom##render span index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let option () = Js.string "" in 
            let text = Js.Opt.get (index##.textContent) option |> Js.to_string in
            Lwt.return @@ assert_ok ("foo" = text)
          )
      )
  ];
