<cfcomponent>

	<cfset this.instantiated_at = now()>

	<cfoutput>
		<h2>#getCurrentTemplatePath()#</h2>
	</cfoutput>

		<!--- Set up the application. --->
		<cfset this.Name = "AppCFC" />
		<cfset this.ApplicationTimeout = CreateTimeSpan(0, 16, 0, 0) />
		<cfset this.SessionManagement = false />
		<cfset this.SetClientCookies = false />


		<!--- Define the page request properties. --->
		<cfsetting
				requesttimeout="20"
				showdebugoutput="false"
				enablecfoutputonly="false"
				/>


		<cffunction
				name="OnApplicationStart"
				access="public"
				returntype="boolean"
				output="false"
				hint="Fires when the application is first created.">

				<!--- Return out. --->
				<cfset this['pfft_root'] = getDirectoryFromPath(getCurrentTemplatePath())>
				<cfdump var="#this#" label="Line 28 of /Users/alexbrown/Public/www/pfft/Application.cfc">
				<cfdump var="#getMetaData(this)#" label="Line 28 of /Users/alexbrown/Public/www/pfft/Application.cfc">
				<cfreturn true />
		</cffunction>


		<cffunction
				name="OnSessionStart"
				access="public"
				returntype="void"
				output="false"
				hint="Fires when the session is first created.">

				<!--- Return out. --->
				<cfreturn />
		</cffunction>


		<cffunction
				name="OnRequestStart"
				access="public"
				returntype="boolean"
				output="false"
				hint="Fires at first part of page processing.">

				<!--- Define arguments. --->
				<cfargument
						name="TargetPage"
						type="string"
						required="true"
						/>

						<cfif structKeyExists(url, 'restart')>
							<cfset this.OnApplicationStart()>
						</cfif>

				<!--- Return out. --->
				<cfreturn true />
		</cffunction>


		<cffunction
				name="OnRequest"
				access="public"
				returntype="void"
				output="true"
				hint="Fires after pre page processing is complete.">

				<!--- Define arguments. --->
				<cfargument
						name="TargetPage"
						type="string"
						required="true"
						/>

				<!--- Include the requested page. --->
				<cfinclude template="#ARGUMENTS.TargetPage#" />

				<!--- Return out. --->
				<cfreturn />
		</cffunction>


		<cffunction
				name="OnRequestEnd"
				access="public"
				returntype="void"
				output="true"
				hint="Fires after the page processing is complete.">

				<!--- Return out. --->
				<cfreturn />
		</cffunction>


		<cffunction
				name="OnSessionEnd"
				access="public"
				returntype="void"
				output="false"
				hint="Fires when the session is terminated.">

				<!--- Define arguments. --->
				<cfargument
						name="SessionScope"
						type="struct"
						required="true"
						/>

				<cfargument
						name="ApplicationScope"
						type="struct"
						required="false"
						default="#StructNew()#"
						/>

				<!--- Return out. --->
				<cfreturn />
		</cffunction>


		<cffunction
				name="OnApplicationEnd"
				access="public"
				returntype="void"
				output="false"
				hint="Fires when the application is terminated.">

				<!--- Define arguments. --->
				<cfargument
						name="ApplicationScope"
						type="struct"
						required="false"
						default="#StructNew()#"
						/>

				<!--- Return out. --->
				<cfreturn />
		</cffunction>


		<cffunction
				name="OnError"
				access="public"
				returntype="void"
				output="true"
				hint="Fires when an exception occures that is not caught by a try/catch.">

				<!--- Define arguments. --->
				<cfargument
						name="Exception"
						type="any"
						required="true"
						/>

				<cfargument
						name="EventName"
						type="string"
						required="false"
						default=""
						/>

						<cfdump var="#arguments#" label="Line 173 of /Users/alexbrown/Public/www/pfft/Application.cfc">

				<!--- Return out. --->
				<cfreturn />
		</cffunction>

</cfcomponent>
