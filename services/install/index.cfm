<cfdump var="#application#" label="Line 3 of /Users/alexbrown/Public/www/pfft/services/install/index.cfm" expand="false">
<cfdump var="#server#" label="Line 7 of /Users/alexbrown/Public/www/pfft/services/install/index.cfm" expand="false">
<cfset web_server = createObject('component', 'com.web_servers.base').get_web_server()>
<cfdump var="#web_server#" label="Line 7 of /Users/alexbrown/Public/www/pfft/services/install/index.cfm" expand="false">

<cfoutput>

	<!--- some minimal scriptiness --->
	<cfif structKeyExists(url, 'get_vhosts')>
		<!--- this link appears when apache is configured to use one hosts file, usually a local machine. --->
		<cfset output = web_server.make_vhosts_file_content()>
		<cfcontent type="text/plain" reset="true">
		<cfoutput>#output#</cfoutput>
	<cfelseif structKeyExists(url, 'get_hosts_file_entries')>
		<!--- this link appears when apache is configured to use one hosts file, usually a local machine. --->
		<cfset output = web_server.get_hosts_file_entries()>
		<cfcontent type="text/plain" reset="true">
		<cfoutput>#output#</cfoutput>
	<cfelse>

		<h1>Installs</h1>

		idempotently install all sites. this means diff things on diff apaches. establish vhosts, enable as nec. restart server.
		<cfset web_server.install_all()>
		<!--- we might make one file or a hundred. --->
		<cfif structKeyExists(application.config.web_server_config, 'sites_available_folder')>
			<!--- for each site, make sure a vhostsst file exists in sites-available. we'll enable/disable later. --->
			<cfset web_server.establish_vhosts_files()>
		<cfelse>
			<p class="error">We cannot make VirtualHosts without vhosts config.</p>
		</cfif>


		<hr>
		validate:
		<xmp><cfexecute name="#listFirst(application.config.web_server_config.config_validation_cmd, ' ')#" arguments="#replace(application.config.web_server_config.config_validation_cmd, listFirst(application.config.web_server_config.config_validation_cmd, ' ') & ' ', '')#" timeout="30" /></xmp>
		<hr>
		restart (disabled. needs sudo?): #listFirst(application.config.web_server_config.restart_cmd, ' ')# #replace(application.config.web_server_config.restart_cmd, listFirst(application.config.web_server_config.restart_cmd, ' ') & ' ', '')#
	<!--- <cfexecute name="#listFirst(application.config.web_server_config.restart_cmd, ' ')#" arguments="#replace(application.config.web_server_config.restart_cmd, listFirst(application.config.web_server_config.restart_cmd, ' ') & ' ', '')#" timeout="30" />: --->

		<h4>on production? on ubuntu?, we will take stock of what configs exist, and compare that to our data. we will suggest removing configs that do not belong, and we will create any that are missing (enabling may or may not occur.</h4>
		<cfif application.mode eq 'production' or application.mode eq 'staging?/development?'>
			<cfdirectory action="list" directory="#application.config.web_server_config.sites_available_folder#" name="existing_files" type="file" />
			<cfdump var="#existing_files#">
			so.... loop over each.
			<cfset unmatched_files = []>
			
			<cfloop query="existing_files">
				<cfset file_was_matched = false>
				<cfloop array="#web_server.sites#" index="site">
					<cfif name eq site.sys_name & '.conf'>
						<cfset site.conf_file_existed = true>
						<cfset file_was_matched = true>
						<cfbreak>
					</cfif>
				</cfloop>
				<cfif not file_was_matched>
					<cfset arrayAppend(unmatched_files, name)>
				</cfif>
			</cfloop>

			<cfloop array="#web_server.sites#" index="site">
				<cfif structKeyExists(site, 'file_was_matched')>
					<p>This site was matched. validate that the contents match?</p>
				<cfelse>
					<p>This site's config file is missing. Let's make #application.config.web_server_config.sites_available_folder##site.sys_name#.conf</p>
				</cfif>
			</cfloop>


			<cfdump var="#unmatched_files#" label="unmatched_files"/>
		</cfif>


	</cfif>
</cfoutput>
