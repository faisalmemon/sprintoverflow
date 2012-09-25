package com.pcc.SprintOverflow;

import java.util.LinkedHashSet;
import java.util.List;
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
	private List<String> resolutions;
	
	/**
	 * No-arg public constructor as required by the Java Persistence API.
	 */
	public Project() {
	}
	
	/**
	 * Create a placeholder Null project.
	 * 
	 * Sometimes a null is passed as a project reference.  When this
	 * is processed, it can be substituted for the NullProject.  The
	 * purpose of this is so that getter functions then can return
	 * nulls, without the getter itself throwing a NPE.
	 */
	private static Project NullProject = new Project();
	
	public Set<Epic> getEpics() {
		return epics;
	}
	
	public List<String> getResolutions() {
		return resolutions;
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
	
	/**
	 * Resolve between base, new and master Projects.
	 * 
	 * The Project class allows the projectId to be modified, and its
	 * list of epics to be modified by a resolver.  Projects are top-level
	 * entities, so new projects are handled by the master automatically
	 * being created whenever there is a new project referenced by a 
	 * client.  In such cases, the base project will be null.
	 * 
	 * @param baseProject
	 * @param newProject
	 * @param masterProject
	 * @param resolver
	 */
	public static void resolveProject(Project baseProject, Project newProject, Project masterProject, Resolver<String> resolver) {
		if (null == masterProject) {
			throw new NullPointerException("The masterProject should have been auto-setup as soon as a newProject mentioned its existance");
		}
		if (null == baseProject) {
			// we have a new project
			baseProject = NullProject;
		}
		if (null == newProject) {
			throw new NullPointerException("The next project may not be null because it means we have a client asking to update the server but supplying no projects");
		}
		resolver.threeWayResolve(baseProject.getProjectId(), newProject.getProjectId(), masterProject.getProjectId(), masterProject.getResolutions());
		// Now need a public static in Epic to do the same and recurse downwards.
		
	}
}
