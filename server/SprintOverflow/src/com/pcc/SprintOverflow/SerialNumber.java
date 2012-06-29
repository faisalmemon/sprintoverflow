package com.pcc.SprintOverflow;

public class SerialNumber {

	private static final int AgileCollaboratorRandomStart = 872983; // arbitrary choice
	private static long serialNumber = AgileCollaboratorRandomStart;

	public synchronized static long next() {
		long result = serialNumber++;
		return result;
	}
}
