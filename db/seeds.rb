# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)   ]

Plot.all.each do |plot|
  plot.delete
end
Plot.create [:x =>1 ,   :y1 => -1,    :y2 => 2,  :DataDate => "2012/05/05"]
Plot.create [:x =>1.5,  :y1 => -2,    :y2 => 3,  :DataDate => "2012/05/05 12:00:00"]
Plot.create [:x =>2,    :y1 => -4,    :y2 => 4,  :DataDate => "2012/05/06"]
Plot.create [:x =>2.5,  :y1 => -16,   :y2 => 7,  :DataDate => "2012/05/06 12:00:00"]
Plot.create [:x =>3,    :y1 => -20,   :y2 => 9,  :DataDate => "2012/05/07"]
Plot.create [:x =>3.5,  :y1 => -21,   :y2 => 12, :DataDate => "2012/05/07 12:00:00"]
Plot.create [:x =>4,    :y1 => -19,   :y2 => 16, :DataDate => "2012/05/08"]
Plot.create [:x =>4.5,  :y1 => -11,   :y2 => 20, :DataDate => "2012/05/08 12:00:00"]
Plot.create [:x =>5,    :y1 => -6,    :y2 => 25, :DataDate => "2012/05/09"]
Plot.create [:x =>5.5,  :y1 => -1,    :y2 => 31, :DataDate => "2012/05/09 12:00:00"]
Plot.create [:x =>6,    :y1 => 5,     :y2 => 35, :DataDate => "2012/05/10"]
Plot.create [:x =>6.5,  :y1 => 9,     :y2 => 37, :DataDate => "2012/05/10 12:00:00"]
Plot.create [:x =>7,    :y1 => 12,    :y2 => 38, :DataDate => "2012/05/11"]
Plot.create [:x =>7.5,  :y1 => 13,    :y2 => 36, :DataDate => "2012/05/11 12:00:00"]
Plot.create [:x =>8,    :y1 => 14,    :y2 => 31, :DataDate => "2012/05/12"]
Plot.create [:x =>8.5,  :y1 => 12,    :y2 => 28, :DataDate => "2012/05/12 12:00:00"]
Plot.create [:x =>9,    :y1 => 10,    :y2 => 25, :DataDate => "2012/05/13"]
Plot.create [:x =>9.5,  :y1 => 11,    :y2 => 22, :DataDate => "2012/05/13 12:00:00"]
Plot.create [:x =>10,   :y1 => 14,    :y2 => 21, :DataDate => "2012/05/14"]
Plot.create [:x =>10.5, :y1 => 15,    :y2 => 19, :DataDate => "2012/05/14 12:00:00"]
Plot.create [:x =>11,   :y1 => 19,    :y2 => 20, :DataDate => "2012/05/15"]
Plot.create [:x =>11.5, :y1 => 21.5,  :y2 => 22, :DataDate => "2012/05/15 12:00:00"]
Plot.create [:x =>12,   :y1 => 28,    :y2 => 23, :DataDate => "2012/05/16"]
Plot.create [:x =>12.5, :y1 => 34,    :y2 => 25, :DataDate => "2012/05/16 12:00:00"]
Plot.create [:x =>13,   :y1 => 38,    :y2 => 28, :DataDate => "2012/05/17"]
Plot.create [:x =>13.5, :y1 => 37,    :y2 => 31, :DataDate => "2012/05/17 12:00:00"]
Plot.create [:x =>14,   :y1 => 36,    :y2 => 29, :DataDate => "2012/05/18"]
Plot.create [:x =>14.5, :y1 => 30,    :y2 => 33, :DataDate => "2012/05/18 12:00:00"]
Plot.create [:x =>15,   :y1 => 21,    :y2 => 39, :DataDate => "2012/05/19"]
Plot.create [:x =>15.5, :y1 => 11,    :y2 => 44, :DataDate => "2012/05/19 12:00:00"]
Plot.create [:x =>16,   :y1 => 6,     :y2 => 50, :DataDate => "2012/05/20"]
Plot.create [:x =>16.5, :y1 => 4,     :y2 => 54, :DataDate => "2012/05/20 12:00:00"]
Plot.create [:x =>17,   :y1 => 3,     :y2 => 56, :DataDate => "2012/05/21"]
Plot.create [:x =>17.5, :y1 => 2,     :y2 => 58, :DataDate => "2012/05/21 12:00:00"]
Plot.create [:x =>18,   :y1 => 1.5,   :y2 => 55, :DataDate => "2012/05/22"]
Plot.create [:x =>18.5, :y1 => 1,     :y2 => 52, :DataDate => "2012/05/22 12:00:00"]
Plot.create [:x =>19,   :y1 => 0.4,   :y2 => 53, :DataDate => "2012/05/23"]
Plot.create [:x =>19.5, :y1 => 0,     :y2 => 51, :DataDate => "2012/05/23 12:00:00"]
Plot.create [:x =>20,   :y1 => -0.6,  :y2 => 50, :DataDate => "2012/05/24"]
Plot.create [:x =>20.5, :y1 => -1,    :y2 => 48, :DataDate => "2012/05/24 12:00:00"]
Plot.create [:x =>21,   :y1 => -4,    :y2 => 44, :DataDate => "2012/05/25"]
#
#
#user = User.create :email => 'Zach@example.com', :password => 'guessit', :password_confirmation => 'guessit'
#user = User.create :email => 'Mary@example.com', :password => 'guessit', :password_confirmation => 'guessit'
#
#Category.create [
#                  {:name => 'programming'},
#                  {:name => 'Event'},
#                  {:name => 'Travel'},
#                  {:name => 'Music'},
#                  {:name => 'TV'}
#                ]
#
#user.articles.create :title => 'Advanced Active Record',
#                     :body => 'Models need to relate to eachother. In the real world...',
#                     :published_at => Date.today
#
#user.articles.create :title => '1 to Many associations',
#                     :body  => 'One-to-many associations describe a pattern...',
#                     :putlished_at => Date.today
#
#user.articles.create :title => 'Associations',
#                     :body  => 'Active Record makes working with associations easy',
#                     :published_at => Date.today
#
