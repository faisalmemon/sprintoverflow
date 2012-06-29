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

import java.util.LinkedHashSet;
import java.util.Set;

public class Epic {

	/**
	 * The first field for serialization is the unique identifier so that in the
	 * future we can encode compatibility data here.
	 */
	private final long epicId;
	private String epicName;
	private Set<Story> stories;
	
	public Epic(String name) {
		this.epicName = name;
		this.epicId = SerialNumber.next();
		stories = new LinkedHashSet<Story>();
	}
	
	/** Add a story to the epic.
	 * 
	 * Epics can comprise zero or more unique stories.
	 * 
	 * @param story story to add
	 * @return true if the item was added, false otherwise.
	 */
	public boolean addStory(Story story) {
		return stories.add(story);
	}
}
