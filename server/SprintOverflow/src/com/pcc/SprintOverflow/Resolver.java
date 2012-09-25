package com.pcc.SprintOverflow;

import java.util.List;

/*
 * Generic interface to model the resolving of data between a client
 * and a server.
 * 
 * This interface is based upon merging semantics.  From the client 
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
 * The merge action resolution results in M now representing the new
 * canonical state of the system.  M is resolved to become:
 * <code>
 * 0 updateStaleDataDivergeServer
 * 		Resolution: M, report that N was rejected.
 * 
 * 1	 updateStaleDataConvergeServer
 * 		Resolution: M.
 * 
 * 2 clientCatchupNeeded	
 * 		Resolution: M.
 * 
 * 3 clientPushNeeded
 * 		Resolution: N.
 * 
 * 4 noChange
 * 		Resolution: B.
 * </code>
 *
 */
public interface Resolver<T> {
	enum Situation {
		updateStaleDataDivergeServer,
		updateStaleDataConvergeServer,
		clientCatchupNeeded,
		clientPushNeeded,
		noChange
	};
	
	/**
	 * Resolve the actual change based upon the supplied items.
	 * 
	 * Using the merging semantics described @see Resolver<T> update
	 * masterItem to set the actual change desired, and update the record
	 * of resolution actions.
	 * 
	 * @param baseItem used for "BASE MODEL"; never modified by this function
	 * @param newItem used for "NEW MODEL"; never modified by this function
	 * @param masterItem used for "MASTER MODEL"; modified by this function
	 * @param resolutionDescription used for appending human-readable explanation of
	 *                the resolve actions taken.
	 */
	public void threeWayResolve(T baseItem, T newItem, T masterItem, List<String> resolutionDescription);
}
