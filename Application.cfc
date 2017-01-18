<cfcomponent>

	<cfset application.instantiated_at = now()>

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


		<cffunction name="onApplicationStart" access="public" returntype="boolean" output="false" hint="Fires when the application is first created. I will load configuration and instantiate some core objects for you to use when ever you like.">

				<cfset var temp = ''>

				<cfif not structKeyExists(server, 'ini_file_path')>
					<cfthrow message="need ini file configured in that special server.cfc" />
				</cfif>
				<cfif not fileExists(server.ini_file_path)>
					<cfthrow message="need ini file to actually exist [#server.ini_file_path#]" />
				</cfif>
				<cfset temp = fileRead(server.ini_file_path)>
				<cfif not isJSON(temp)>
					<cfthrow message="need ini file to be JSON" />
				</cfif>
				<cfset temp = deserializeJSON(temp)>
				<cfif not structKeyExists(server, 'environment_name')>
					<cfthrow message="need environment_name configured in #server.ini_file_path#" />
				</cfif>
				<cfif not structKeyExists(temp, server.environment_name)>
					<cfthrow message="need server.environment_name section configured in #server.ini_file_path#" />
				</cfif>
				<cfset application['mode'] = server.environment_name>
				<cfset application['config'] = temp[server.environment_name]>
				<cfset application.config['pfft_root'] = getDirectoryFromPath(getCurrentTemplatePath())>
				<!--- the above doesn't really work, because we want the currentCOmponetFilePath, not the template path. but we will trim folders off until the last folder is pfft --->
				<cfloop condition="listLast(application.config.pfft_root, '/') neq 'pfft'">
					<cfset application.config.pfft_root = listDeleteAt(application.config.pfft_root, listLen(application.config.pfft_root, '/'), '/')>
				</cfloop>
				<!--- then put the trailing slash back on --->
				<cfset application.config.pfft_root &= '/'>
				<cfset application['started_at'] = now()>

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






	<cffunction name="onRequestEnd" returnType="void">
		<cfargument type="String" name="targetPage" required=true/>
		<cf_verbose>
			onRequestEnd runs.
		</cf_verbose>
		<cfhtmlhead text="<script>console.log('onRequestEnd');</script>">
	</cffunction>

	<cffunction name="onError">
		<cfargument name="exception" required="true" />
		<cfargument name="eventName" type="string" required="true" />

		<cfset var tag_context = ''>
		<cfset var messages = arrayNew(1)>

		<cfif structKeyExists(arguments.exception, 'tagContext')>
			<cfset tag_context = arguments.exception.tagContext>
		</cfif>

		<!--- do we step into cause? take this out if your type isn't working. --->
		<cfswitch expression="#arguments.exception.cause.type#">
			<cfcase value="illegal request">
				<!--- log what ever you want, filter and report anything you want, otherwise... --->
				<cfcontent reset="true">
				<cfheader name="X-humans" value="illegal request">
				<cfheader statuscode="400">
			</cfcase>
			<cfcase value="database">
				<!--- we should see two additional fields in the cause: sql and queryError --->
				<!--- stripping out the [driver-generated messages] --->
				<cfset arrayAppend(messages, reReplaceNoCase(arguments.exception.cause.queryError, '(\[.*\])', '<!-- \1 -->', 'all'))>
				<cfset arrayAppend(messages, arguments.exception.cause.sql)>
			</cfcase>
			<cfdefaultcase>
				<!--- i think we want to step into the cause --->
				<cfif len(arguments.exception.cause.message)>
					<cfset arrayAppend(messages, arguments.exception.cause.message)>
				</cfif>
				<cfif len(arguments.exception.cause.detail)>
					<cfset arrayAppend(messages, arguments.exception.cause.detail)>
				</cfif>

				<h1>application.onError says&hellip;</h1>
				<cfdump var="#messages#" label="messages">
				<cfdump var="#tag_context#" label="tag_context">
				<cfdump var="#arguments.exception#" label="UNCAUGHT - #arguments.exception.cause.type#" expand="false">
				what runs after this?
			</cfdefaultcase>
		</cfswitch>

	</cffunction>

	<cffunction name="onMissingTemplate" returnType="boolean">
		<cfargument type="string" name="targetPage" required=true/>
		<cfreturn BooleanValue />
	</cffunction>

	<cffunction name="onApplicationEnd">
		<cfargument name="ApplicationScope" required="true" />
		<cflog file="application_ends" type="Information" text="Application #Arguments.ApplicationScope.applicationname# Ended" >
	</cffunction>




</cfcomponent>
