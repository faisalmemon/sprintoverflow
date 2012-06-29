package com.pcc.SprintOverflow;

import java.util.LinkedHashSet;
import java.util.Set;

public class Story {
	
	/**
	 * The first field for serialization is the unique identifier so that in the
	 * future we can encode compatibility data here.
	 */
	private final long storyId;
	private String storyName;
	private Set<Task> tasks;
	
	public Story(String name) {
		this.storyName = name;
		storyId = SerialNumber.next();
		tasks = new LinkedHashSet<Task>();
	}
	
	/** Add a task to the story.
	 * 
	 * Stories can comprise zero or more unique tasks.
	 * 
	 * @param task task to add
	 * @return true if the item was added, false otherwise.
	 */
	public boolean addTask(Task task) {
		return tasks.add(task);
	}
}
