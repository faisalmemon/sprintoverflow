package com.pcc.SprintOverflow;

public class Task {
	
	/**
	 * The first field for serialization is the unique identifier so that in the
	 * future we can encode compatibility data here.
	 */
	private final long taskId;
	private String taskName;
	private Status status;
	
	public Task(String name) {
		this.taskName = name;
		taskId = SerialNumber.next();
		status = Status.NotStarted;
	}
}
