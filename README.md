# node-red-mobile-ios
Run [Node-RED](http://nodered.org) on your iOS device

This is an experiment to see what it takes to run Node-RED on iOS and what fun, if any, can come out of it!

`node` is running via Janea Systems's lovely [`nodejs-mobile`](https://github.com/janeasystems/nodejs-mobile), currently based on the example app.

## Current setup
* `.node-red` configuration folder is located under app’s `Documents` folder
* on device **Palette** editing is disabled - **Palette** management requires spawning child processes which iOS does not like us doing from Javascript 🤬
