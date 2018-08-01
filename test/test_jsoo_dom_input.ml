module R = Jsoo_reactjs
open Mocha_of_ocaml
open Mocha_of_ocaml_async

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

let suite () =
  "React DOM element" >::: [
    "can create input element with default value" >:- (fun () ->
        prepare ();
        let input = R.create_dom_element "input" ~props:R.(element_spec ~default_value:"input" ()) in
        let index = Dom_html.getElementById "js" in
        R.dom##render input index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let input = index##getElementsByTagName (Js.string "input") in
            let input = Js.Opt.get (input##item 0) (fun () -> failwith "input not found") in
            let value = input##getAttribute (Js.string "value") in
            Lwt.return @@ assert_ok (value = Js.Opt.return @@ Js.string "input")
          )
      );

    "can handle input event on input" >:- (fun () ->
        prepare ();
        let value = ref "" in
        let on_change e =
          let v = Js.Opt.get (e##.target##getAttribute (Js.string "value")) (fun () -> Js.string "") in
          value := Js.to_string v
        in
        let input = R.create_dom_element "input" ~props:R.(element_spec
                                                    ~on_change
                                                    ~default_value:"input" ()) in
        let index = Dom_html.getElementById "js" in
        R.dom##render input index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let input = index##getElementsByTagName (Js.string "input") in
            let input = Js.Opt.get (input##item 0) (fun () -> failwith "input not found") |> Dom_html.element in
            input##setAttribute (Js.string "value") (Js.string "new");
            R.Test_util.instance##._Simulate##change input Js.Optdef.empty;
            Lwt.return @@ assert_ok (!value = "new")
          )
      );
  ]
