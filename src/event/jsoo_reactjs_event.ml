class type ['element] synthetic_event =
  object
    method bubbles : bool Js.t Js.readonly_prop

    method cancelable : bool Js.t Js.readonly_prop

    method currentTarget : 'a Js.t Js.readonly_prop

    method defaultPrevented : bool Js.t Js.readonly_prop

    method eventPhase : Js.number Js.t Js.readonly_prop

    method isTrusted : bool Js.t Js.readonly_prop

    method nativeEvent : 'a Dom.event Js.t Js.readonly_prop

    method preventDefault : unit Js.meth

    method isDefaultPrevented : bool Js.t Js.meth

    method stopPropagation : unit Js.meth

    method isPropagationStopped : bool Js.t Js.meth

    method target : 'element Js.t Js.readonly_prop

    method timeStamp : Js.number Js.t Js.readonly_prop

    method _type : Js.js_string Js.t Js.readonly_prop
  end

module Keyboard_event = struct
  class type ['element] _t =
    object
      inherit ['element] synthetic_event

      method altKey : bool Js.t Js.readonly_prop

      method charCode : Js.number Js.t Js.readonly_prop

      method ctrlKey : bool Js.t Js.readonly_prop

      method getModifierState : Js.js_string Js.t -> bool Js.t Js.meth

      method key : Js.js_string Js.t Js.readonly_prop

      method keyCode : Js.number Js.t Js.readonly_prop

      method locale : Js.js_string Js.t Js.readonly_prop

      method location : Js.number Js.t Js.readonly_prop

      method metaKey : bool Js.t Js.readonly_prop

      method repeat : bool Js.t Js.readonly_prop

      method shiftKey : bool Js.t Js.readonly_prop

      method which : Js.number Js.t Js.readonly_prop
    end

  type 'element t = 'element _t Js.t

  type event_type =
    | KeyDown
    | KeyUp
    | KeyPress
    | Unknown

  let to_event_type ev =
    match Js.to_string ev##._type with
    | "keydown" -> KeyDown
    | "keyup" -> KeyUp
    | "keypress" -> KeyPress
    | _ -> Unknown
end

module Input_event = struct
  class type ['element] _t =
    object
      inherit ['element] synthetic_event
    end

  type 'element t = 'element _t Js.t
end

module Scroll_event = struct
  class type ['element] _t =
    object
      inherit ['element] synthetic_event

      method detail : Js.number Js.t Js.readonly_prop

      method view : Dom.element Js.t Js.readonly_prop
    end

  type 'element t = 'element _t Js.t
end

module Focus_event = struct
  class type ['element] _t =
    object
      inherit ['element] synthetic_event

      method relatedTarget : Dom.element Js.t Js.readonly_prop
    end

  type 'element t = 'element _t Js.t
end
