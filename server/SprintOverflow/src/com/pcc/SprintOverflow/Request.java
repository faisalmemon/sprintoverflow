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
 * This class encapsulates all the different request types passed from
 * the client.  See also @see Response for the repsonse types.
 * 
 * The names of the enumerations MUST NOT change due to their String
 * equivalent being used as actual protocol strings sent from the
 * client.
 * 
 * The request and response protocol is based upon url encoded JSON
 * data strings.  The purpose of the encoding is to avoid collisions
 * with meta-data characters used by HTTP POST.  To avoid escaping out
 * of the JSON data structure from bad or malicious data, we convert
 * any double quote (") to single quote(') at the client.
 * 
 * The protocol starts with the client supplying the HTTP POST
 * <code>
 * Json=string
 * </code>
 * where string is a url-encoded JSON format string representing the
 * dictionaries LastFetch, and NextPush.  LastFetch represents the
 * last retrieve of data from the server for the given projects of
 * interest at that time.  NextPush is the amended data based from
 * LastFetch to be sent to the server.  The purpose of the client
 * sending past data originated by the server is to allow the server
 * to implement a merge algorithm to resolve changes in the client
 * against the server.  We have:
 * <code>
 * BASE
 * NEW
 * MASTER
 * </code>
 * where BASE is LastFetch, NEW is NextPush, and MASTER is the value
 * stored on the server in its persistent store.
 * 
 * The server does a resolve of the request.  This is documented in
 * @see Model
 * 
 * Once resolved, the server persists the newly updated MASTER for the
 * projects listed in NextPush.  Then it replies with
 * <code>
 * ReplyJson=string
 * </code>
 *
 * The ReplyJson is a JSON array of two dictionaries, ReturnedProjects
 * and ResolveList.
 * 
 * @author faisalmemon
 */
public enum Request {
	ProjectOwnerEmail, 
	ProjectId,
	SoftDelete,
	NO,
	YES,
	
	Epic, Sprint, Story, Task,
	
	Version,
	ClientVersion,
	
	SecurityToken,
	Token,
	
	Json,
	LastFetch,
	NextPush,
}
