# README

The Canvas Seeder will populate data in your Canvas account. It will not create Modules, and SOMETHING ELSE.


# Localhost Configuration Only

This is the Configuration you will need to seed a local Canvas instance.
* Ruby version

  `>= 2.2.0`

* Configuration

  Install gem dependencies.

  Run `bundle install`

  Once all the dependencies are installed run rails migrations.

  Run `rake db:migrate`

* Services (job queues, cache servers, search engines, etc.)

  Start the server with a different port compared to your Canvas localhost.

  Run `rails s -p 3001` if you Canvas local is running on 3000, and no other local servers are running on port 3001.

  To kick off the jobs server, open a new terminal window.

  Run`rake jobs:work`


* Seeding

  You will need to create an access token in your Canvas local for the seeder to work.
  Under the Configuration, your domain will need to include the `http://` & the port.
  `http://localhost:3000`

  You will then add your token you generated from your local Canvas instance. When you are in the seeder starting a new batch, the maximum and minimum values are compounding, so do NOT choose 100 courses, with 100 students, and 100 teachers. This will take all week to run to seed.
