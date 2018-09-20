(** Ref_table provides utility for management refs in component.
    Functions in this component are totally having side-effect for type [t].
*)

type t

val create : unit -> t
(** [create ()] returns new instance of {type!t} *)

val define : key:string -> t -> unit
(** [define ~key t] create new ref in [t] with [key]. *)

val use : key:string -> t -> Core.React.ref_ Js.t Js.optdef
(** [use ~key t] returns ref to be able to pass to {!Core.create_element} directly. *)

val find : key:string -> t -> Dom_html.element Js.t option
(** [find ~key t] returns the element in ref defined by [key].  *)
