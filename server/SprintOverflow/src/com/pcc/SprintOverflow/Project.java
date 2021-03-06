package com.pcc.SprintOverflow;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import javax.persistence.Entity;
import javax.persistence.EntityManager;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.NoResultException;

import com.google.appengine.api.datastore.Key;
import com.google.gson.*;
import com.google.gson.annotations.Expose;

@Entity
public class Project {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Key key;
	@Expose private String projectOwnerEmail;
	@Expose private String projectId;
	@Expose private String securityToken;
	@Expose private String softDelete;
	@Expose private String discoverable;
	@Expose private String generationId;
	@Expose private Set<Epic> epics;
	@Expose private List<String> resolutions;
	@Expose private String didNotDiscover;
	
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
	
	public String getProjectKey() {
		return getProjectOwnerEmail() + getSecurityToken();
	}
	
	public Set<Epic> getEpics() {
		return epics;
	}
	
	public String getSoftDelete() {
		return softDelete;
	}
	
	public void setSoftDelete(String aSoftDelete) {
		softDelete = aSoftDelete;
	}
	
	public String getDiscoverable() {
		return discoverable;
	}
	
	public void setDiscoverable(String aDiscoverable) {
		discoverable = aDiscoverable;
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
	
	public String getDidNotDiscover() {
		return didNotDiscover;
	}
	
	public void setDidNotDiscover(String aSearch) {
		didNotDiscover = aSearch;
	}
	
	/**
	 * Get the Generation Id.
	 * 
	 * The Generation Id is a way to tie up responses to requests.
	 * The client can make progress when offline so it might change
	 * a given data structure.  Each time is does this, it changes its
	 * Generation Id.  Whenever the server sees a generation Id and
	 * responds, it copies the generation Id over.  This is so that
	 * when returned to the client, if it did not make local progress
	 * with that particular data structure, it knows for sure that the
	 * server has responded to the clients data request as seen by the
	 * client at the time the response is processed at the client.
	 * 
	 * This is needed because the client maintains two parallel data
	 * structures, lastFetch (from the server) and nextPush (to the
	 * server).  When it gets a lastFetch item matching the generation
	 * Id of a nextPush item, it deletes locally its nextPush item.
	 * 
	 * The augmented set of lastFetch + nextPush is what the client
	 * sees as the latest local description of the world.
	 * 
	 * @return the Generation Id.
	 */
	public String getGenerationId() {
		return generationId;
	}
	
	/**
	 * Set the generation Id.
	 * 
	 * See the documentation {@link getGenerationId} for a description
	 * of the generation Id concept.
	 * 
	 * @param aGenerationId the generation Id to set
	 */
	public void setGenerationId(String aGenerationId) {
		generationId = aGenerationId;
	}
	
	Project(String aOwner, String aId, String aToken, String aDiscoverable, String aGenerationId) {
		setProjectOwnerEmail(aOwner);
		setProjectId(aId);
		setSecurityToken(aToken);
		setEpics(new LinkedHashSet<Epic>());
		setSoftDelete(Request.NO.toString());
		setDiscoverable(aDiscoverable);
		setDidNotDiscover(null);
		setGenerationId(aGenerationId);
		resolutions = new ArrayList<String>();
	}
	
	Project(String aOwner, String aId, String aGenerationId, ProjectJoinFailure aJoinFailure) {
		setProjectOwnerEmail(aOwner);
		setProjectId(aId);
		setSecurityToken(aGenerationId);
		resolutions = new ArrayList<String>();
		setDidNotDiscover(aJoinFailure.getProblem());
		setGenerationId(aGenerationId);
	}
	
	Project(JsonObject json) throws ProjectCreateException {
		try {
			setProjectOwnerEmail(json.get(Request.ProjectOwnerEmail.toString()).getAsString());
			setProjectId(json.get(Request.ProjectId.toString()).getAsString());
			setSecurityToken(json.get(Request.SecurityToken.toString()).getAsString());
			setDidNotDiscover(null);
			setGenerationId(json.get(Request.GenerationId.toString()).getAsString());
			
			/* PROTOCOL DATA COMPATIBILITY.
			 * If SoftDelete is absent, assume it is NO.
			 */
			if (json.get(Request.SoftDelete.toString()) != null) {
				setSoftDelete(json.get(Request.SoftDelete.toString()).getAsString());
			} else {
				setSoftDelete(Request.NO.toString());
			}
			/* PROTOCOL DATA COMPATIBILITY.
			 * If Discoverable is absent, assume it is NO.
			 */
			if (json.get(Request.Discoverable.toString()) != null) {
				setDiscoverable(json.get(Request.Discoverable.toString()).getAsString());
			} else {
				setDiscoverable(Request.NO.toString());
			}
		} catch (Exception e) {
			throw new ProjectCreateException("Bad json data when creating project: " + json.toString());
		}
		setEpics(new LinkedHashSet<Epic>());
		resolutions = new ArrayList<String>();
	}
	
	/**
	 * Fetch the specified project by its key or return null.
	 * 
	 * @param aProjectOwnerEmail
	 * @param aSecurityToken
	 * @return specified project, or null
	 * @note Should there be more than one project matching the key,
	 *       we only return the first.  This should not happen but we
	 *       are lenient in this area in case we want to re-populate
	 *       the data with deleting the old data.
	 */
	static Project fetchProject(String aProjectOwnerEmail, String aSecurityToken, String aGenerationId) {
		Project project = null;
		EntityManager em = null;
		try {
			em = SingletonManager.getEntityManagerFactory().createEntityManager();
			try {
				project = (Project) em.createQuery(
						"select p from Project p" +
								" where p.projectOwnerEmail=:supplied_email" +
						" and p.securityToken=:supplied_securityToken" +
						" and p.didNotDiscover is null")
						.setParameter("supplied_email", aProjectOwnerEmail)
						.setParameter("supplied_securityToken", aSecurityToken)
						.getSingleResult();
			} catch (NoResultException nre) {
				return null;
			}
		} finally {
			em.close();
		}
		project.setGenerationId(aGenerationId);
		return project;
	}
	
	/**
	 * Find a project based on its owner email, and either the Security
	 * Token or its Project Id.
	 * 
	 * This function respects the discoverability setting of a project.
	 * If a project is "discoverable", then it can be found using its
	 * Project Id or Security Token.  If it is not discoverable, the
	 * Project Id cannot be used for searching.  This prevents people
	 * from guessing the name of your project and thus seeing private
	 * project data.  A project might be made discoverable because it
	 * is not sensitive data.  It means that it is easy to join the
	 * project because the Project Id would be more memorable than the
	 * Security Token.
	 * 
	 * @param aProjectOwnerEmail the project owner's email address is always needed
	 * @param aSecurityTokenOrId the Security Token or Project Id
	 * @param aGenerationId the client Generation Id
	 * @return the Project found, else null.
	 */
	static Project findProject(String aProjectOwnerEmail, String aSecurityTokenOrId, String aGenerationId) {
		Project project = null;
		EntityManager em = null;
		if ((project = fetchProject(aProjectOwnerEmail, aSecurityTokenOrId, aGenerationId)) != null) {
			project.setGenerationId(aGenerationId);
			return project;
		}
		try {
			em = SingletonManager.getEntityManagerFactory().createEntityManager();
			try {
				project = (Project) em.createQuery(
						"select p from Project p" +
								" where p.projectOwnerEmail=:supplied_email" +
								" and p.projectId=:supplied_key" +
								" and p.discoverable='YES' " +
								" and p.didNotDiscover is null")
						.setParameter("supplied_email", aProjectOwnerEmail)
						.setParameter("supplied_key", aSecurityTokenOrId)
						.getSingleResult();
				project.setGenerationId(aGenerationId);
			} catch (NoResultException nre) {
				return new Project(
						aProjectOwnerEmail,
						aSecurityTokenOrId,
						aGenerationId,
						new ProjectJoinFailure(aProjectOwnerEmail + " " + aSecurityTokenOrId));
			}
		} finally {
			em.close();
		}
		return project;
	}
	
	static void storeProject(Project p) {
		EntityManager em = null;
		if (null == p) {
			throw new NullPointerException("Cannot store a project which is null");
		}
		if (p.getDidNotDiscover() != null) {
			System.out.println("Rejecting storage of didNotDiscover projects: " + p.getDidNotDiscover());
			return;
		}
		try {
			em = SingletonManager.getEntityManagerFactory().createEntityManager();
			if (em.contains(p)) {
				System.out.println("em already manages " + p + " so storeProject has no more work to do");
			} else {
				em.persist(p);
			}
		} finally {
			em.close();
		}
	}
	
	/**
	 * Determine if the supplied object is a join project request.
	 * 
	 * The client can under-specify a project in the case of joining
	 * projects because in addition to the project owner email, either
	 * the Security Token or the Project Id can be supplied.
	 * 
	 * The joining request is marked by the name JoinProject being
	 * set.
	 * @param r the json object request from the client
	 * @return true if it is a join project request, otherwise false.
	 */
	private static boolean joinProjectRequest(JsonObject r) {
		if (null != r.get(Request.JoinProject.toString())) {
			return true;
		}
		return false;
	}
	
	static Project extractProjectFromJson(JsonObject jo) {
		if (joinProjectRequest(jo)) {
			Project search = Project.findProject(
					jo.get(Request.ProjectOwnerEmail.toString()).getAsString(),
					jo.get(Request.IdOrToken.toString()).getAsString(),
					jo.get(Request.GenerationId.toString()).getAsString());
			if (null != search) {
				return search;
			}
		} else {
			Project p;
			try {
				p = new Project(jo);
			} catch (ProjectCreateException e) {
				return null;
			}
			if (p != null) {
				return p;
			}
		}
		return null;
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
		if  (null != newProject.getDidNotDiscover()) {
			throw new IllegalArgumentException("Cannot resolve the new project as it is a didNotDiscover project, designed only for reporting errors");
		}
		
		// The ProjectId is mutable.
		resolver.threeWayResolve(
				baseProject.getProjectId(),
				newProject.getProjectId(),
				masterProject.getProjectId(),
				masterProject.getResolutions());
		
		// In practice, since the client does not offer an undelete option in its UI, in practice
		// we will only advance SoftDelete from NO to YES, never YES to NO.
		resolver.threeWayResolve(
				baseProject.getSoftDelete(),
				newProject.getSoftDelete(),
				masterProject.getSoftDelete(),
				masterProject.getResolutions());
		
		resolver.threeWayResolve(
				baseProject.getDiscoverable(),
				newProject.getDiscoverable(),
				masterProject.getDiscoverable(),
				masterProject.getResolutions());
		
		// Now need a public static in Epic to do the same and recurse downwards.
		
	}
}
