Rails-Plotter
=============

Ruby on Rails application designed to plot data from a database in ten minutes. 

=Introduction
Welcome to the interactive database plotting web engine, built in Ruby on Rails. If you're reading this, then its likely you are trying to
connect this app with your database. This readme assumes you have some knowledge of Ruby on Rails. If you don't, online
resources can be great teachers. Most of what you're about to read shouldn't require much RoR insight, and the demo
should be comprehensible even for noobs (of which, I am one).

![My image](ZachDischner.github.com/Rails-Plotter/doc/Selector.png)
![My image](ZachDischner.github.com/Rails-Plotter/doc/Plotter.png)

This was built for the Laboratory for Atmospheric and Space Physics (LASP) in Boulder, Colorado.
Its AIM is to enable quick visualization of database numeric data, without spending months developing
your own custom solutions. Since LASP has a diverse scientific community, using many different database engines and schemas, I tried
to make this app as generic as I could, so that it may work for any of them. The goal is that this app will provide a
startup web server for any basic *single table* database table in under 2 hours. Most of that time will be installing
RoR dependencies. Once everything is intalled, you should be able to run the server for your database within 10 minutes,
with only minimal adjustments to the code itself.

To date (July 1 2012), I have successfully tested this app with the following databases:
* MySQL
* PostgreSQL
* SQLite
it should perform for other setups as well, but they have not been examined yet.

==Architecture
The architecture of this application is pretty simple, and there are really only 4 real pieces of code.

1.0 Selector View: An HTML page that contains selectors, tied to database information. This is where you use HTML elements
to essentially build your database query. These elements include:

* X axis variable
* Y axis variable(s)
* Different plot sets or filters (optional)
* X axis range selector using a numeric indicator (optional)
* X axis range selector using a date indicator (optional)
* Feature selector, enables different plot features aimed to help interaction

This page is found in */app/views/plots/index.html.erb*

2.0 Plot View: An HTML page that takes a data set obtained from your database, and from it renders interactive Dygraphs
plots.
This page is found in  */app/views/plots/plotter.html.erb*

3.0 Controller: Ruby file that grabs DB data necessary to construct HTML pages, and handles lots of the logic required in
that selection. Here, there are only two pages. There are two methods, one for the Selector page, and one for the Plot
page.
This file is found in */app/controllers/plots_controller.rb*

4.0 Plot Class: Ruby file that contains all the business logic of this application. The methods defined within are used
throughout the plotting process to fetch, parse, and regulate plot data.
This file is found in */app/models/plot.rb*

All files are well documented. Please review said documentation to get a better understanding of how it all works.
Logic, rendering, and selection are all kept separate as much as possible. The way its laid out now, this app should be
portable to other project platforms, such as Django.

=Setup

The best way to get started is to load up a demo and try it out.
BEWARE, The hardest thing is getting Ruby/Ruby on Rails and RoR + Databases installed and working cohesively.

==Environment
Obviously, you'll need to have Ruby, Ruby on Rails, and a Database client installed on your machine.
SQLite and MYSQL sample databases are included with this app for testing.  You *must* have MySQL installed on your
machine in order to for *>>bundle install* to work correctly.

Getting Ruby/RoR is notoriously difficult for some reason, though in practice it should be very simple.
Here is a basic tutorial:
http://eddorre.com/posts/rails-ultimate-install-guide-on-os-x-lion-using-rvm-homebrew-and-pow
I went through a similar tutorial, and searching through google got me though any problems I ran into.

This app is built using:
* Ruby 1.9.3-p125
* Rails 3.2.3
Using different versions of Ruby or Rails is known to cause some headaches. They may be easily fixed, but I've never
felt the need to try. Consider yourself warned.


I *strongly* recommend using a nice GUI to help manage everything.
RubyMine is my weapon of choice:
http://www.jetbrains.com/ruby
It is easy to use, very intelligent, and has great integration with GIT version control systems. It also has tools to
manage your versions of Ruby and Gems, which are much easier to use than trying to do it all from the Command Line. With
this program, you can easily manage which Ruby SDKs you are using and which are available, and make sure all Gems are up-to-date
and activated.

In addition, RubyMine has built in managers for data sources. It can be difficult to connect RoR to your databases, and
using this feature makes it much easier.

==Databases
Included in this package is a self contained SQLite3 table, and a script that will create a MySQL database and table.
Since required gems are dependant on local libraries, SQLite3 and MySQL will need to be installed on your machine in
order for this to work. If you really don't want to install them, you must change requirements in */config/Gemfile*.
All necessary connection gems and database configurations for these databases are included.

