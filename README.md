[![Stories in Ready](https://badge.waffle.io/gdotdesign/coffer.png?label=ready)](https://waffle.io/gdotdesign/coffer)
# Coffer [![Build Status](https://travis-ci.org/gdotdesign/coffer.png?branch=master)](https://travis-ci.org/gdotdesign/coffer)

Coffer is a components framework, designed from the ground up to be modular, extensible and easy to use.

## A Component

*TODO*

## Usage (development)

### Basic usage
Build / Download the Coffer client and load it into your application

```html
<script type="text/javascript" src="coffer-client.js"></script>
```

This will create `Coffer` global variable that can you use the create a component, it will connect to the registry and emit `components-ready` event.

#### Registering a local component
Just call `Coffer.register` with the name and contents of the component, the callback will be run when the component is registered.
```JavaScript
Coffer.register('tagname', {css:'', events: ..., properties: ...}), callback)
````

#### Create a component
The example below will create a local component if it exsists otherwise it will retrieve the component from the registry and create it, if it can't find it, it will create the elment nonetheless but it will be empty and won't contain any events, properties or CSS.
```JavaScript
Coffer.create('tagname', function(element){
  console.log(element);
})
```

## Production / Build

*TODO*
    
## Framework Development
Development goes in a Trello board: https://trello.com/b/nVlowUCH/components
