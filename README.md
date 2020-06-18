# PLAN


## **PHASE ONE:** Create Architecture

- **URGENT BLOCKERS**
	- [ ] All PATCH/PUTS links are broken -- routing or view problem?

	- [ ] Change landing to use session by default to prevent accidental blocking of website
	
	- [ ] Guest users have been noticed seeing an extremely painful experience loading the site [because of constant current_user full checks (fix with use of instance variable?)]
		- Later, after restarting the server and cleaning some tests, the issue has seemingly cleared up.  The giveaway was a lack of `CACHE User Load` spam in the logs
	
	- [ ] Master key has to be set every time the environment is reset.
		Should this get a more permanent fix?



	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
	#                                                                           #
	# # REMEMBER, USE ALTERNATE POST TYPES FOR REDIRECT/LINK TESTING ONLY!!!  # #
	#                                                                           #
	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


- **New Test Suite**
	- [x] First Pass
		- Uses Factories, not Fixtures -- use this to determine necessary records for ideal test database
		- Tests for expected success and failure (triggering specific controller filters, etc)
	- [ ] Second Pass -- might make it into AnythingIsPossible
		- [ ] Existing tests could use a re-check and touch-up
		- Imagine a dynamic catch-all helper that dynamically assembles a test suite and sample data based on the parameters provided
		- Example:
			INPUT: test_link_presence(owner: user_one, default: true, trashed: false, hidden: false, owned_hidden: true)
			OUTPUT:
				user_link: pass
				user_trashed_link: fail
				user_hidden_link: pass
				other_user_link: pass
				other_user_trashed_link: fail
				other_user_hidden_link: fail
		- I see big potential for reusable CS library here,
		- would need to rely more on metaprogramming/self-generation to be portable


- [ ] **Clean up tests** - **TOTAL TIME:** 00:00:12

	**_BIG THINGS_** -Features, overhauls
	- [ ] https://github.com/paper-trail-gem/paper_trail#7-testing
	- [ ] **Add helper tests (auto-logs, etc?)**
	- [ ] **Add integration testing using Capybara**
	- [ ] **Testing groups for Guardfile(?)**

	**_Small Gripes_**
	- [ ] The trashed modifier switches after other modifiers -- Can this be patched for test log readability?
	- [ ] Change all 'blog_modifiers' and 'forum_numbers', etc to use '_post_'
	- [ ] Also, could the guests be included in loops and loads before all other users?
	- [ ] Even easier, change titles, contents, and names to use spacers in between all the keys
	- [ ] There is something wrong with the flash helpers, currently using harmless, static about page for loading/clearing flashes in cached limbo

	**_EVERYTHING ELSE_**
	- [ ] **Guardfile**
		- [x] Link controllers to controller tests
		- [x] Link models to model tests
		- [ ] Link views and controllers to integration tests
			- Need to add integration tests first
	- [ ] **Helper methods**
		- [ ] Repetetive checks on controller tests
			- User groups testing routes? (?)
	- [ ] **Test Definition**
		- [ ] Test for both PUT & PATCH where applicable
		- [ ] Test for proper comment trash/hide links where available
			- Should certain links be GET-able? (hide, trash)
		- [ ] Test for failure [redirects, flashes] upon bad CRUD requests
			- **FLASH CLEARS ARE NOT WORKING AS EXPECTED -- USE _CLEAR_FLASHES_**
		- [ ] Test for empty content placeholders when there are no records to display
		- [ ] Add complete definition for important content in views (ie headers, form inputs)
			- Do this after Vue update
		- [ ] Add specific error messages for each assertion, if possible
		- [ ] Test for redirects by [specific] controller filters
		- [ ] Test for header link tree changes
		- [ ] Test for marking recent activity after controller actions
		- [ ] Test against undesired flashes
		- [ ] Test for record-specific collection size changes during posts & deletes
		- [ ] Test for proper formatting of all model partial renders
			- [ ] Doctypes (what?)
		- [ ] Are you clearing flashes?
		- [ ] Are you building/using browser cookies/session?
		- [ ] Are you testing for forms?
		- [ ] When does a destroy failure happen
		- [ ] What's up with the association tests?
	- [ ] Notice the _dependent destroy_ tests only test destruction of expected dependencies, not all possible [unexpected] destructions


- [x] **Users (& Sessions) Update**
	- CANNED: Video Preview
	- [ ] DELAYED: NavBar User Icon
	- [ ] DELAYED: In-view bucket-switching
	- [ ] **Future Update:**
		- [ ] Add custom crop editing (javascript?)