The SQLite3 database is self contained, and is located in */db/sqlite_test.sqlite3*, and can be connected to while using
the "sqlite_test" environment under */config/database.yml*. It is a simple and small table, where each column is a
variable which can be plotted against other columns.

The MySQL database is populated using the text-file: */CreateTestTable.txt*

To populate your MySQL database, simply run:

    >>mysql < /dir/to/application/CreateTestTable.txt

This will build a MySQL test database and table full of stock market data. An important difference between the MySQL and
the SQLite3 database is in the schema. Where the SQLite3 database just has numeric columns to plot against each-other,
the MySQL database also contains a column of strings, which will be used to filter the rows within columns to plot.
This is because for a database full of stock market stats, you will have lots of the same variables
(open, close, volume, ect) for a variety of stock market symbols. The difference may seem moot, but it really represents
a totally different approach to data fetching and plotting. The two databases together will show how this app can
handle both with ease.

Connecting the database to Rails often is difficult. Error like "database configuration does not specify adapter" pop up
even when the configurations are all correct. Fixing these errors often seems like magic. Simple restarts sometimes fixes
them. More often then not, digging through the interweb is the best way to solve these errors.

==The All Clear
First, either from the command line or using *tools/bundle/install* in RubyMine, run:
    bundle install
to install all gems required for this app. If any fail to install, it is likely an issue with your environment setup.

Basically, you'll know everything is working correctly when you can successfully run the rails console, and typing:
    Plot.first
Returns the first row in your database.
Once this works for both of the provided databases (switching between will be covered shortly), you should be good to go!

=Take it for a Test Drive
Once everything is installed correctly (a never-ending struggle), its time to try it out! I'll walk you through how to
use the app for each database. Hopefully this will illustrate how simple it will be to connect to your own database. The
RoR connection specifications for both can be found in */config/database.yml*. This is where you will put connection
information for your own database.

Normally, creating a web server designed to plot data from a database takes months to setup and lots of tweaking and
tinkering. Then, say you want to start over with an entirely different database server and a completely different table
schema. Most of the time, this requires a lot of modification to your server, if not a whole new setup. At least, this
is the case as far as I have seen.

Keeping that in mind, this app was designed to make this transition especially easy, as I will illustrate below.

==1.0 SQLite Database
This is probably as simple a schema as there will be. Each column contains a single variable, which can be plotted
against other columns. There is a *Date* type column, as well as a continuos *Index* type column. Both are defined
below, in the *Model* section. The database design and population was all performed in Rails using an SQLite database.


The first time you run this application with this database setup, you'll need to make sure the database is constructed.
Using the "sqlite_test" environment, perform a:

    >>rake db:migrate
    >>rake db:seed

This will make sure the db schema is up to date, and that it is 'seeded' with values.


This is a database built in Rails, populated in the */db/seeds.rb*. You can easily add or change the values in this
file, and update the database with:

    >>rake db:seed

Configuring the app to run a database happens in two places:

* Database Specs --> /config/database.yml
* Model          --> /app/models/plot.rb

===Database Connection
This is where you tell Rails *how* to connect to your database
This section has been filled out for you. Look at */config/database.yml* and examine the database environment:
    sqlite_test:
        adapter:  sqlite3
        database: db/sqlite_test.sqlite3
        table: plots
        pool: 5
        timeout: 5000

Everything needed should be included there, and should connect automatically to the SQLite3 database.

===Model
This class definition is where you tell Ruby how to interpret and work with database data. This really is the 'meat and
potatoes' of the plotting app. The methods and code within is what turns a connection to a database into a epic
interactive plotting experience.

In the *Database Specs* section, you told RoR *how* to connect to your database. Here, you must give a few specifics
about *what* you are connecting to.

Now, edit/examine the *Database Table Specifications* section (near the top of the file). Two subsections have
been pre-defined. Make sure the MySQL section (1.0) is all commented out, and the SQLite3 section (2.0) is uncommented.
It should look like this:
        #2.0-SQLite Testing Environment
          #establish_connection :sqlite_test                     # The connection specs in /config/database.yml
          #self.table_name   = "plots"                           # Table name defined in the "CreateTestTable.txt" script
          #@@find_filter     = false                             # Indicates that this database will require column filtering (No for unique columns)
          #@@default_x       = [""]                              # Default selection for X axis
          #@@default_y       = [""]                              # Default selection(s) for Y axis
          #@@default_filter  = [""]                              # Default selection(s) for FILTER selection
          #@@default_feature = [""]                              # Default selection for interaction FEATURE
          #@@date_name       = "DataDate"                        # Name of column containing Date values. Set to "" if you wish not to include
          #@@index_name      = "id"                              # Name of column containing some index value
          #@@filter_name     = ""                                # Name of column containing filters
          #@@exclude_tags    = ["created_at","updated_at"]       # Name of columns you don't want to be considered for plotting

