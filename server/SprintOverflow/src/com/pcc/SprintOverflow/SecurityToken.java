package com.pcc.SprintOverflow;

public class SecurityToken {
	private String projectOwnerEmail;
	private String projectId;
	private String securityToken;
	
	SecurityToken(String aOwner, String aId, String aToken) {
		this.projectOwnerEmail = aOwner;
		this.projectId = aId;
		this.securityToken = aToken;
	}
}
