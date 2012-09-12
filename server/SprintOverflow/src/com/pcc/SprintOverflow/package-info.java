/**
Copyright Faisal Memon 2012.  All rights reserved. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

SprintOverflow is a simple server side implementation of an Agile
Software Process Productivity tool.

<h1>Basic Architecture</h1>
The basic architecture of the Agile Collaborator is to have a IOS
client application which makes JSON requests to a server.
The server runs on Google App Engine (GAE).
Data is cached on the client using Core Data.
We represent using Interfaces the basic data model in Java in GAE, and
then use the Google GSON library to provide the data to the client.

<h1>Account Data</h1>
Faisal Memon has a google account and uses the GAE application id 
ios38722 to host the server.

<h1>Manual Server Testing</h1>
Here are some simple URLs to stimulate the server:

http://localhost:8888/sprintoverflow?Mode=Epic 
will dump a sample epic with child stories and tasks.

http://localhost:8888/sprintoverflow?Version=Version1_0
will confirm that the protocol version specified is supported

https://ios38722.appspot.com/sprintoverflow?Mode=Epic
will provide a publicly viewable sample epic when deployed

<h1>Persistence</h1>
The server uses Java Persistence API v1.0 for its persistence service.  
This was chosen because it is simple to use, and works by default with
Eclipse.  We anticipate that data mining will be efficient as the
backing store is geared for massively horizontal queries.

As a consequence, the source code has JPA annotations throughout for
data classes.

<h1>Synchronization Model</h1>

<h2>Client-side Persistent Data</h2>

On the client side the following data is persisted on disk:
	ProjectList
	LastFetch
	PendingQueue
	
ProjectList
	may be null (no projects yet)
	[ {ProjectOwnerEmail,ProjectId,SecurityToken}* ]
	may be projects not known on the server yet
	
LastFetch
	may be null (never been online before)
	{JSON array of projects with e/s/t tree data} for each project
	in the ProjectList
	
PendingQueue
	[ {action, resolution}* ]



When communication is possible we do a Sync:
1) Upload
2) Download

The Upload comprises:
1) ProjectList
2) PendingQueue

The Download comprises:
1) ResolvedQueue
2) Model for each project in ProjectList

then we do a persist:
update ProjectList, LastFetch, PendingQueue

then we update the in-memory model according to LastFetch
then we do a UI refresh
--

Whenever a user action is done, e.g. add task, add project, we
1) Update ProjectList (only for new projects)
2) Append request to the PendingQueue
3) Update local model to assume the requested change was valid
4) Kick-off a Sync.

@author Faisal Memon
*/
package com.pcc.SprintOverflow;

