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
  "React SyntheticEvent" >::: [
    "can handle focus event" >:- (fun () ->
        prepare ();
        let value = ref false in
        let on_focus _ = value := true in
        let input = [%e input ~on_focus ~default_value:"input"] in
        let index = Dom_html.getElementById "js" in
        R.dom##render input index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let input = index##getElementsByTagName (Js.string "input") in
            let input = Js.Opt.get (input##item 0) (fun () -> failwith "input not found") |> Dom_html.element in
            R.Test_util.instance##._Simulate##focus input Js.Optdef.empty;
            Lwt.return @@ assert_ok !value
          )
      );
    "can handle blur event" >:- (fun () ->
        prepare ();
        let value = ref false in
        let on_blur _ = value := true in
        let input = [%e input ~on_blur ~default_value:"input"] in
        let index = Dom_html.getElementById "js" in
        R.dom##render input index;

        let open Lwt.Infix in
        Lwt_js.sleep 0.0 >>= (fun () ->
            let input = index##getElementsByTagName (Js.string "input") in
            let input = Js.Opt.get (input##item 0) (fun () -> failwith "input not found") |> Dom_html.element in
            R.Test_util.instance##._Simulate##blur input Js.Optdef.empty;
            Lwt.return @@ assert_ok !value
          )
      );
  ]
