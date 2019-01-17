var http = require('http');
var express = require("express");
var RED = require("node-red");

var nodejsProcess = require('./process');

var programArguments = require('minimist')(process.argv.slice(2));
var mobileDocumentDir = programArguments.mobileDocumentDir;
delete programArguments.mobileDocumentDir;

var userDir = programArguments.userDir;
var settingsFile = programArguments.settings;

var settings = require(settingsFile);
settings.userDir = userDir;

// Create an Express app
var app = express();

// Add a simple route for static content served from 'public'
app.use("/", express.static("public"));

// Create a server
var server = http.createServer(app);

console.log("Running Node-RED with the settings:", programArguments);

var nodeRedBootTrackingName = "Node-RED.booting";

// TODO: use temporary or cache folder
nodejsProcess.emptyTrackingFolder(mobileDocumentDir)
.then(function() {
    return nodejsProcess.createTrackingFile(mobileDocumentDir, nodeRedBootTrackingName)    
})
.then(function() {
    // Initialise the runtime with a server and settings
    RED.init(server, settings);

    // Serve the editor UI from /red
    app.use("/", RED.httpAdmin);

    // Serve the http nodes UI from /api
    app.use("/api", RED.httpNode);

    server.listen(1880);
    return RED.start();
})
.then(function() {
    nodejsProcess.removeTrackingFile(mobileDocumentDir, nodeRedBootTrackingName);
    console.log("Node-RED started");
})
.catch(function(reason) {
    console.error("While starting:", reason);
});




