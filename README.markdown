# ComatoseEngine [v0.1.0]

* Versin 0.1.0 Alpha
* Author: Polar Humenn
          extending upon the work of M@ McRay
* Website: http://github.com/polar/comatose_engine
* Email: polar humenn at gmail com

* Comatose Engine is an Engines Plugin of the popular Comatose
plugin, enhanced with associating photos with pages with
the attachment_fu plugin.

It's intended for simple CMS support. Comatose Engine supports

 * Nested pages
 * Versioning
 * Page markup in Textile, Markdown, RDoc, or easily add your own
 * Page processing through Liquid or ERb
 * Engines Ready for easy installation/migration
 * Completely self-contained within plugin folder
 * Can handle uploading images and associating with a page.

It's meant to be lean, mean, easily embedded, and easy to re-skin for
existing applications.

### Requirements:

	- RAILS VERSION 2.2.2
	- The engines plugin for Rails 2.2.2
	- ImageMagick (>6.4)
	- Several gems:
	  rmagick, if using page photos
	  rake 0.8.3

This plugin includes the following plugins in "engine_plugins", and they
are git submodules.

  * acts_as_list
  * acts_as_tree
  * pagnating_find
  * respond_to_parent

You may have to remove them if they conflict with other versions that you are
using.

### Getting ComatoseEngine Running
--------------------------------
1. From the command line

		$ rails site_name (create a rails app if you don't have one already)

2. Install the engines plugin:

		$ script/plugin install git://github.com/lazyatom/engines.git

3. Put the comatose engine plugin into plugins directory (use one of the following methods):

	* If you're not using git, and just want to add the source files:

			Download a tarball from https://github.com/polar/comatoseengine/tarball/master and unpack it into /vendor/plugins/comatose\_engine

	* Using git, make a shallow clone of the comatose_engine repository:

			$ git clone --depth 1 git://github.com/polar/comatoseengine.git vendor/plugins/comatose_engine

	* If you want to keep your comatose_engine plugin up to date using git, you'll have to add it as a submodule:

			http://www.kernel.org/pub/software/scm/git/docs/user-manual.html#submodules
			Basically:
			git submodule add git://github.com/polar/comatoseengine.git vendor/plugins/comatose_engine
			git submodule init
			git submodule update

	* Make sure you rename your CE directory to `comatose_engine` (note the underscore) if it isn't named that for some reason

4. Create your database and modify your `config/database.yml` appropriately.

5. Delete public/index.html (if you haven't already)

6. Modify your environment.rb as indicated below:

		## environment.rb should look something like this:
		RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION
		require File.join(File.dirname(__FILE__), 'boot')
		require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')

		Rails::Initializer.run do |config|
		  config.plugins = [:engines, :comatose_engine, :all]
		  config.plugin_paths += ["#{RAILS_ROOT}/vendor/plugins/comatose_engine/engine_plugins"]

		  ... Your stuff here ...
		end
		# Include your application configuration below
		require "#{RAILS_ROOT}/vendor/plugins/comatose_engine/engine_config/boot.rb"

7. Modify your routes.rb as indicated below:

		# If you want default routes from the plugin add this after any of your own
        # existing routes, but before the default rails routes:
		map.from_plugin :comatose_engine
        # Otherwise, follow the Comatose Description for routes.
        # map.resources "page_photos"
        # map.comatose_admin
        # map.comatose_root "home"

		# Install the default routes as the lowest priority.
		map.connect ':controller/:action/:id'
		map.connect ':controller/:action/:id.:format'

10. Generate the comatose engine migrations:

		$ script/generate plugin_migration

11. From the command line:

		$ rake db:migrate

12. You may need to change these lines in `application.rb` (if you're not using cookie sessions):

		# See ActionController::RequestForgeryProtection for details
		# Uncomment the :secret if you're not using the cookie session store
		protect_from_forgery # :secret => 'your_secret_string'

13. Run tests (remember, you must run `rake test` before you can run the comatose\_engine tests):

    $ rake test
		$ rake comatose_engine:test

14. Start your server and check out your site!

		$ mongrel_rails start
		or
		$ ./script/server

14, You should be able to browse to http://127.0.0.1:3000/**comatose_admin** and start adding pages to your CMS.
Browsing to http://127.0.0.1:3000/ will render your comatose pages if routing doesn't match any of your controllers.


# Optional Configuration

To override the default configuration, you configure Comatose in
your `config/environment.rb` file. Here is an example
configuration block:

    Comatose.configure do |config|
      # Sets the text in the Admin UI's title area
      config.admin_title = "Site Content"
      config.admin_sub_title = "Content for the rest of us..."
    end

TODO: Configuration Details
For now look in comatose_engine/lib/comatose/configuration.rb for details.

Since this is Comatose, your Authorization and Admin Authorization
procedures are still valid. Here's an example that uses the
`AuthenticationSystem` as generated by the
`restful_authentication` plugin:

    Comatose.configure do |config|
      # Includes AuthenticationSystem in the ComatoseController
      config.includes << :authenticated_system

      # admin
      config.admin_title = "Comatose - TESTING"
      config.admin_sub_title = "Content for the rest of us..."

      # Includes AuthenticationSystem in the ComatoseAdminController
      config.admin_includes << :authenticated_system

      # Calls :login_required as a before_filter
      config.admin_authorization = :login_required
      # Returns the author name (login, in this case) for the current user
      config.admin_get_author do
        current_user.login
      end
    end

However, now that Comatose is an Engines Plugin, you can
just mix in methods in the ComatoseController and ComatoseAdminController.

## Photo Uploading

By default ComatoseEngine uses the filesystem to store photos. Change this in
Comatose.config.page_photo.attachment_fu_options.storage. See attachment_fu
for details.

## Other notes

Any views you create in your app directory will override those in `comatose_engine/app/views`.
For example, you could create `RAILS_ROOT/app/views/layouts/application.html.haml` and have that include your own stylesheets, etc.

You can also override ComatoseEngine's controllers by creating identically-named controllers in your application's `app/controllers` directory.

### Extra Credit

This plugin includes the work of many wonderful contributors to the Railsphere.
Following are the specific libraries that are distributed with Comatose. If I've
missed someone/something please let me know.

 * [Comatose][] by [M@ McCray][]
 * [Liquid][] by [Tobias Luetke][]
 * [RedCloth][] by [_why][]
 * [Acts as Versioned][]  by [Rick Olsen][]
 * [Behaviors][] by Atomic Object LLC -- very nice BDD-like testing library
 * [Engines][] by Lazy Tom

### Feedback

Comatose Engine is released under the MIT license.

If you like it, hate it, or have some ideas for new features, let me know!

polar.humenn at gmail com

[Engines]: http://github.com/lazytom/engines
[Getting Started]: http://comatose.rubyforge.org/getting-started-guide
[Liquid]: http://home.leetsoft.com/liquid
[Tobias Luetke]: http://blog.leetsoft.com
[RedCloth]: http://whytheluckystiff.net/ruby/redcloth

Bug tracking is via [Lighthouse](http://comatoseengine.lighthouseapp.com)