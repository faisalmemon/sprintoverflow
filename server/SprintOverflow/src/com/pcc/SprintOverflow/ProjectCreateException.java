package com.pcc.SprintOverflow;

public class ProjectCreateException extends Exception {
	private static final long serialVersionUID = 7863140979398865611L;
	public ProjectCreateException() { super(); }
	public ProjectCreateException(String message) { super(message); }
	public ProjectCreateException(String message, Throwable cause) { super(message, cause); }
	public ProjectCreateException(Throwable cause) { super(cause); }
}
