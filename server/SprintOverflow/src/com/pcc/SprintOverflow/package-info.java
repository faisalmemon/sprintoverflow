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

The following is a conceptual description of the Synchronization Model.
Some actual implementation details are listed, but in other cases the
steps shown are implemented by differently named methods.

<h2>Client-side Persistent Data</h2>

On the client side the following data is persisted on disk

<ul>
<li>ProjectList<code>[ {ProjectOwnerEmail,ProjectId,SecurityToken}* ]</code>
<ul>
	<li>may be null (no projects yet)
	<li>may be projects not known on the server yet
</ul>	
<li>LastFetch<code>{JSON array of projects with e/s/t tree data}</code> for each project in the ProjectList
<ul>
	<li>may be null (never been online before)
</ul>
	
<li>PendingQueue<code>[ {action, resolution}* ]</code>
</ul>	

<h2>Client originated local model changes</h2>

The client, whether online or not, can make model changes, such as
adding a new project, adding a new story, etc.  This needs to be
responsive but also cope with faults when synchronizing with the
server.

Suppose the local model change is to AddNewProject.

For any local model change, the following steps are done:
<ol>
<li>CalculateNewModel
<li>AsyncRecordRequest
<li>SyncUpdateMemoryModel
</ol>

This means the change is seen immediately in the UI to the user.

<h3>CalculateNewModel</h3>
This step merely works out what delta will be applied to the in-memory
model.  For example, in the case of creating a new project, the
SecurityToken value is computed.  In the case of adding a Task, it is
the object that would represent the task that is established.

<h3>AsyncRecordRequest</h3>

The AsyncRecordRequest does not run on the UI thread.  It does the
following when scheduled (on a serial dispatch queue):

<ol>
<li>UpdatePersistentData:
<ul>
<li>ProjectList - updated here for the new project request
<li>PendingQueue - updated here to add the request
"AddNewProject <ProjectOwnerEmail,ProjectId,SecurityToken>"
</ul>

<li>Do a SyncWithServer

<li>Update the in-memory model to the persistent store

<li>Trigger a UI update

<li>Put a badge next to the sync tab if there is a pending queue
   item that needs resolving
</ol>

<h4>SyncWithServer</h4>

A SyncWithServer is a communication with the server which results in a
new definitive model for a project, and resolution actions on pending
requests.

<p>
First there is an Upload to the server, and then a Download from the
server.
<ul>
<li>Upload comprises sending ProjectList and PendingQueue.
<li>Download comprises PendingQueue and LastFetch data.
</ul>

After Download, we update our persistent store with PendingQueue
and LastFetch.

<h3>SyncUpdateMemoryModel</h3>
This is directly updating the memory model for the given project and
reloading the UI so it is shown.

<h2>Resolving inconsistencies</h2>

The PendingQueue has a UI view which presents it as well as actions
to resolve the items.  The view is on its own tab, with a badge
indicating how many unresolved items are present.

<h1>Boot Model</h1>
The Boot Model is how the system boots up.  Its design is derived from
the Synchronization Model.  Upon boot,
<ul>
<li>Read in the ProjectList
<li>For each project, read in the LastFetch data.  Build the data
model from it.
<li>For each project, read in the PendingQueue.  Augment the model
from it.
<li>Kick off a Synchronization in the background.
</ul>
@author Faisal Memon
 */
package com.pcc.SprintOverflow;