The first two lines tell RoR which connection (of all listed in the */config/database.yml* file) to connect to, and which
table to use in that database connection.

The next 9 lines are optional.

* @@find_filter is an indicator, and should be set if your column relations are not unique. See *Filter Explanation* below
for a better description of this. If not set, there will be no filter applied automatically.
* @@default_* can be used when you know more about your database. They hold what you would like to be the options selected
by default in the HTML page where you choose plot options. Now, they are blank, if undefined, this program will set them
to [""] automatically.
* @@*_name gives the column name of some pertinent variables to be used in db querying and data selection. By defining
these here, you can avoid mucking around throughout the rest of the program and save some initial headaches.
* @@exclude_tags Defines database column variables that you do not want to be considered in plotting. The app will
automatically remove String type variables, but you may define other types here for convenience.

Hooray you're done! This is all that is required to tell RoR about your setup.  Run the app and check out how the server
works. You can tinker with the @@instance_variables to change default selections, and change the style of the table to
include/disregard index and date selectors.



==2.0 MySQL Stock Market Database
This is the second simplest database schema I can think of. It is what could be considered a typical table full of
stock market data. Its columns consist of market statistics, including price measurements, a *Date* type column
corresponding to each statistic measurement date, and a column full of stock tickers that match statistics and dates to
their pertinent company symbol. Inclusion of the 'ticker' column requires extra logic, as described below in the *Filter*
*Explination* section, below.

The important thing about this database, besides the fact that it has a whole new, and more complicated schema, is the
fact that it was built entirely outside of Rails. The data was gathered, processed, and parsed into SQL statements using
MATLAB. Recall, to populate the database and table, just run from a command prompt:

        >>mysql < /dir/to/application/CreateTestTable.txt

Of course, this assumes you have MySQL installed on your machine.

As with the SQLite3 database discussed above, there are only two places that you must specify DB/Table information

===Database Connection
This is where you tell Rails *how* to connect to your database
This section has been filled out for you. Look at */config/database.yml* and examine the database environment:
    development:
      adapter: mysql2
      encoding: utf8
      reconnect: false
      database: test
      pool: 5
      host: localhost
Everything needed should be included there, and Rails should be able to now connect to the MySQL database. If using
RubyMine (per my recommendation) you can look at the *Data* *Sources* window and ensure that Rails has correctly found
this database. On your machine, if you have configured differet ports or users and passwords for your MySQL server,
those changes need to be added here. Google is a great help for doing this if you don't know how to do so.



===Model
Recall, this is where the majority of all application logic is housed. In the *Database Specs* section, you told Rails
*how* to connect to your database. Here, you must give a few specifics about *what* you are connecting to.

Now, edit/examine the *Database Table Specifications* section (near the top of the file). To tell the application to
now connect to the MySQL database, ensure that the MySQL section (1.0) is all uncommented, and the SQLite3 section
(2.0) is commented out. It should look like this:

      # 1.0-MYSQL development environment
        establish_connection :development                        # The connection specs in /config/database.yml
        self.table_name   = "stock_test"                         # Table name defined in the "CreateTestTable.txt" script
        self.primary_key  = "id"                                 # Table's primary key
        @@find_filter     = true                                 # Indicates that this database will require column filtering (No for unique columns)
        @@default_x       = ["date"]                             # Default selection for X axis
        @@default_y       = ["open","close","adjclose"]          # Default selection(s) for Y axis
        @@default_filter  = ["aapl","arwr","goog","dow"]         # Default selection(s) for FILTER selection
        @@default_feature = ["Both"]                             # Default selection for interaction FEATURE
        @@date_name       = "date"                               # Name of column containing Date values. Set to "" if you wish not to include
        @@index_name      = "id"                                 # Name of column containing some index value
        @@filter_name     = "ticker"                             # Name of column containing filters
        @@exclude_tags    = ["ticker"]                           # Name of columns you don't want to be considered for plotting

Again, the first thing this section does is specify which environment to connect to, the name of the table to be used,
and the primary key used for this table. All of these specs are *required*

Most important is the next spec, *@@find_filter*. As mentioned previously, this database schema will require extra logic
to plot correctly. Setting

    @@find_filter   = true

will tell the application to treat this set of data accordingly.

