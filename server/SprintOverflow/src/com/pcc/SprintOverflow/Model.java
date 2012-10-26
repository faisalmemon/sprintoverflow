package com.pcc.SprintOverflow;

import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.persistence.EntityManager;
import com.google.gson.*;

/*
 * Server-side Model for projects of interest for a given client.
 * 
 * This class looks at the state of the client in terms of its data
 * and the changes it desires to be made, and resolves these against
 * the server persistent record, resolving differences and generating
 * revised data for the client.
 */
public class Model implements Resolver<String> {
	private Map<String, Project> newModel;
	private Map<String, Project> baseModel;
	private Map<String, Project> masterModel;
	private enum State { Init, LoadedClientData, LoadedMasterData, ResolvedData, PersistedUpdatedMaster };
	
	private State currentState;

	public Model() {
		newModel = new LinkedHashMap<String, Project>();
		baseModel = new LinkedHashMap<String, Project>();
		masterModel = new LinkedHashMap<String, Project>();
		currentState = State.Init;
	}
	
	public void reset() {
		// Throw away old data, so it can be GC'ed
		newModel = null;
		baseModel = null;
		masterModel = null;

		// Start with fresh data
		newModel = new LinkedHashMap<String, Project>();
		baseModel = new LinkedHashMap<String, Project>();
		masterModel = new LinkedHashMap<String, Project>();
		currentState = State.Init;
	}
	
	public boolean resolveClientData(JsonElement nextPushJson, JsonElement lastFetchJson) {
		boolean progress;
		
		progress = uploadData(nextPushJson, lastFetchJson);
		if (!progress) {
			return false;
		}
		
		progress = loadMasterData();
		if (!progress) {
			return false;
		}
		
		progress = resolveModel();
		if (!progress) {
			return false;
		}
		
		progress = persistUpdatedMaster();
		return progress;	
	}
	
	private boolean uploadData(JsonElement nextPushJson, JsonElement lastFetchJson) {
		JsonArray projectNextArray = null;
		JsonArray projectBaseArray = null;
		
		if (currentState != State.Init) {
			return false;
		}
		
		try {
			if (nextPushJson.isJsonArray()) {
				projectNextArray = nextPushJson.getAsJsonArray();
			} else {	
				System.out.println("next push is not a json array");
				return false;
			}
			if (lastFetchJson.isJsonArray()) {
				projectBaseArray = nextPushJson.getAsJsonArray();
			} else {
				System.out.println("last fetch is not a json array");
				return false;
			}
			Iterator<JsonElement> pnaItr = projectNextArray.iterator();
			Iterator<JsonElement> pbaItr = projectBaseArray.iterator();

			while (pnaItr.hasNext()) {
				JsonObject e = pnaItr.next().getAsJsonObject();
				Project p = Project.extractProjectFromJson(e);
				if (null != p) {
					newModel.put(p.getProjectKey(), p);
				}
			}
			while (pbaItr.hasNext()) {
				JsonObject e = pbaItr.next().getAsJsonObject();
				Project p = Project.extractProjectFromJson(e);
				if (p != null) {
					baseModel.put(p.getProjectKey(), p);
				}
			}
		} catch (ClassCastException cce) {
			System.out.println("Could not create project data cce: " + cce);
			return false;
		} catch (IllegalStateException ise) {
			System.out.println("Could not create project data ise: " + ise);
			return false;
		} catch (Exception e) {
			System.out.println("Programming error: Unexpected exception e: " + e);
			return false;
		}
		
		currentState = State.LoadedClientData;
		return true;
	}
	