- [ ] **Show/Hide Update** (Extras)
	- [ ] Figure out exactly who can post comments on hidden/trashed posts and whether their parents must be hidden/trashed -- List is subject to change
		- Users
			Admin - All
			User - Hidden when owned but not Trashed(Disabled)
		- Suggestions
			Admin - All -- warn for discretion (use case for special notices feature?)
			User - Hidden when owned & Trashed when owned
		- Forum
			Admin - All -- warn for discretion (use case for special notices feature?)
			User - Hidden when owned & Trashed when owned
		- Should there be a disabling option for admins?
	- [ ] Add flash+redirects when attempting to trash/hide something that already has that state
	- [ ] Change Users' 'trashed' states into 'active' and show false as deactivated
	- [ ] Features -- Add these in the next two updates
		- [ ] Change Suggestions to show/notice/dim if they match the current version
			- prevents diff glitches and otherwise confusion from manual edits
		- [ ] Change controller filters [and add notice] to warn users attempting CRUD if they are hidden/trashed
		- [ ] Trash/Hide All Action for Users (or admins)
			- Extrapolation: Think of options relative to all comments, or all forum posts
		- [ ] Page(s) showing all records and their dependencies' [and their dependencies'] current state
			- For accessing & editing with trashed/hidden parent records
			- IE: Blog Post and Comments, Archiving and Suggestion
		- [ ] Trashed and Hidden 'placeholder' screens(?)
			- Replace titles and users in affected state with placeholders
			- Trashed: image of a trash can
			- Hidden: incognito-esque icon
	- [ ] System
		- RECOMMEND ADDING A HIDDEN-STATE EQUIVALENT OF #TRASH_CANNED CONCERN METHOD
		- The new 'hidden' modifier kills the tests: now over 25000 fixtures on comments
			- It is in the process of being reworked in with a new, basic test suite

- [ ] Get rid of ForumPost's motd attribute <<<<
- [ ] Change Blog routes to use dates as id slugs
- [ ] Should the routes get a rework? (link helpers read different than what they actually are)
	- _trashed_archiving_document_suggestions_ instead of _archiving_document_trashed_suggestions_


- [ ] **Mobile/React Update**
	- [ ] **Is this a good idea now?**
		- Possibly way overcomplicated for a Rails app... who cares!
	- [ ] Webpacker
		- [ ] install react
		- [ ] react-rails
	- [ ] copy all routes under subdomain
	- [ ] Add json responses (templates?) for all controllers
	- [ ] Create mobile-friendly standalone single page app under special subdomain


- **Flash messages are inconsistent**
- **And filters could use a tidying up too.**

- **Some where around these two, add integration tests**
	- [ ] Login session changes
- Also give the controller tests a second pass for all the redirects (and flash messages if possible)


- [ ] **Vue Update**
	- *Adds Webpacker and a json interface for each action in the entire app.*
		- This could make or break the possibility of a SPA being included alongside the core app, or at least add the option for external interfaces to use this as an API.
	- [ ] Add full Suite of CRUD+ actions for each controller (give or take)
		- with support for hot-loading fragments using vue (drop downs)
		- This should be a feature to reduce load on database, not 'modularize'
	- [x] Webpacker
		- [x] Vue Configuration
	- [ ] **modularize header extensions** ( or maybe refactor them altogether for html snippets? )
	- [ ] Navigation Bar
		- [ ] Add dropdowns to all sections (?)
	- [ ] Trash Can
		- Subrecords like Documents and Comments can have something like a trashcan tab with number of trashed records inside
	- [ ] Add User Trashed tab support (?)
	- [ ] Things like sessions should be auto-created unless a hover (or first click) dropdown for advanced editing is clicked


