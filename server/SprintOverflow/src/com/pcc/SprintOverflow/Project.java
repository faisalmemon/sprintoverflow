package com.pcc.SprintOverflow;

public class Project {
	private String projectOwnerEmail;
	private String projectId;
	private String securityToken;
	
	Project(String aOwner, String aId, String aToken) {
		this.projectOwnerEmail = aOwner;
		this.projectId = aId;
		this.securityToken = aToken;
	}
}
