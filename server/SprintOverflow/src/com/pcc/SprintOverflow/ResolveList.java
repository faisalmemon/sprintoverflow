package com.pcc.SprintOverflow;
import java.util.List;
import java.util.ArrayList;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

import com.google.appengine.api.datastore.Key;
import com.google.gson.*;

@Entity
public class ResolveList {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Key key;
	
	/** @see Response.ResolveList
	 * 
	 * The resolveList here is upper camel cased by Gson to become
	 * ResolveList and this then matches with the official protocol
	 * tag ResolveList shown in Response.java
	 */
	private List<String> resolveList;
	
	/**
	 * No-arg public constructor as required by the Java Persistence API.
	 */
	public ResolveList() {
		resolveList = new ArrayList<String>();
	}
	
	public ResolveList(String singleResolution) {
		resolveList = new ArrayList<String>();
		addResolution(singleResolution);
	}
	
	public void addResolution(String resolution) {
		resolveList.add(resolution);
	}
}
