

/**

BareBones is a simple server side implementation of an Agile Software Process Productivity tool.

<h1>Basic Architecture</h1>
The basic architecture of the Agile Collaborator is to have a IOS client application which makes JSON requests to a server.
The server runs on Google App Engine (GAE).
Data is cached on the client using Core Data.
We represent using Interfaces the basic data model in Java in GAE, and then use the Google GSON library to provide the data to the client.

@author Faisal Memon
*/
package com.pcc.SprintOverflow;

