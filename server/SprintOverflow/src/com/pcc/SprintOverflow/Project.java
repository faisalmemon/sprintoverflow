package com.pcc.SprintOverflow;

import java.util.LinkedHashSet;
import java.util.Set;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

import com.google.appengine.api.datastore.Key;

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
	
	Project(String aOwner, String aId, String aToken) {
		this.projectOwnerEmail = aOwner;
		this.projectId = aId;
		this.securityToken = aToken;
		epics = new LinkedHashSet<Epic>();
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
