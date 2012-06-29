/**
Copyright Faisal Memon 2012.  All rights reserved. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

SprintOverflow is a simple server side implementation of an Agile Software Process Productivity tool.

<h1>Basic Architecture</h1>
The basic architecture of the Agile Collaborator is to have a IOS client application which makes JSON requests to a server.
The server runs on Google App Engine (GAE).
Data is cached on the client using Core Data.
We represent using Interfaces the basic data model in Java in GAE, and then use the Google GSON library to provide the data to the client.

<h1>Account Data</h1>
Faisal Memon has a google account and uses the GAE application id ios38722 to host the server.

<h1>Manual Server Testing</h1>
Here are some simple URLs to stimulate the server:

http://localhost:8888/sprintoverflow?Mode=Epic 
will dump a sample epic with child stories and tasks.

http://localhost:8888/sprintoverflow?Version=Version1_0
will confirm that the protocol version specified is supported

http://ios38722.appspot.com/sprintoverflow?Mode=Epic
will provide a publicly viewable sample epic when deployed

@author Faisal Memon
*/
package com.pcc.SprintOverflow;

