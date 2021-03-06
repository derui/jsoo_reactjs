# ReactJS Bindings for js\_of\_ocaml #
This library provides bindings for ReactJS to use with js\_of\_ocaml.

## Requirements ##

* js\_of\_ocaml
* js\_of\_ocaml-ppx

## Installation ##
1. Clone this repository
1. Add jsoo\_reactjs as pinned project

   ```shell
   $ cd path_to_jsoo_reactjs
   $ opam install .
   ```

   >> NOTE: command ``opam install .`` above is only available opam version 2.0.

## Usage ##

1. Add jsoo\_reactjs to your project's dependency.

   If you already use opam, add ``depends`` follows.

   ```
   "jsoo_reactjs"
   ```

1. Install npm packages that are used in this library.

    ```shell
    npm install --save-dev react react-dom react-test-renderer
    ```

## Development ##

### Installation ###

```shell
$ npm install
```

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
