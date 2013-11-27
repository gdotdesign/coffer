Graphite
==========

[![Build Status](https://travis-ci.org/gdotdesign/components.png?branch=master)](https://travis-ci.org/gdotdesign/components)

## Development
Development goes in a Trello board: https://trello.com/b/nVlowUCH/components

# Usage

## Development
In development you can load your own components as well as components from the registry.

#### Register a component
    Components.register('tagname', component, callback)

#### Create a component
    Components.create('tagname', function(element){
        console.log(element);
    })

# Production / Build

    bin/build tagname

This will build the tagname (component / application) into 2 sperate files (JS/CSS)
