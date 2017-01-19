<cfcomponent>

	<cfset this.sites = []>

	<cfset this.fake_data = [{
		id=123,
		name='Uno, you know, for kids',
		sys_name='uno',
		canonical_domain_name = 'www.uno.com',
		alias_domain_names = ['uno-kids.com', 'www.uno-kids.com'],
		supports_ssl = false,
		enforces_ssl = false,
		design_name = 'CBL16',
		hosting_mode = 'production',
		note = '',
		created_date = '2016-03-05',
		expiration_date = '',
		type = 'restaurant',
		polymorphic_id = 9565
	},{
		id=123,
		name='Dos, you know, for kids',
		sys_name='dos',
		canonical_domain_name = 'www.dos.com',
		alias_domain_names = ['dos-kids.com', 'www.dos-kids.com', 'www.dos-kids.ca'],
		supports_ssl = false,
		enforces_ssl = false,
		design_name = 'CBL16-urban',
		hosting_mode = 'production',
		note = 'for the design skin, lets just separate with a dash? the ui can restrict those.',
		created_date = '2015-06-01',
		expiration_date = '',
		type = 'grocer',
		polymorphic_id = 85247
	},{
		id=14223,
		name='Post Oak Plaza',
		sys_name='postoak',
		canonical_domain_name = 'www.postoak.com',
		alias_domain_names = ['postoak.com', 'www.post-oak.com', 'postoakplaza.com', 'www.post-oak-plaza.com'],
		supports_ssl = false,
		enforces_ssl = false,
		design_name = 'pwr_bravo',
		hosting_mode = 'production',
		note = 'not sure how ip restriction works (will ask martinson) but this one needs to only be shown if the request originates from the office or a specific ip of the mall wifi. hmmmmm',
		created_date = '2015-11-05',
		expiration_date = '',
		type = 'power_center',
		polymorphic_id = 1028
	},{
		id=77,
		name='Fair Hope Building',
		sys_name='fairhope',
		canonical_domain_name = 'demo.fairhope.com',
		alias_domain_names = ['demo.fair-hope.com'],
		supports_ssl = false,
		enforces_ssl = false,
		design_name = 'longs',
		hosting_mode = 'demonstration',
		note = 'as demonstration, only visible with simple http basic auth eg login: pw password: digital',
		created_date = '2005-03-05',
		expiration_date = '2017-05-31',
		type = 'Corporate (Property Management Corporate Site)',
		polymorphic_id = 666
	},{
		id=77,
		name='Fair Hope Building',
		sys_name='fairhope',
		canonical_domain_name = 'www.fairhope.com',
		alias_domain_names = ['fairhope.com', 'fair-hope.com', 'www.fair-hope.com'],
		supports_ssl = false,
		enforces_ssl = false,
		design_name = 'cameron',
		hosting_mode = 'production',
		note = 'as production, must have canonical_domain_name and will be unrestricted.',
		created_date = '2005-03-05',
		expiration_date = '',
		type = 'Corporate (Property Management Corporate Site)',
		polymorphic_id = 666
	},{
		id=744,
		name='Acadiana Mall',
		sys_name='acadiana',
		canonical_domain_name = 'www.acadiana-mall.com',
		alias_domain_names = ['acadiana-mall.com'],
		supports_ssl = true,
		enforces_ssl = false,
		design_name = 'CBL16',
		hosting_mode = 'production',
		note = '',
		created_date = '2008-03-05',
		expiration_date = '',
		type = 'mall',
		polymorphic_id = 7210
	},{
		id=477,
		name='Westfield Commons',
		sys_name='westfieldcommons',
		canonical_domain_name = 'www.westfield.com',
		alias_domain_names = ['westfield.com'],
		supports_ssl = false,
		enforces_ssl = false,
		design_name = '',
		hosting_mode = '',
		note = 'This is a website we do not host, but need to know the url of... when I pull this data, I do not want sites that we do not host... offline? non-hosted? empty hosting_mode? We have site types listed in pcmenu such as Facebook, Loyalty Program, & Mail Only that are non-hosted',
		created_date = '2016-03-05',
		expiration_date = '',
		type = 'mall',
		polymorphic_id = 9514
	},{
		id=844,
		name='Kids Eat Free',
		sys_name='kidseatfree',
		canonical_domain_name = 'www.eatkids.com',
		alias_domain_names = ['eatkids.com'],
		supports_ssl = true,
		enforces_ssl = true,
		design_name = '',
		hosting_mode = 'production',
		note = 'how about "promotional"',
		created_date = '2016-03-05',
		expiration_date = '',
		type = 'promotional',
		polymorphic_id = 100
	}]>


	
	<cffunction name="install_all">
		<cfthrow message="someone forgot to develop a method." />
	</cffunction>


	<cffunction name="get_web_server" access="public">
		<!--- based on config and server vars, instantiate an appropriate web_server object and return it. --->
		<!--- // need web_server_config --->
		<cfif(not structKeyExists(application.config, 'web_server_config'))>
			<cfthrow message="no web_server_config found" />
		</cfif>

		<!--- on production and staging, must have basic auth config. --->
		<cfif application.mode eq 'production' or application.mode eq 'staging'>
			<cfif not structKeyExists(application.config.web_server_config, 'basic_auth_login') 
				or not structKeyExists(application.config.web_server_config, 'basic_auth_user_file')
				or not fileExists(application.config.web_server_config.basic_auth_user_file)>
				<cfthrow message="need simple basic auth login and password (etc)." />
			</cfif>
		</cfif>

		<!---  double check against cgi.server_software --->
		<cfif cgi.server_software does not contain application.config.web_server_config.type>
			<cfthrow message="web server config/cgi mismatch" />
		</cfif>

		<!---  double check version against cgi.server_software --->
		<cfif cgi.server_software does not contain application.config.web_server_config.version>
			<cfthrow message="web server version config/cgi mismatch" />
		</cfif>

		<cfswitch expression="#application.config.web_server_config.type#">
			<cfcase value="apache">
				<cfif application.config.web_server_config.version eq '2.4'>
					<!--- okay. --->
					<cfif server.os.name contains 'Ubuntu'>
						<cfreturn createObject('component', 'com.web_servers.apache24_ubuntu').init()>
					<cfelseif server.os.name contains 'OS X'>
						<cfreturn createObject('component', 'com.web_servers.apache24').init()>
					<cfelse>
						<cfthrow message="Not sure if I can help you. you are probably just like OSX, si?" />
					</cfif>
				<cfelse>
					<cfthrow message="I didnt know apache version went that high." />
				</cfif>
			</cfcase>
			<cfdefaultcase>
				<cfthrow message="unsupported web server." />
			</cfdefaultcase>
		</cfswitch>
	</cffunction>

	<cffunction name="init" access="package">
		<!--- load all sites information from the api --->
		<!--- for dev servers, ignore demo sites. for production servers ignore dev sites? --->
		<!--- also get server defautl sites. --->
		<cfset var args = ''>
		<cfset var temp = []>

		<!--- the default local sites have to go first (this is so for apache.) --->
		<cfloop array="#this.get_default_local_sites()#" index="site">
			<cfset arrayAppend(this.sites, site)>
		</cfloop>
		<cfdump var="#this.sites#" label="Line 192 of /Users/alexbrown/Public/www/pfft/com/web_servers/base.cfc">
		<cfloop array="#this.fake_data#" index="args">
			<cfif args.hosting_mode neq 'demonstration'>
				<cfset arrayAppend(this.sites, createObject('component', 'site').init(argumentCollection=args))>
			</cfif>
		</cfloop>
		<cfreturn this>
	</cffunction>




<!--- 		public string function get_hosts_file_entries(param) {
			// this would only ever be used on local machines - .dev and then maybe if we know devel version of a site is on same url but diff ip/server. like we did with fce16
			// but we aren't making these changes for you, just providing them for you to paste in.
			// if you don't like using .dev, make a switch based on machine name.
			var output = '## Generated for #server.machineName# on #dateFormat(now(), 'full')##chr(10)#';
			var site = '';

			for(site in this.sites) {
				if(listFind('production,development,demonstration', site.hosting_mode)) {
					output &= '127.0.0.1 #reReplace(site.canonical_domain_name, '\.\w{2,7}$', '.dev')# #reReplace(arrayToList(site.alias_domain_names, ' '), '\.\w{2,7}\b', '.dev', 'all')##chr(10)#';
				}
			}
			return output;
		}


	} --->

</cfcomponent>
