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
import java.util.AbstractMap;
import java.util.Collection;
import java.util.LinkedHashMap;

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
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		resp.setContentType("application/json"); // application/x-www-form-urlencoded
		//resp.setContentType("application/x-www-form-urlencoded");
		resp.setCharacterEncoding("UTF-8");
		
		String jsonValue = req.getParameter(Request.Json.toString());
		if (jsonValue != null) {
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
	
	private void handleJsonPost(String jsonValue, HttpServletRequest req,
			HttpServletResponse resp) throws IOException {
		String returnString = null;		
		JsonElement nextPush = JsonNull.INSTANCE;
		JsonElement lastFetch = JsonNull.INSTANCE;
		try {
			JsonObject jsonObject = SingletonManager.getTheJsonParser().parse(jsonValue).getAsJsonObject();
			nextPush = jsonObject.get(Request.NextPush.toString());
			lastFetch = jsonObject.get(Request.LastFetch.toString());
		} catch (ClassCastException cce) {
			System.out.println("CCE Error handling Json post, given "
					+ jsonValue + " generated exception " 
					+ cce.toString());
		} catch (NullPointerException npe) {
			System.out.println("NPE Error handling Json post, given "
					+ jsonValue + " generated exception " 
					+ npe.toString());
		} catch (Exception e) {
			System.out.println("Exception Error handling Json post, given "
					+ jsonValue + " generated exception " 
					+ e.toString());
		}

		Model model = new Model();
		boolean result;
		result = model.resolveClientData(nextPush, lastFetch);		
		System.out.println("model processed with result " + result);
		if (!result) {
			returnString = SingletonManager.getTheGson().toJson(new ResolveList("Error in nextPush or lastFetch data"));
			resp.getWriter().println(returnString);
			return;
		}
		returnString = model.getUpdatedMasterAsJsonString();
		resp.getWriter().println(returnString);
		System.out.println("Supplying the client with the data " + returnString);
		return;
	}
	private void supplyDefaultResponse(HttpServletResponse resp) throws IOException {
		String returnString = SingletonManager.getTheGson().toJson(new ResolveList("Error in client data"));
		resp.getWriter().println(returnString);
	}

}
