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
import javax.servlet.http.*;

import com.google.gson.*;

@SuppressWarnings("serial")
public class SprintOverflowServlet extends HttpServlet {
	
	private static Gson theGson = new Gson();
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		resp.setContentType("application/json");
		
		String modeValue = req.getParameter(Request.Mode.toString());
		String versionOfClient = req.getParameter(Request.Version.toString());
		
		if (modeValue != null) {
			handleModeQuery(modeValue, req, resp);
		} else if (versionOfClient != null) {
			handleVersionQuery(versionOfClient, req, resp);
		} else {
			supplyDefaultResponse(resp);
		}
	}

	private void handleVersionQuery(String versionOfClient, HttpServletRequest req,
			HttpServletResponse resp) throws IOException {
		if (versionOfClient.equals(Response.Version1_0.toString())) {
			resp.getWriter().println(theGson.toJson(Response.Version1_0));
		} else {
			resp.getWriter().println(theGson.toJson(Response.VersionNotSupported));

		}
	}

	private void handleModeQuery(String modeValue, HttpServletRequest req,
			HttpServletResponse resp) throws IOException {
		if (modeValue.equals(Request.Epic.toString())) {
			resp.getWriter().println(theGson.toJson(DefaultScenario.theDefaultScenario));
		} 
	}
	
	private void supplyDefaultResponse(HttpServletResponse resp) throws IOException {
		resp.getWriter().println(theGson.toJson(JohnSmithDemo.JohnSmith));
	}

}
