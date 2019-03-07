# PLAN

* Home Pages
- Landing page -- initial redirect
- Dashboard -- root
- Mission Statement

* Blog -- admin thing
- index
- show -- shows full comments
- new
- create
- edit
- update
- delete

* Blog Comments -- user thing
- new
- create

* Archive
- index
- show
- new -- redirect_to proposal unless admin
- create 
- edit -- redirect_to proposal unless admin
- update
- destroy -- redirect_to proposal unless admin

* Archive Proposal -- for non-admins
- index
- show -- all cersions expandable
- new
- create
- edit -- tracks history
- update
- delete

* Users
- index
- show
- new
- create
- edit
- update
- delete

* Posts -- 'Forum'
- index
- show -- all versions expandable
- new
- create
- edit -- tracks history
- update
- delete