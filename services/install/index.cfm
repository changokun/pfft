

services - install local websites.


<cfdump var="#application#" label="Line 3 of /Users/alexbrown/Public/www/pfft/services/install/index.cfm" expand="false">
<cfset web_server = createObject('component', 'com.web_servers.base').get_web_server()>

<cfdump var="#web_server#" label="Line 7 of /Users/alexbrown/Public/www/pfft/services/install/index.cfm" expand="false">

<cfoutput>

<h3>VirtualHosts</h3>

<!--- we might make one file or a hundred. --->
<cfif structKeyExists(application.config.web_server_config, 'sites_available_folder')>
	<!--- for each site, make sure a vhostsst file exists in sites-available. we'll enable/disable later. --->
	<cfset web_server.establish_vhosts_files()>
<cfelseif structKeyExists(application.config.web_server_config, 'vhosts_file_path')>
	<textarea cols="100" rows="20">#web_server.get_local_vhosts()#</textarea>
<cfelse>
	<p class="error">We cannot make VirtualHosts without vhosts config.</p>
</cfif>

<hr>
	<xmp>
validate:
<cfexecute name="#listFirst(application.config.web_server_config.config_validation_cmd, ' ')#" arguments="#replace(application.config.web_server_config.config_validation_cmd, listFirst(application.config.web_server_config.config_validation_cmd, ' ') & ' ', '')#" timeout="30" />
restart (disabled. needs sudo?): #listFirst(application.config.web_server_config.restart_cmd, ' ')# #replace(application.config.web_server_config.restart_cmd, listFirst(application.config.web_server_config.restart_cmd, ' ') & ' ', '')#
<!--- <cfexecute name="#listFirst(application.config.web_server_config.restart_cmd, ' ')#" arguments="#replace(application.config.web_server_config.restart_cmd, listFirst(application.config.web_server_config.restart_cmd, ' ') & ' ', '')#" timeout="30" />: --->
	</xmp>

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

	<cfif application.mode neq 'production'>
	<hr>
	<p>Hosts file entries</p>
	<textarea cols="100" rows="20">#web_server.get_hosts_file_entries()#</textarea>



	<hr>
	<p>Review each entry: look to make sure folders exist for hosted sites, suggest cleanup of non-hosted folders.</p>
	<ul>
	<cfloop array="#web_server.sites#" index="site">
		<li>#site.name# - #site.hosting_mode#
			<!--- we only add folders on development servers, which really means local hosts or mayyybe staging. --->
			<cfif server.environment_name eq 'development'>
				<cfif listFind('development,demonstration,production', site.hosting_mode)>
					oh, let's check it out: #site.web_root#<br>
					<cfif not directoryExists(site.web_root)>
						dir does not exist. creating. shrug.<br>
						<cfdirectory action="create" directory="#site.web_root#" recurse="true" mode="0755" />
						would you like me to add our site files and folders?
					</cfif>
				<cfelse>
					I don't care about #(len(site.hosting_mode) ? site.hosting_mode : 'such')# sites.
				</cfif>
			</cfif>
		</li>
	</cfloop>
	</cfif>
</ul>
</cfoutput>
