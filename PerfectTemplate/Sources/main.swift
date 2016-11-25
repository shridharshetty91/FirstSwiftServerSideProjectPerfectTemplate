//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

// Create HTTP server.
let server = HTTPServer()

// Register your own routes and handlers
//var routes = Routes()
//routes.add(method: .get, uri: "/", handler: {
//		request, response in
//		response.setHeader(.contentType, value: "text/html")
//		response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
//		response.completed()
//	}
//)
//
//// Add the routes to the server.
//server.addRoutes(routes)

var routes = Routes()
// Create routes for version 1 API
var api = Routes()
api.add(method: .get, uri: "/call1", handler: { _, response in
    response.setBody(string: "API CALL 1")
    response.completed()
})
api.add(method: .get, uri: "/call2", handler: { _, response in
    response.setBody(string: "API CALL 2")
    response.completed()
})
api.add(method: .post, uri: "/foo/", handler: { request, response in
//    response.setBody(string: "API CALL for Variables - \(request.urlVariables[routeTrailingWildcardKey])")
    response.setBody(string: request.postBodyString!)
//    response.setBody(string: "API CALL for Variables - \(request.postParams)")
    response.appendBody(string:"\(request.queryParams)")
    response.completed()
})

// API version 1
var api1Routes = Routes(baseUri: "/v1")
// API version 2
var api2Routes = Routes(baseUri: "/v2")
// API version 3
var api3Routes = Routes(baseUri: "/v3")

// Add the main API calls to version 1
api1Routes.add(routes: api)
// Add the main API calls to version 2
api2Routes.add(routes: api)
// Update the call2 API
var v2Call2 = Route(method: .get, uri: "/call2", handler: { _, response in
//    response.setBody(string: "API v2 CALL 2")
    do {
        try response.setBody(json: ["name" : "shridhar"])
    } catch {
        
    }
    response.completed()
})
api2Routes.add(v2Call2)

// Add the main API calls to version 3
api3Routes.add(routes: api)
// Update the call1 API
api3Routes.add(method: .get, uri: "/call1", handler: { _, response in
    response.setBody(string: "API v3 CALL 1")
    response.completed()
})
//To use previous version method
api3Routes.add(v2Call2)

// Add all versions to the main server routes
routes.add(routes: api1Routes)
routes.add(routes: api2Routes)
routes.add(routes: api3Routes)

server.addRoutes(routes)

// Set a listen port of 8181
server.serverPort = 8181

// Set a document root.
// This is optional. If you do not want to serve static content then do not set this.
// Setting the document root will automatically add a static file handler for the route /**
server.documentRoot = "./webroot"

// Gather command line options and further configure the server.
// Run the server with --help to see the list of supported arguments.
// Command line arguments will supplant any of the values set above.
configureServer(server)

do {
	// Launch the HTTP server.
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
