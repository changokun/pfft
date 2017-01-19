<cfcomponent extends="base">

	<cffunction name="get_default_local_sites" access="package"  hint="i return fakey site objects that are for use on local machines or what not.">
		<!--- there is always a special default site for the install mechanisms. --->
		<cfset var ret = []>
		<cfset arrayAppend(ret, createObject('component', 'site').init(
			canonical_domain_name = 'localhost',
			web_root = "#application.config.pfft_root#services/install/",
			comment = 'This is the default for your local development machine: it will show the site installer (which you are probably looking at right now).',
			sys_name = 'localghost'
		))>
		<cfreturn ret>
	</cffunction>

	<cffunction name="make_virtual_host_entry_for_site">
		<cfargument name="site" type="site" required="true">
		<cfset var VirtualHost = structNew('ordered')>
		<cfset var ret = []>
		<cfset var ip = '*'>
		<cfset var port = 80>
		<cfset var key = ''>
		<cfset var aliases = ''>
		<cfset var server_name = ''>
		<cfset var directory_key = ''>

		<cfset VirtualHost['ServerName'] = site.canonical_domain_name>
		<cfset VirtualHost['DocumentRoot'] = site.web_root>
		<cfset VirtualHost['ServerName'] = reReplace(site.canonical_domain_name, '\.\w{2,7}$', '.dev')>
		<cfset VirtualHost['FallbackResource'] = 'router.cfm'>
		<cfset VirtualHost['ErrorLog'] = site.web_root & 'local-apache-error-log'>
		<cfset VirtualHost['CustomLog'] = site.web_root & 'local-apache-access-log vhost_common'>
		<cfset VirtualHost['Directory'] = {}>
		<cfset VirtualHost.Directory['location'] = site.web_root>
		<cfset VirtualHost.Directory['Require'] = 'all granted'>

		<!--- render that much --->
		<cfset arrayAppend(ret, this.render_VirtualHost(VirtualHost=VirtualHost, ip=ip, port=port, comment=site.comment))>

		<!--- start fresh for aliases --->
		<cfif arrayLen(site.alias_domain_names)>
			<cfset aliases = site.alias_domain_names>
			<cfset server_name = aliases[1]>
			<cfset arrayDeleteAt(aliases, 1)>
			<cfset VirtualHost = structNew('ordered')>
			<cfset VirtualHost['ServerName'] = reReplace(server_name, '\.\w{2,7}$', '.dev')>
			<cfif arrayLen(aliases)>
				<cfset VirtualHost['ServerAlias'] = #reReplace(arrayToList(aliases, ' '), '\.\w{2,7}\b', '.dev', 'all')#>
			</cfif>
			<cfset VirtualHost['Redirect'] = '"/" "http://#reReplace(site.canonical_domain_name, '\.\w{2,7}$', '.dev')#"'>

			<cfset arrayAppend(ret, this.render_VirtualHost(VirtualHost=VirtualHost, ip=ip, port=port))>
		</cfif>


		<cfreturn arrayToList(ret, chr(10)) & chr(10)>
	</cffunction>

	<cffunction name="render_VirtualHost" access="package" output="true">
		<cfargument name="VirtualHost" required="true">
		<cfargument name="ip" required="false" default="*">
		<cfargument name="port" required="false" default="80" hint="or 443 if you are doin ssl.">
		<cfargument name="comment" required="false" default="">

		<cfset var ret = []>

		<cfif len(arguments.comment)>
			<cfset arrayAppend(ret, '## #arguments.comment#')>
		</cfif>

		<cfset arrayAppend(ret, '<VirtualHost #arguments.ip#:#arguments.port#>')>
		<cfloop collection="#arguments.VirtualHost#" item="key">
			<cfif isSimpleValue(arguments.VirtualHost[key])>
				<cfset arrayAppend(ret, chr(9) & key & ' ' & arguments.VirtualHost[key])>
			<cfelse>
				<!--- directory, probably --->
				<cfif structKeyExists(arguments.VirtualHost[key], 'location')>
					<cfset arrayAppend(ret, '#chr(9)#<Directory "#arguments.VirtualHost[key].location#">')><!--- quotes because some early folders may have spaces in them --->
					<cfloop collection="#arguments.VirtualHost[key]#" item="directory_key">
						<cfif directory_key neq 'location'>
							<cfset arrayAppend(ret, chr(9) & chr(9) & directory_key & ' ' & arguments.VirtualHost[key][directory_key])>
						</cfif>
					</cfloop>
					<cfset arrayAppend(ret, '#chr(9)#</Directory>')><!--- quotes because some early folders may have spaces in them --->
				</cfif>
			</cfif>
		</cfloop>
		<cfset arrayAppend(ret, '</VirtualHost>')>
		<cfreturn arrayToList(ret, chr(10))>
	</cffunction>

	<cffunction name="install_all" access="public" output="true">
		<cfset var site = ''>
		<cfset var folder_name = ''>
		<cfset var temp = ''>
		<!--- this flavor of apache is not used in production. so install all means --->
		<!--- make vhosts (but I don't feel like making it and then trying to write it to the right place yet. so this will be an optional step.) --->
		<!--- review sites - make sure folders exist. that's really it. --->

		<dl>
			<cfloop array="#this.sites#" index="site">
				<cfsavecontent variable="dd">
					<cfif not directoryExists(site.web_root)>
						Creating #site.web_root#<br>
						<cfdirectory action="create" directory="#site.web_root#" recurse="true" mode="0755" />
					</cfif>
					<!--- for now, make sure the following folders exist above the doc root --->
					<cfloop list="com,includes,pages" index="folder_name">
						<cfset temp = left(site.web_root, len(site.web_root) - 4) & folder_name & '/'>
						<cfif not directoryExists(temp)>
							Creating #temp#<br>
							<cfdirectory action="create" directory="#temp#" recurse="true" mode="0755" />
						</cfif>
					</cfloop>
					<!--- make sure that the router.cfm exists. --->
					<cfset temp = site.web_root & 'router.cfm'>
					<cfif not fileExists(temp)>
						Creating #temp#<br>
						<cfset fileWrite(temp, '<h3 style="color:olive">ROUTER</h3>', 'utf-8')>
					</cfif>
				</cfsavecontent>

				<cfif not len(trim(dd))>
					<dt>#site.name# <span style="color:olive">OK</span></dt>
				<cfelse>
					<dt>#site.name#</dt>
					<dd>#dd#</dd>
				</cfif>
			</cfloop>
		</dl>

		<p>That is it really. You will need to manually update your <a href="?get_vhosts=1">vhosts</a> and your <a href="?get_hosts_file_entries=1">hosts</a>.<p>
	</cffunction>

	<cffunction name="make_vhosts_file_content" access="public" output="true">
		<!--- check that we are on local server? --->
		<cfset content = '## Generated by #getMetaData(this).fullName# for #server.machineName# on #dateFormat(now(), 'full')##chr(10)##chr(10)#'>
		<cfset site = ''>
		<cfloop array="#this.sites#" index="site">
			<cfset content &= this.make_virtual_host_entry_for_site(site) & chr(10)>
		</cfloop>
		<cfreturn content>
	</cffunction>

<!--- cfscript>
	public void function establish_vhosts_files() {
		// this is for ubuntu apache 2.4s that use a sites-available type of thing.
		var site = '';
		var aliases = '';
		var file_content = '';
		var server_name = '';

		if( ! structKeyExists(application.config.web_server_config, 'sites_available_folder')) {
			throw "need sites_available_folder config.";
		}

		for(site in this.sites) {
			writeOutput(site.name & '<code>#application.config.web_server_config.sites_available_folder##site.sys_name#.conf</code><br><xmp>');
			file_content = '## Generated on #server.machineName# #dateFormat(now(), 'full')# at #timeFormat(now(), 'full')#
<VirtualHost *:80>
	ServerName #site.canonical_domain_name#
	DocumentRoot #application.config.pfft_root#sites/#site.sys_name#/www/
	ErrorLog ${APACHE_LOG_DIR}/#site.sys_name#-error.log
	CustomLog ${APACHE_LOG_DIR}/#site.sys_name#-access.log vhost_combined
	<Directory #application.config.pfft_root#sites/#site.sys_name#/www/ >';
	if(site.hosting_mode eq 'demonstration' or application.mode eq 'staging') {
		file_content &= '
		AuthType Basic
		AuthName "Restricted Demonstration"
		AuthUserFile "#application.config.web_server_config.basic_auth_user_file#"
		Require user #application.config.web_server_config.basic_auth_login#';
	} else {
		file_content &= '
		Require all granted';
	}
	file_content &= '
	</Directory>
</VirtualHost>';
			if(arrayLen(site.alias_domain_names)) {
				aliases = site.alias_domain_names;
				server_name = aliases[1];
				arrayDeleteAt(aliases, 1);
				file_content &= replace('
				<VirtualHost *:80>
					ServerName #server_name#
					', '				', '', 'all');
					if(arrayLen(aliases)) {
						file_content &= 'ServerAlias #arrayToList(aliases, ' ')#';
					}
					file_content &= replace('
						Redirect "/" "http://#site.canonical_domain_name#"
					</VirtualHost>
				', '					', '', 'all');
			}
			writeOutput(trim(file_content));
			writeOutput('</xmp><br><br>');
		}
		return;
	}
	
	

									', '									', '', 'all');
								}
							}
						}
						break;

						default:
						output = 'not yet developed for your machine. see #getCurrentTemplate()#';
						break;
					}
					output &= '#chr(10)### ';
					return output;
				}






			}

			</cfscript>

--->
</cfcomponent>
