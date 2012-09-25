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
 */
public class Model implements Resolver<String> {
	private List<Project> newModel;
	private List<Project> baseModel;
	private List<Project> masterModel;
	private List<String>  resolveList;
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
				// CONTINUE HERE
				// need to auto-create the project in master.
			}
		}
		currentState = State.LoadedMasterData;
		return true;
	}
	
	public boolean resolveModel() {
		if (currentState != State.LoadedMasterData) {
			return false;
		}		
		
		Iterator<Project>projItr = newModel.iterator();
		while (projItr.hasNext()) {
			Project p = projItr.next();
			
		}
		currentState = State.ResolvedData;
		return true;
	}
}
