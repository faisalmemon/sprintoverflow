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

/** Create a default initial agile project scenario.
 * 
 * To allow us to understand the basics of client-server useability we need to have
 * some initial data values setup for a project.  This is so we can experiment with
 * easy addition of tasks/stories/epics.
 * 
 * Eventually, we need a database back end and place the initial project scenario in
 * there.  This will feed into the analytics algorithm.
 * 
 * @author faisalmemon
 *
 */
public class DefaultScenario {
	public static DefaultScenario theDefaultScenario = new DefaultScenario();
	
	private Epic epic;
	
	private DefaultScenario() {
		epic = new Epic("Bootstrap the AgileOverflow project");
		Story story0 = new Story("Create GAE default scenario response");
		epic.addStory(story0);
		Task task0 = new Task("Create default scenario java class");
		story0.addTask(task0);
		Story story1 = new Story("Migrate to new MacBook Air Mid 2012");
		Task task1 = new Task("Fix up eclipse for MBA2012");
		story1.addTask(task1);
		Task task2 = new Task("Fix up xcode for MBA2012");
		story1.addTask(task2);
		epic.addStory(story1);
	}
}
