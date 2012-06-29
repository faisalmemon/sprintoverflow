package com.pcc.SprintOverflow;

public class JohnSmithDemo {
	private final String firstName;
	private final String lastName;
	
	public static JohnSmithDemo JohnSmith = new JohnSmithDemo("John Appleseed", "Smith");
	
	public JohnSmithDemo(String firstName, String lastName) {
		this.firstName = firstName;
		this.lastName = lastName;
	}
}