The rest of the specifications are all optional. They *dont* *even* *need* *to* *be* *defined!*. This app will function
regardless. But giving it some additional insight into your database design will help extend the application to better
fit your needs.

Play around with the class variables listed above. Try commenting some out, and changing others' contents. You will
notice that some, such as the *@@default** variables, have little bearing on how everything works. Just on the user's
interaction. But removing the *@@index_name* or *@@date_name* variables, the user's interface changes, as the app no
longer knows if these items are available.

Removing the *@@find_filter* variable will have the biggest effect on the app's functionality. It still functions, but
the plots it produces are of little use.

And that's it! In case you missed it, the app just switched between to completely different database systems, using
different schemas, different variables, and different sized data sets, all in a matter of minutes. All modification of
this code happens in about 20 lines. This is true for *SQLite*, *MySQL*, and *PostgreSQL* database, and should be true
for many more systems, including NoSQL setups such as *MongoDB*





=Filter Explanation
One of the more confusing aspects of this application is the *"FILTER"* used throughout. This is used to distinguish the
two common database schemas I see this application working for. There are an infinite number of possible schemas and
designs, but for numeric setups, these are the two forms I envision the database taking on.

==Databases not requiring a 'filter'
This type of database arises when column relations are unique. I.E. one whole column can be plotted versus another whole
column as a single relation. See the envisioned schema below:

                ----------------------Plot-----------------------

                 |____x____|____y1____|____y2____|_____date_____|
                 |    1    |    1     |    1     |  Jan 1 2011  |
                 |    2    |    2     |    4     |  Jan 2 2011  |
                 |    3    |    3     |    9     |  Jan 3 2011  |
                 |    4    |    4     |    16    |  Jan 4 2011  |
                 |    5    |    5     |    25    |  Jan 5 2011  |
                 |    6    |    6     |    36    |  Jan 6 2011  |
                 |    7    |    7     |    49    |  Jan 7 2011  |
                 ...


This is the simplest type of schema. Columns represent variables that can be plotted. Each column has a unique relation
with the others.

The included *SQLite3* database has this type of setup. Use *Section 2* under *Database Table Specifications* in the file
*app/models/plot.rb* to see this type of schema in action.

==Databases requiring a 'filter'
This type of database arises when your schema has column relations that are not unique throughout the table.

For example, picture a table full of stock market data (this is why one was included). The table would contain numeric
data for various stock market symbols. Plotting one column vs another would be useless, since each column several
relations with other columns. Again, see an example schema below.

                ---------------------------Plot---------------------------

                |____ticker____|____open____|____close____|_____date_____|
                |     aapl     |    350     |    358      |  Jan 1 2011  |
                |     aapl     |    360     |    361      |  Jan 2 2011  |
                |     aapl     |    370     |    394      |  Jan 3 2011  |
                |     goog     |    668     |    665      |  Jan 1 2011  |
                |     goog     |    660     |    653      |  Jan 2 2011  |
                |     goog     |    652     |    653      |  Jan 3 2011  |
                |     goog     |    655     |    670      |  Jan 4 2011  |
                ...

If you were to try to plot either 'open' or 'close' versus 'date' (as is often done), you will end up with a conglomerate
mess of points. There are multiple relations between 'open' and 'date', for the various tickers they apply to.

If you database schema looks like this, extra logic must be employed to successfully grab and plot the data within.
Setting
    @@find_filter = true
in the *Database* *Table* *Specifications* section of *app/models/plot.rb* will tell
the app to treat the database appropriately.

For now, this logic results in a separate plot of 'open/close' versus 'date' for EACH plot ticker (filter) selected. For
a filter of 'appl', the app will grab 'open/close/date', but will _filter_ those variables to only include rows where
the 'ticker == aapl'.

Underneath the hood, each *filter* selection results in its own database query, and its own instance variable being set.

== One Last Note on the Filter
It is assumed that the 'filter' column in your database is a string. If it in fact is a numeric type, this app will require
some adjustment. I believe the filter selection will just have to be converted to a string, with a string character
concatenated to the beginning of that selection.

In the controller, each filter has its own instance variable, labeled after that filter. So a filter selection of 'aapl'
becomes @aapl. So if your selection happens to be
    params[:filter] = '1'
The controller would attempt to assign
    @1 = Plot.select_var ...
That wouldn't work. Just something to keep in mind.



=Summary

Well there you have it. Now that you've seen it in action, go connect this to your database and modify at will. Also,
check out the *Plot.rb* and *plots_controller* and *plot_template.html.erb* files, as they are well documented and
should give you a good idea of what is going on under the hood.












