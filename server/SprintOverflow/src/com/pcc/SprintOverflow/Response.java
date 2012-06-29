package com.pcc.SprintOverflow;

/**
 * Provide response data from the server to the client.
 * 
 * This class encapsulates all the different response types passed from the server.
 * 
 * The names of the enumerations cannot change due to their String equivalent being
 * used as actual protocol strings sent to the client.
 * 
 * 
 * @author faisalmemon
 */
public enum Response {
	/** The first version supported by the server */
	Version1_0,
	/** Unsupported Version */
	VersionNotSupported;
	
}
