package com.pcc.SprintOverflow;

import java.util.LinkedHashSet;
import java.util.Set;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

import com.google.appengine.api.datastore.Key;
import com.google.gson.*;

@Entity
public class Project {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Key key;
	private String projectOwnerEmail;
	private String projectId;
	private String securityToken;
	private Set<Epic> epics;
	
	/**
	 * No-arg public constructor as required by the Java Persistence API.
	 */
	public Project() {
	}
	
	public Set<Epic> getEpics() {
		return epics;
	}

	public void setEpics(Set<Epic> epics) {
		this.epics = epics;
	}
	
	public void setProjectOwnerEmail(String projectOwnerEmail) {
		this.projectOwnerEmail = projectOwnerEmail;
	}

	public void setProjectId(String projectId) {
		this.projectId = projectId;
	}

	public void setSecurityToken(String securityToken) {
		this.securityToken = securityToken;
	}
	public String getProjectOwnerEmail() {
		return projectOwnerEmail;
	}

	public String getProjectId() {
		return projectId;
	}

	public String getSecurityToken() {
		return securityToken;
	}
	
	Project(String aOwner, String aId, String aToken) {
		setProjectOwnerEmail(aOwner);
		setProjectId(aId);
		setSecurityToken(aToken);
		setEpics(new LinkedHashSet<Epic>());
	}
	
	Project(JsonObject json) throws ProjectCreateException {
		try {
			setProjectOwnerEmail(json.get(Request.ProjectOwnerEmail.toString()).getAsString());
			setProjectId(json.get(Request.ProjectId.toString()).getAsString());
			setSecurityToken(json.get(Request.SecurityToken.toString()).getAsString());
		} catch (Exception e) {
			throw new ProjectCreateException("Bad json data when creating project: " + json.toString());
		}
		setEpics(new LinkedHashSet<Epic>());
	}
	
	/** Add a epic to the project.
	 * 
	 * Projects can comprise zero or more unique epics.
	 * 
	 * @param epic epic to add
	 * @return true if the item was added, false otherwise.
	 */
	public boolean addEpic(Epic epic) {
		return epics.add(epic);
	}
}
