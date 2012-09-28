package com.pcc.SprintOverflow;

import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;

import com.google.gson.FieldNamingPolicy;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonParser;

/**
 * SingletonManager ensures we only use shared instances of application
 * wide resources.
 * 
 * SingletonManager ensures there is only one application-wide instance
 * of
 * <ol>
 * <li>entity manager factory.
 * <li>Gson library configured for Upper Camel Case.
 * <li>JsonParser.
 * </ol>
 * 
 * Developer documentation https://developers.google.com/appengine/docs/java/datastore/jpa/overview
 * 
 * @author faisal
 */
public final class SingletonManager {
	
	/** Gson parent class.
	 * 
	 * The Gson parent class embodying the configuration of how we 
	 * want JSON serialization to work.  We specify upper camel casing
	 * which means fields like resolveList get mapped to ResolveList.
	 */
	private static final Gson theGson =  
			new GsonBuilder()
			.setFieldNamingPolicy(FieldNamingPolicy.UPPER_CAMEL_CASE)
			.create(); 
	private static final JsonParser theParser = new JsonParser();
	
	private static final EntityManagerFactory emfInstance =
			Persistence.createEntityManagerFactory("transactions-optional");
	
	
	/** Private constructor since SingletonManager is used only on a class method basis */
	private SingletonManager() {}

	public static EntityManagerFactory getEntityManagerFactory() {
		return emfInstance;
	}
	
	public static Gson getTheGson() {
		return theGson;
	}
	
	public static JsonParser getTheJsonParser() {
		return theParser;
	}
}