	private boolean loadMasterData() {
		if (currentState != State.LoadedClientData) {
			return false;
		}
		
		Iterator<Project>projItr = newModel.values().iterator();
		while (projItr.hasNext()) {
			Project p = projItr.next();	
			/*
			 * If the client has attempted to join a project, newModel
			 * would have seen this (via the JoinProject tag) and then
			 * done a search.  If that search failed to match, a
			 * "Problem Project" would have been created which 
			 * encapsulates the failed search.  Problem projects are
			 * never persisted on the server, but they are returned to
			 * the user so that an error message can be reported.
			 * The client keeps circulating the problem projects
			 * because it persists them, until the user deletes them.
			 * This is so we can work offline.
			 */
			if (p.getProblem() != null) {
				masterModel.put(p.getProjectKey(), p);
				continue;
			}
			
			String securityToken = p.getSecurityToken();
			String projectOwnerEmail = p.getProjectOwnerEmail();
			String projectId = p.getProjectId();
			String discoverable = p.getDiscoverable();
			String generationId = p.getGenerationId();
			Project masterProject = Project.fetchProject(projectOwnerEmail, securityToken, generationId);
			if (null != masterProject) {
				masterModel.put(p.getProjectKey(), masterProject);
			} else {
				System.out.println("newModel has project not seen before " + projectOwnerEmail + " " + securityToken);
				if (null == projectOwnerEmail || null == projectId || null == securityToken) {
					throw new NullPointerException("newModel presents a project for add which has nulls");
				}
				p = new Project(projectOwnerEmail, projectId, securityToken, discoverable, generationId);
				Project.storeProject(p);
				masterModel.put(p.getProjectKey(), p);
			}
		}
		currentState = State.LoadedMasterData;
		return true;
	}
	
	private boolean resolveModel() {
		if (currentState != State.LoadedMasterData) {
			return false;
		}		
		
		Iterator<Project>projItr = newModel.values().iterator();
		while (projItr.hasNext()) {
			Project newProject = projItr.next();
			if (newProject.getProblem() != null) {
				// Don't resolve problem projects as these are merely
				// relayed back to the user as they comprise an error
				// message
				continue;
			}
			Project masterProject = masterModel.get(newProject.getProjectKey());
			Project baseProject = baseModel.get(newProject.getProjectKey());
			Project.resolveProject(baseProject, newProject, masterProject, this);		
		}
		currentState = State.ResolvedData;
		return true;
	}
	
	private boolean persistUpdatedMaster() {
		if (currentState != State.ResolvedData) {
			return false;
		}
		EntityManager em = null;
		Iterator<Project>projItr = masterModel.values().iterator();
		if (!projItr.hasNext()) {
			/*
			 * When the client supplies an empty list of projects,
			 * there is no persisting needed.  But it is not an error
			 * to do no work, it just represents a cold start situation
			 * at the client.
			 */
			currentState = State.PersistedUpdatedMaster;
			return true;
		}
		Project p = null;
		while (projItr.hasNext()) {
			p = projItr.next();
			if (null == p) {
				throw new NullPointerException("Cannot store a project which is null");
			}
			try {
				em = SingletonManager.getEntityManagerFactory().createEntityManager();
				if (em.contains(p)) {
					System.out.println("em already managing " + p + " so no more work to do");
				}  else {
					em.merge(p);
				}
			} finally {
				em.close();
			}
		}
		currentState = State.PersistedUpdatedMaster;
		return true;
	}
	
	public String getUpdatedMasterAsJsonString() {
		if (currentState != State.PersistedUpdatedMaster) {
			throw new IllegalStateException("Tried to get updated master before it was persisted, instead we are in state " + currentState.toString());
		}
		Project[] updatedProjects = null;
		updatedProjects = masterModel.values().toArray(new Project[0]);
		return SingletonManager.getTheGson().toJson(updatedProjects);
	}
	
	@Override
	public void threeWayResolve(String baseItem, String newItem, String masterItem, List<String> resolutionDescription)
	{
		Situation s = Situation.noChange;
		if (baseItem.equals(masterItem)) {
			if (baseItem.equals(newItem)) {
				s = Situation.noChange;
			} else {
				s = Situation.clientPushNeeded;
			}
		} else {
			if (baseItem.equals(newItem)) {
				s = Situation.clientCatchupNeeded;
			} else {
				if (newItem.equals(masterItem)) {
					s = Situation.updateStaleDataConvergeServer;
				}
				else {
					s = Situation.updateStaleDataDivergeServer;
				}
			}
		}
		switch (s) {
		default:
			System.out.println("Unexpected case in threeWayResolve " + s.toString());
			break;
		case updateStaleDataDivergeServer:
			resolutionDescription.add(
					"Server was updated differently, change " 
							+ newItem + " from " + baseItem 
							+ "was not taken but server version " 
							+ masterItem + " was taken.");
			// do nothing as masterItem is correct
			break;
		case updateStaleDataConvergeServer:
			// do nothing as masterItem is correct
			break;
		case clientCatchupNeeded:
			// do nothing as masterItem is correct
			break;
		case clientPushNeeded:
			masterItem = newItem;
			break;
		case noChange:
			// do nothings as there is no changes between them
			break;
		}		
	}
}
