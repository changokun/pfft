/**
*
* @file  /Users/alexbrown/Public/www/pfft/com/web_servers/site.cfc
* @author  
* @description
*
*/

component output="false" displayname="site - in the context of a web server." accessors="true"  {

	public function init(){
		this.canonical_domain_name = arguments.canonical_domain_name ?: '';
		this.alias_domain_names = arguments.alias_domain_names ?: arrayNew(1);
		this.sys_name = arguments.sys_name ?: '';
		this.design_name = arguments.design_name ?: '';
		this.id = arguments.id ?: '';
		this.hosting_mode = arguments.hosting_mode ?: '';
		this.name = arguments.name ?: '';
		this.note = arguments.note ?: '';
		this.polymorphic_id = arguments.polymorphic_id ?: '';
		this.supports_ssl = arguments.supports_ssl ?: false;
		this.enforces_ssl = arguments.enforces_ssl ?: false;
		this.type = arguments.type ?: '';
		this.created_date = arguments.created_date ?: '';
		this.expiration_date = arguments.expiration_date ?: '';

		if(not len(this.sys_name)) throw "invalid sys_name for site [#this.name#] (No. #this.id#)";
		this.web_root = application.config.pfft_root & 'sites/' & this.sys_name & '/www/';
		return this;
	}
}
