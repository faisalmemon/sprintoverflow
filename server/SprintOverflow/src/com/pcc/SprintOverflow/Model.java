package com.pcc.SprintOverflow;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.persistence.EntityManager;

import com.google.gson.*;

/*
 * Server-side Model for projects of interest for a given client.
 * 
 * This class looks at the state of the client in terms of its data
 * and the changes it desires to be made, and resolves these against
 * the server persistent record, resolving differences and generating
 * revised data for the client.
 * 
 * This file is based upon merging semantics.  From the client 
 * perspective, there are three aspects to merge data:
 * <ul>
 * <li>NEW MODEL</li>
 * <li>BASE MODEL</li>
 * <li>MASTER MODEL</li>
 * </ul>
 * 
 * Hereafter, we abbreviate to N, B, M.
 * 
 * B is the data the client last got from the server (potentially
 * null) for a given project.  That is, the Base from which changes
 * are proposed.  N is the modified version of the project data, thus
 * the New data.  M is the data in the server not seen by the client
 * necessarily due to the round trip time getting B, there could have
 * been further updates to the server from another client, particularly
 * if the client has been offline for some time.
 * 
 * There is a matrix of possibilities, and this leads to the resolution
 * done on the data to arrive at the new data that has to be persisted
 * by the master.
 * <code>
 * CASE 0 B!=M, B!=N, N!=M
 * CASE 1 B!=M, B!=N, N==M
 * CASE 2 B!=M, B==N, N!=M
 * CASE 3 B==M, B!=N, N!=M
 * CASE 4 B==M, B==N, N==M
 * </code>
 * 
 * <h1>Merge Analysis</h1>
 * In case 0, the client has a stale copy of the server data, a change
 * was made to it, and this change is different from the version at the
 * server.  This is a update-stale-data-diverge-server.
 * 
 * In case 1, the client has a stale copy of the server data, a change
 * was made to it, and this happened to coincide with the version at
 * the server.  This is a update-stale-data-converge-server.
 * 
 * In case 2, the client has a stale copy of the server data, which has
 * not been modified locally.  This is a client-catchup-needed.
 * 
 * In case 3, the client has made a modification based upon fresh server
 * data, and this is different from the server.  This is a 
 * client-push-needed.
 * 
 * In case 4, the client has fresh server data with no updates made.
 * This is a no-change
 * 
 * The merge actions are:
 * <code>
 * Case									   Resolution
 * 0 update-stale-data-diverge-server		M, report that N was rejected.
 * 1	 update-stale-data-converge-server  M.
 * 2 client-catchup-needed					M.
 * 3 client-push-needed						N.
 * 4 no-change								B.
 * </code>
 */
public class Model {
	private List<Project> newModel;
	private List<Project> baseModel;
	private List<Project> masterModel;
	private List<String>  resolveList;
	private boolean dataValid;
	enum State { Init, LoadedClientData, LoadedMasterData, ResolvedData };
	State currentState;

	public Model() {
		newModel = new ArrayList<Project>();
		baseModel = new ArrayList<Project>();
		masterModel = new ArrayList<Project>();
		currentState = State.Init;
	}
	
	public boolean uploadData(JsonElement nextPushJson, JsonElement lastFetchJson) {
		JsonArray projectNextArray = null;
		JsonArray projectBaseArray = null;
		
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
				Project p = new Project(e);
				if (p != null) {
					newModel.add(p);
				}
			}

			while (pbaItr.hasNext()) {
				JsonObject e = pbaItr.next().getAsJsonObject();
				Project p = new Project(e);
				if (p != null) {
					baseModel.add(p);
				}
			}
		} catch (ProjectCreateException cpe) {
			System.out.println("Could not create project data cpe: " + cpe);
			return false;
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
	
	public Project fetchProject(String aProjectOwnerEmail, String aSecurityToken) {
		Project project = null;
		EntityManager em = null;
		try {
			em = SingletonEntityManager.get().createEntityManager();
			project = (Project) em.createQuery(
					"select p from project p" +
					" where p.projectOwnerEmail=:supplied_email" +
					" and p.securityToken=:supplied_securityToken")
					.setParameter("supplied_email", aProjectOwnerEmail)
					.setParameter("supplied_securityToken", aSecurityToken)
					.getSingleResult();
		} finally {
			em.close();
		}
		return project;
	}
	
	public boolean loadMasterData() {
		if (currentState != State.LoadedClientData) {
			return false;
		}
		
		Iterator<Project>projItr = newModel.iterator();
		while (projItr.hasNext()) {
			Project p = projItr.next();
			String securityToken = p.getSecurityToken();
			String projectOwnerEmail = p.getProjectOwnerEmail();
			Project masterProject = fetchProject(projectOwnerEmail, securityToken);
			if (null != masterProject) {
				masterModel.add(masterProject);
			} else {
				System.out.println("new Model has project not seen before " + projectOwnerEmail + " " + securityToken);
			}
		}
		currentState = State.LoadedMasterData;
		return true;
	}
	
	/*
	 * * CASE 0 B!=M, B!=N, N!=M
 * CASE 1 B!=M, B!=N, N==M
 * CASE 2 B!=M, B==N, N!=M
 * CASE 3 B==M, B!=N, N!=M
 * CASE 4 B==M, B==N, N==M
 * 
	 */
	public void threeWayResolve(String baseItem, String newItem, String masterItem, ResolveCallback callback) {
		
	}
	public boolean resolveModel() {
		if (currentState != State.LoadedMasterData) {
			return false;
		}		
		
		currentState = State.ResolvedData;
		return true;
	}
}
