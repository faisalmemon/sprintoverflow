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
 * Provide response data from the server to the client.
 * 
 * This class encapsulates all the different response types passed from the server.
 * 
 * The names of the enumerations cannot change due to their String equivalent being
 * used as actual protocol strings sent to the client.
 * 
 * 
 * @author faisalmemon
 */
public enum Response {
	/** The first version supported by the server */
	Version1_0,
	
	/** Unsupported Version */
	VersionNotSupported,
	
	/** Placeholder response assumed by client before it listens to the server */
	ServerNotRespondedYet,
	
	/** Response assumed when the server did not respond in time */
	ServerDidNotRespond,
	DidNotDiscover,
	
	/** Json Reply from a Json request */
	JsonReply,
	ReturnedProjects,
	ResolveList,
}
