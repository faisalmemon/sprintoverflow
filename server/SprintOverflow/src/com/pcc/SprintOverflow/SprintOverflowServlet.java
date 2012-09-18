/**
 * Copyright Faisal Memon 2012.  All rights reserved. 
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 * FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package com.pcc.SprintOverflow;

import java.io.IOException;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.servlet.ServletException;
import javax.servlet.http.*;

import com.google.gson.*;

/**
 * Main protocol handler class for SprintOverflow project.
 * 
 * This class is the point of service for iOS clients wishing to
 * get updates from the server on the current state of a given project.
 * 
 * It implements the client-server protocol {@link com.pcc.SprintOverflow}
 * @author faisal
 *
 */
@SuppressWarnings("serial")
public class SprintOverflowServlet extends HttpServlet {
	
	private static Gson theGson = new Gson();
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		resp.setContentType("application/json");
		
		String modeValue = req.getParameter(Request.Mode.toString());
		String jsonValue = req.getParameter(Request.Json.toString());
		
		if (modeValue != null) {
			handleModeQuery(modeValue, req, resp);
		} else if (jsonValue != null) {
			handleJsonPost(jsonValue, req, resp);
		} else {
			supplyDefaultResponse(resp);
		}
	}
	
	public void doPost(HttpServletRequest request,
			HttpServletResponse response)
					throws ServletException, IOException {
		doGet(request, response);
	}

	private void handleModeQuery(String modeValue, HttpServletRequest req,
			HttpServletResponse resp) throws IOException {
		String returnString;
		
		if (modeValue.equals(Request.Epic.toString())) {
			returnString = theGson.toJson(DefaultScenario.theDefaultScenario);
			resp.getWriter().println(returnString);
		} else if (modeValue.equals(Request.CreateProject.toString())) {
			String owner = req.getParameter(Request.ProjectOwnerEmail.toString());
			String id = req.getParameter(Request.ProjectId.toString());
			String token = req.getParameter(Request.SecurityToken.toString());
			EntityManager em = SingletonEntityManager.get().createEntityManager();
			Project project = new Project(owner, id, token);
			try {
				em.persist(project);
				returnString = theGson.toJson(project);
				resp.getWriter().println(returnString);
			} finally {
				em.close();
			}		
		} else if (modeValue.equals(Request.Version.toString())) {
			String version = req.getParameter(Request.ClientVersion.toString());
			if (version.equals(Response.Version1_0.toString())) {
				returnString = theGson.toJson(Response.Version1_0);
				resp.getWriter().println(returnString);
			} else {
				returnString = theGson.toJson(Response.VersionNotSupported);
				resp.getWriter().println(returnString);
			}
		} else if (modeValue.equals(Request.PostTest.toString())) {
			returnString = "GoodPostTest";
			resp.getWriter().println(returnString);
		}
	}
	
	private void handleJsonPost(String jsonValue, HttpServletRequest req,
			HttpServletResponse resp) throws IOException {
		String returnString;
		/*
		need to do something like
		http://code.google.com/p/google-gson/source/browse/trunk/extras/src/main/java/com/google/gson/extras/examples/rawcollections/RawCollectionsExample.java
		to get the passed in string into a proper data structure
		which we can process
		*/
		returnString = theGson.toJson(DefaultScenario.theDefaultScenario);
		resp.getWriter().println(returnString);
	}
	private void supplyDefaultResponse(HttpServletResponse resp) throws IOException {
		String returnString = theGson.toJson(JohnSmithDemo.JohnSmith);
		resp.getWriter().println(returnString);
	}

}
