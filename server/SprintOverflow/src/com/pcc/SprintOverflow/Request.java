package com.pcc.SprintOverflow;

/**
 * Request parameters from the client
 * 
 * This class encapsulates all the different request types passed from the client.
 * 
 * The names of the enumerations cannot change due to their String equivalent being
 * used as actual protocol strings sent from the client.
 * @author faisalmemon
 *
 */
public enum Request {
	/** ?Mode=Epic or Sprint, Story, Task */
	Mode,
	Epic, Sprint, Story, Task,
	/** ?Version=2 where the supplied number is the highest protocol version understood by the client */
	Version,
}
