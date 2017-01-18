/**
*
* @file  /Users/alexbrown/Public/www/pfft/com/web_servers/base.cfc
* @author
* @description
*
*/

component output="false" displayname="" {

	this.sites = [{
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
		hosting_mode = 'development',
		note = 'as development, only visible on office vpn. tbh, the variation in the domain name can be minted on the fly.',
		created_date = '2005-03-05',
		expiration_date = '2017-05-31',
		type = 'Corporate (Property Management Corporate Site)',
		polymorphic_id = 666
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
	}];


	public web_servers.base function get_web_server() {
		// based on config and server vars, instantiate an appropriate web_server object and return it.
		// writeDump(cgi);
		// writeDump(application.config);
		// need web_server_config
		if( ! structKeyExists(application.config, 'web_server_config')) {
			throw "no web_server_config found";
		}
		switch(application.config.web_server_config.type){
			case 'apache':
				// double check against cgi.server_software
				if(cgi.server_software does not contain application.config.web_server_config.type) {
					throw "web server config/cgi mismatch";
				}
				// and version.
				if(application.config.web_server_config.version != '2.4' or cgi.server_software does not contain application.config.web_server_config.version) {
					throw "unsupported apache version."; // this only means you should double check if any of this stuff changed in 2.5 or whatever you are using.
				}
				//okay.
				return new com.web_servers.apache24();
				break;

				default:
				throw "unsupported web server.";
				break;
			}

			return;
		}


		public function init(){
			var site = '';
			var temp = [];
			for(site in this.sites) {
				temp.append(new site(argumentCollection=site));
			}
			this.sites = temp;
			return this;
		}


		public string function get_hosts_file_entries(param) {
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


	}

