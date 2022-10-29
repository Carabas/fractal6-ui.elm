# Fractal6-ui.elm

Single-page application frontend for [Fractale](https://fractale.co).


## Install

    npm install


## Launch

First, generate the elm i18n langage source code (it will generate the `src/Text.elm` file): 

    ./i18n.py gen -w -l

**Run the test server**

Build the code and run a webpack dev server (hot reload)

    make run

To run webpack with the production code (i.e with optimization)

    make run_prod


## Build

**Build the production code**

The code will be generated in the `dist` folder.

    make prod


**Re-generate the GraphQL parser code for Elm**

    make gen


## Routing

We use [elm-spa](https://www.elm-spa.dev/) as the spa framework. It defines the routing and the Main input logic. Basycally, files located in `Pages` will be an accessible route in the browser. 
For exemple: `Pages/o/Dynamiyc.elm` makes the route at `https://[domain_name]/o/my_org`

Note: For the moment we lock the `elm-spa` version to the v4 version as it is working well, and upgrading to v6 will be time consuming while the benefits of it is not guaranteed.

## Creating new components

A components is a reusable piece of code use in a application to implement a given functionality.
By components, we mean here a state-full Elm module, that is a module which have its own state, Model & Msg managed by itself. It allows to limit the complexity of the elm files and prevents file from being too big.
For simple components that don't have complex states (i.e. have a few or no Msg), they can be implemented by getting the Msg from the main page, as it is done
in `Components/ColorPicker.elm` for example.
For more complex components, a lot of boilerplates are involved when creating a component with Elm (for the best!) which maintain their own state.
To help building new components quickly without having to repeat the same code again and again, and ensure code api consistency,
we provide a script to generate template code when creating new component:  `melm.py`.

Let say that you need a new component that implements a dropdown menu, and put the file in the `src/Components/` folder.
You will create the template for you dropdown like this

    melm.py add -w Components.MyDropdown

The file `MyDropdown.elm` will be created for you.

If your component is a modal, then you will need to change the default template as follows

    melm.py add -w -t modal Components.MyModal


Finally, when you want to use your component inside a file, let's say in a page located at `src/Page/Welcome.com`, you will need to write some boilerplate code to use your component. The following command will help you by adding in your file the necessery boilerplate code to use the component

    melm.py push -w Components.MyDropdown Page.Exemple

Note: some manually edit can be necessayry anyway, but following the elm compiler should guide you to light.

You can obtain the full script documentation by typing

    melm.py --help


## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
