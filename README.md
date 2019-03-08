# PLAN

** Add smart redirects from unknown paths [and domains?]

** Add email for verification and confirmations, etc

** Change sessions to use tokens instead of ids

** Nav Bar
+ Home Pages
+ Blog
+ Archive
+ Forum
+ Users
+ Account Functions -- convert into dropdown with 'LED-style' status dot for login / remembering

** Home Pages
+ Landing page -- initial redirect
+ Dashboard -- root
+ Mission Statement

** Blog -- admin thing
		-- add motd when you learn querying 
		-- Fix the post control link sizing
+ index
+ show -- shows full comments
+ new
+ create
+ edit
+ update -- add some form of changes screen / javascript
+ delete

** Blog Comments -- user thing
- new
- create

** Archive
- index
- show
- new -- redirect_to proposal unless admin
- create 
- edit -- redirect_to proposal unless admin
- update
- destroy -- redirect_to proposal unless admin

** Archive Proposal -- for non-admins
- index
- show -- all cersions expandable
- new
- create
- edit -- tracks history
- update
- delete

** Users -- Add warning about open source and passwords
+ index
+ show
+ new
+ create -- verify over email
+ edit
+ update -- notify over email
+ delete -- confirm over email

** Posts -- 'Forum'
- index
- show -- all versions expandable
- new
- create
- edit -- tracks history
- update
- delete