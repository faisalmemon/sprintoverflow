package com.pcc.SprintOverflow;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

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
 */
public class Model {
	private List<Project> newModel;
	private List<Project> baseModel;
	private List<Project> masterModel;
	private List<String>  resolveList;
	private boolean dataValid;

	public Model() {
		newModel = new ArrayList<Project>();
		baseModel = new ArrayList<Project>();
		masterModel = new ArrayList<Project>();
		setDataValidity(false);
	}
	
	public boolean isDataValid() {
		return dataValid;
	}
	
	private void setDataValidity(boolean setting) {
		this.dataValid = setting;
	}
	
	public boolean uploadData(JsonElement nextPushJson, JsonElement lastFetchJson) {
		JsonArray projectNextArray = null;
		JsonArray projectBaseArray = null;
		
		setDataValidity(false);
		try {
			if (nextPushJson.isJsonArray()) {
				projectNextArray = nextPushJson.getAsJsonArray();
			} else {	
				System.out.println("next push is not a json array");
				return isDataValid();
			}
			if (lastFetchJson.isJsonArray()) {
				projectBaseArray = nextPushJson.getAsJsonArray();
			} else {
				System.out.println("last fetch is not a json array");
				return isDataValid();
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
			return isDataValid();
		} catch (ClassCastException cce) {
			System.out.println("Could not create project data cce: " + cce);
			return isDataValid();
		} catch (IllegalStateException ise) {
			System.out.println("Could not create project data ise: " + ise);
			return isDataValid();
		} catch (Exception e) {
			System.out.println("Programming error: Unexpected exception e: " + e);
			return isDataValid();
		}
		
		setDataValidity(true);
		return isDataValid();
	}
	
	public boolean resolveModel() {
		if (!isDataValid()) {
			return false;
		}
		
		Iterator<Project>projItr = newModel.iterator();
		while (projItr.hasNext()) {
			Project p = projItr.next();
			String securityToken = p.getSecurityToken();
			String projectOwnerEmail = p.getProjectOwnerEmail();
		}
		return false;
	}
}