- [ ] **Suggests Update V2**
	- **COME BACK TO THIS UPDATE AFTER FINISHING SHOW/HIDE**
	- [ ] Display (don't update) suggestions to not include diff when their stored changes match current version
		- Also display a notice explaining the unapparent changes
	- [ ] Create suggestions option for new documents [and archivings]
	- [ ] Change suggestions [and other posts] to show recently active first
	- [ ] **What should be done about old (no longer relevant) suggestions after one is merged?**
	- [ ] Should merging favor trashed state after all? -- NO
		- Require restoring from trashcan to merge? -- YES
	- [ ] CANNED?: Get Documents into version views (if possible)
		- This may be more of a hassle, and potential db overload than it's worth -- LIKELY
	- [ ] Versions
		- Should be trashable? ( as intermediate between deletion? ) (Yes)
		- [ ] Show
			- [ ] Togglable diff
		- [ ] Index
			- [ ] Highlight current version (necessary?)
		- [ ] Restore
			- Also, keep other versions if possible (restore creates new version?)
			- This is where the above simple highlight change will be important,
				depending on how versions get ordered
		- [ ] Diff
			- Shows changes between any two versions


- [ ] **Forums Update**
	- [ ] Change suggestions [and other posts] to show recently active first
	- [ ] Add markup support to all content
		- [ ] ...with preview tab
	- [ ] Add Multiple Attachment support


- [ ] **6.1 Release:**
	- [ ] Replace multi-bucket hack with ActiveStorage native support
		- [ ] Avatar persistence + navbar
	- [ ] Documents -- uploads
	- [ ] Users -- avatars
	- Remove initializer
	- Remove ApplicationController method


- [ ] **AnythingIsPossible Gem**
	- [ ] **Break every similar loop into a helper call with contextual parameters (name: '...', modifiers: {...}, numbers: [...], etc)**
		- Reduces all loading and iterating to one recursive method using nested hashes?
		- [ ] Implement this as api for AnythingIsPossible gem
		- [ ] Change modifier and number mapping to check for invalid keys
		- [x] Loading fixtures
		- [x] Iterating fixtures
			- [ ] Add verbose mode option for easier test confirmation and debugging
			- [ ] Add custom failsafe try-rescue block for unloaded fixtures
			- [ ] Move guest_users to be included in guest-compatable user hashes
	- [ ] **Reduce all redundant testing to relevent security implementations**
		- Would like to think more on this one, and how much overhead will be available
	- [ ] DRY out all the repetetive, iterative code that can be abstracted into recursive methods in the fixture helpers
	- [ ] **Change all hash modifiers to default to nil, even when not explicitly included in given argument hash**


- Extra Things:

	- [ ] Create a temporary history extending routing link chain? (think Ubuntu)

	- [ ] **ON VISUAL REDESIGN,** add some kind of eye catching animation (subtle, still) to
		encourage discovery and use of routing link chain

	- [ ] **Add a concern for documentable models**

	- [ ] Should MOTDs expire at the end of their day?

	- [ ] Add catches (or conditionals) to each controller action for missing records (potential error 500 -- where is this happening?)

	- [ ] Marking activity is triggered even when not authorized (and activity has not happened)

	- [ ] Change trashed user redirects on actions such as new & edit to allow, and display a warning flash message instead

	- [ ] Refactor timestamps partial to better reflect use of passed arguments

	- [ ] Add User last_active checks to all controller tests

	- [ ] Set up partial inheritance with versions

	- [ ] Move new comments into partial calls

	- [ ] Scope document thumbnails to non-trashed

	- [ ] Put redundant model code into concerns
		- Posts' titles and content

	- [ ] Add sample files to fixtures

	- Reduce session and cookie clutter
		- [ ] Change user_id session to session_token
		- [ ] Change user_id and remember_token cookies to remember_token (?)

	- [ ] Mirror upload database (GCP?)

	- [ ] Add pagination; lists are getting long

	- [ ] Add Guest-Mode option to layout

	- [ ] Change redirects in before_filters

	- [ ] Fix Session Testing (remembered check)

	- [ ] Add document seeds

	- [ ] **Set seeded admin to require password change on first visit**

	- [ ] Clean up routes with _routing concerns_

	- [ ] Implement **FriendlyId**

	- [ ] **Bundle clean --force**

	- [ ] Add in-view error handling (missing attachments, etc)
		- [ ] Extend missing attachements icon to failed s3 requests

	- [ ] Minimize server load by combining/joining database queries

	- [ ] Blog tags/sections?

	- [ ] Go through and translate all tabs to spaces

	- **NOTES:**
		- Test Env has _cookies_with_metadata_ disabled


## Nav Bar
- [x] **TESTS**
	- [ ] Integration - 00:00:02

- [x] **Home Pages**
- [x] **Blog**
- [x] **Archive**
- [x] **Forum**
- [x] **Users**
- [ ] **Account Functions**
	- [ ] Convert into dropdown with 'LED-style' status dot for login / remembering


## Home Pages
- [x] **TESTS**
	- [ ] Controller - 00:00:01

- [x] **Landing page**
	- [x] Redirect
	- [x] Content
- [ ] **Dashboard**
	- [x] Content
	- [ ] Graphic
	- [ ] ???
- [x] **About**
	- [x] Description
- [ ] **Road Map**
	- [ ] Plan
	- [ ] Graphic?


## Users
- **has_many Sessions**
- **has_many Suggestions**
- **has_many Forum Posts**
- **has_many Comments**

- [ ] **TESTS**
	- [x] Model - 00:01:07
		- [ ] Improve email regex tests
	- [x] Controller - 00:00:03

- [x] Confirm on destructive actions
- [ ] Add _Email Confirmations_
	- [ ] Add 'Activated' column to table in database
- [ ] Add _MFA Multi-Factor Authentication_

- [x] **index**
- [x] **show**
- [x] **new**
- [x] **create**
- [x] **edit**
- [x] **update**
- [x] **trashed**
- [x] **trash**
- [x] **destroy**


## Sessions
- **belongs_to Users**

- [ ] **TESTS**
	- [x] Model - 00:00:03
		- [ ] Add Token & Digest support
	- [ ] Controller - 00:00:08
		- [ ] Add helper tests (auto-logs, etc?)

- [x] **index**
- [x] **show**
- [x] **new_login**
- [x] **login**
- [x] **logout**
- [x] **new**
- [x] **create**
- [x] **edit**
- [x] **update**
- [x] **destroy**


## Blog_Posts
- **has_many Documents**
- **has_many Comments**

- [x] **TESTS**
	- [x] Model - 00:00:24
	- [x] Controller - 00:00:39

- [x] Confirm on destructive actions

- [x] **index**
- [x] **show**
- [x] **new**
- [x] **create**
- [x] **edit**
- [x] **update**
- [x] **trashed**
- [x] **trash**
- [x] **destroy**
	- [ ] VERY EXPLICIT CONFIRM


## Archivings
- **has_many Documents**
- **has_many Suggestions**

- [x] **TESTS**
	- [x] Model - 00:00:06
	- [x] Controller - 00:00:02

- [x] Confirm on destructive actions
- [ ] Filter non-admins to suggestions on _**database**_ actions

- [x] **index**
- [x] **show**
- [x] **new**
- [x] **create**
- [x] **edit**
- [x] **update**
- [x] **trashed**
- [x] **trash**
- [x] **destroy**
	- [ ] VERY EXPLICIT CONFIRM


## Documents
- **belongs_to Article (Archiving or Blog Post)**
- **has_many Suggestions**

- [ ] **TESTS**
	- [x] Model - 00:00:39
		- [ ] Test for attachment presence (Unsupported, see below)
		- [ ] Test for attachment dependent purge (and replacement)
	- [x] Controller - 00:00:14

- [ ] Confirm on destructive actions
- [ ] Filter non-admins to suggestions on _**database**_ actions
- [ ] Add create capabilities on Article create
- [ ] _Find a better solution for server-side raw, hierarchic storage (S3 soon won't support, ActiveStorage will never support)_
- Attachments are needed for fixtures, currently unsupported
- ActiveStorage [and soon S3] doesn't support file hierarchies

- [x] **show**
- [x] **new**
- [x] **create**
- [x] **edit**
- [x] **update**
- [x] **upload**
- [x] **trashed**
- [x] **trash**
- [x] **destroy**
	- [ ] VERY EXPLICIT CONFIRM


## Suggestion
- **belongs_to User (optional)**
- **belongs_to Citation (Archiving or Document)**

- [x] **TESTS**
	- [x] Model - 00:02:17
	- [z] Controller - 00:04:11

- [ ] Confirm on destructive actions
- [ ] Add create capabilities on Article create
- Attachments are needed for fixtures, currently unsupported

- [x] **index**
- [x] **show**
- [x] **new**
- [x] **create**
- [x] **edit**
- [x] **update**
- [ ] **upload**
- [x] **trashed**
- [x] **trash**
- [x] **destroy**
	- [ ] VERY EXPLICIT CONFIRM


## Versions (PaperTrail)
- [x] **TESTS**	
	- [ ] Controller - 00:00:05


## Forum_Posts
- **belongs_to User (deletable)**
- **has_many Comments**

- [x] **TESTS**
	- [x] Model - 00:00:30
	- [x] Controller - 00:01:35

- [x] Confirm on destructive actions

- [x] **index**
- [x] **show**
- [x] **new**
- [x] **create**
- [x] **edit**
- [x] **update**
- [x] **trashed**
- [x] **trash**
- [x] **destroy**
	- [ ] VERY EXPLICIT CONFIRM


## Comments
- **belongs_to User (optional)**

- [x] **TESTS**
	- [x] Model - 00:03:34
	- [ ] Controller - 00:02:25

- [x] Confirm on destructive actions
- [ ] Add layouts for comment renders in user show

- [x] **create**
- [x] **update**
- [x] **destroy**


### Errors
- [x] **TESTS**
	- [ ] Controller - 00:00:01
