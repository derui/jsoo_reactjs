# ReactJS Bindings for js\_of\_ocaml #
This library provides bindings for ReactJS to use with js\_of\_ocaml.

## Requirements ##

* js\_of\_ocaml
* js\_of\_ocaml-ppx

## Installation ##
1. Clone this repository
1. Add reactjscaml as pinned project

   ```shell
   $ cd path_to_reactjscaml
   $ opam pin add reactjscaml .
   $ opam install reactjscaml
   ```

1. Add reactjscaml to your project's dependency.

   If you already use opam, add ``depends`` follows.

   ```
   "reactjscaml" {"build" }
   ```

## Development ##

### Build ###

```
jbuilder build
```

### Test ###

```
jbuilder runtest
```

## License ##
MIT
