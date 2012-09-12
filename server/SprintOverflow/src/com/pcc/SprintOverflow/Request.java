/**
 * Copyright Faisal Memon 2012.  All rights reserved. 
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 * FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package com.pcc.SprintOverflow;

/**
 * Request parameters from the client
 * 
 * This class encapsulates all the different request types passed from the
 * client.
 * 
 * The names of the enumerations MUST NOT change due to their String equivalent
 * being used as actual protocol strings sent from the client.
 * 
 * The notation used here is URL request notation so it is clear the
 * mapping between the protocol and the URLs that represent them.
 * 
 * <h1>Protocol Modes</h1>
 * The request protocol is divided at the top level into Modes.  Each mode
 * has its own set of attributes.
 * The supported modes are:
 * 	?Mode=Epic
 * 	?Mode=Sprint
 *  ?Mode=Story
 *  ?Mode=Task
 *  ?Mode=SaveToken
 *  ?Mode=Version
 *  
 * <h2>Version Mode</h2>
 * The client can specify the highest protocol version it supports and the
 * server then can respond if that version is understood or not.
 * ?Mode=Version&ClientVersion=2
 *  
 * @author faisalmemon
 *
 */
public enum Request {
	/** Mode selection
	 * <code> ?Mode=Epic </code> or
	 * <code> ?Mode=Sprint </code> or
	 * <code> ?Mode=Story </code> or
	 * <code> ?Mode=Task </code> or
	 * <code> ?Mode=CreateProject </code> or
	 * <code> ?Mode=Version </code>
	 */
	Mode,
	Epic, Sprint, Story, Task, CreateProject, Version,
	
	/** CreateProject mode
	 * <code>?Mode=CreateProject&ProjectOwnerEmail=john@example.com&ProjectId=df23&SecurityToken=jk3424jee</code> 
	 */
	ProjectOwnerEmail, 
	ProjectId, 
	SecurityToken,
	
	/** Version mode protocol
	 * <code> ?Mode=Version&ClientVersion=1 </code>
	 */
	ClientVersion,
}
