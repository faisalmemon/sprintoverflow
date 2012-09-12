package com.pcc.SprintOverflow;

import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;

/**
 * SingletonEntityManager ensures we only use one create entity manager factory.
 * 
 * Developer documentation https://developers.google.com/appengine/docs/java/datastore/jpa/overview
 * 
 * @author faisal
 */
public final class SingletonEntityManager {
	private static final EntityManagerFactory emfInstance =
			Persistence.createEntityManagerFactory("transactions-optional");

	private SingletonEntityManager() {}

	public static EntityManagerFactory get() {
		return emfInstance;
	}
}

