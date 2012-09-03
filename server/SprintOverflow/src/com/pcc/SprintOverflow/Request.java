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
 * This class encapsulates all the different request types passed from the client.
 * 
 * The names of the enumerations cannot change due to their String equivalent being
 * used as actual protocol strings sent from the client.
 * @author faisalmemon
 *
 */
public enum Request {
	/** ?Mode=Epic or Sprint, Story, Task, SaveToken */
	Mode,
	Epic, Sprint, Story, Task, SaveToken,
	
	/** SaveToken mode protocol */
	ProjectOwnerEmail, 
	ProjectId, 
	SecurityToken,
	
	/** ?Version=2 where the supplied number is the highest protocol version understood by the client */
	Version,
}
