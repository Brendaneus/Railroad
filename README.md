# PLAN


## **PHASE ONE:** Create Architecture

- **URGENT BLOCKERS**
	- [ ] Change landing to use session by default to prevent accidental blocking of website
	
	- [ ] Guest users have been noticed seeing an extremely painful experience loading the site [because of constant current_user full checks (fix with use of instance variable?)]
		- Later, after restarting the server and cleaning some tests, the issue has seemingly cleared up.  The giveaway was a lack of `CACHE User Load` spam in the logs
	
	- [ ] Master key has to be set every time the environment is reset.
		Should this get a more permanent fix?


- [ ] **Clean up tests** - **TOTAL TIME:** 00:04:15

	- [ ] https://github.com/paper-trail-gem/paper_trail#7-testing
	- [ ] **Reduce all redundant testing to relevent security implementations**
		- Would like to think more on this one, and how much overhead will be available
	- [ ] **Reduce all loading and iterating to one recursive method using nested hashes**
	- [ ] **Add helper tests (auto-logs, etc?)**
	- [ ] **Add integration testing using Capybara**
		- And migrate all unnecessary assert_selectors from controller tests
	- [ ] Small gripe: the trashed modifier switches after other modifiers can this be patched up for verbose test reads?
	- [ ] Change all blog_modifiers and forum_numbers, etc to use '_post_' (blog_post_modifiers)
	- [ ] Also, could the guests be included in loops and loads before all other users?
	- [ ] Even easier, change titles, contents, and names to use spacers in between all the keys
	- [ ] Guardfile
		- [x] Link controllers to controller tests
		- [x] Link models to model tests
		- [ ] Link views and controllers to integration tests
			- [ ] Add integration tests
	- [ ] Helper methods
		- [ ] Repetetive checks on controller tests (?)
			- User groups testing routes?
		- [x] Loading fixtures
		- [x] Iterating fixtures
			- [ ] Add verbose mode option for easier test confirmation and debugging
			- [ ] Add custom rescue for unloaded fixtures
			- [ ] Move guest_users to be included in guest-compatable user hashes
		- [ ] **Break every similar loop into a helper call with contextual parameters (name: '...', modifiers: {...}, numbers: [...], etc)**
			- This will make bug tracking and code maintanence _a lot_ simpler.
			- [ ] Change modifier and number mapping to check for invalid keys
				- This could be a function for code reuse
	- [ ] Test Definition
		- [ ] Add complete definition for important content in views (ie headers, form inputs)
			- Do this after Vue update
		- [ ] Add error messages for each assertion, if possible
		- [ ] Test for filter-specific redirects
		- [ ] Test for header link chain changes
		- [ ] Test for marking activity
		- [ ] Add flash clears and assert_not undesired flashes
		- [ ] Test for proper formatting of all model partial renders
			- [ ] Doctypes
	- [ ] **FIXTURES**
		- [ ] **IMPORTANT** DRY out all the repetetive, recursable iterative code in the fixture helpers
			- [ ] Change modifiers to default to nil, even when not explicitly included in given argument hash
	- [ ] Notice the _dependent destroy_ tests only test destruction of expected dependencies, not all possible [unexpected] destructions
	- [ ] Are you clearing flashes?
	- [ ] Are you building/using browser cookies/session?
	- [ ] Are you testing for forms?
	- [ ] Testing groups?

	- [ ] **Speed up all tests**
		- [x] _Quick fix?_ Reduce instances to one of each possible unique combination for speed boost
		- [x] Split up fixture loading to relevant test files?
		- [x] Parallelize tests
		- [ ] *Cut down on controller association testing, like comments, documents*
			- Most of these could not possibly show up from a one-off error, and would show up in other tests anyway 


- [x] **Users (& Sessions) Update**
	- CANNED: Video Preview
	- [ ] DELAYED: NavBar User Icon
	- [ ] DELAYED: In-view bucket-switching
	- [ ] **Future Update:**
		- [ ] Add custom crop editing (javascript?)


- [x] **Show/Hide Update**
	- *Update redesigning trashed state to function as soft delete (out of the way)
		and introducing show/hide feature for making discrete edits, etc*

	- **Trash Can**
		- Trashed Records are effectively in stasis awaiting destruction
		- Trashed Users can't make any changes and are effectively inactive accounts.
		- Users become 'deleted' on record

	- **Hidden Mode (when current user is hidden)**
		- Like incognito mode?
			- Allows making changes discretely, but not posting
			- Users become 'hidden user' on records

	- [x] Models
		- [x] Archivings
		- [x] Blog Posts
		- [x] Forum Posts
		- [x] Documents
		- [x] Suggestions
		- [x] Comments
		- [x] Users
	- [x] Controllers
		- [x] Archivings
		- [x] Blog Posts
		- [x] Forum Posts
		- [x] Documents
		- [x] Suggestions
		- [x] Versions
		- [x] Comments
		- [x] Users
		- [x] Sessions

	- [ ] Features -- Add these in the next two updates
		- [ ] Trash/Hide All Action for Users (or admins)
			- Think relative to all comments, or all forum posts
		- [ ] Page(s) showing all records and their dependency's trashed state
			- For editing (trashed/hidden) with trashed parent records
			- IE: Blog Post and Comments, Archiving and Suggestion
		- [ ] Trashed and Hidden 'placeholder' screens(?)
			- Trashed: image of a trash can
			- Hidden: incognito-esque icon

	- [ ] System
		- RECOMMEND ADDING A HIDDEN-STATE EQUIVALENT OF #TRASH_CANNED CONCERN METHOD
		- The new 'hidden' modifier kills the tests: now over 25000 fixtures on comments

	- [ ] Code Reuse(???)

- [ ] **Gut the tests, extract to a reusable gem, and test by filters / aspect**

- [ ] **Mobile/React Update**
	- [ ] **Is this a good idea now?**
		- Possibly way overcomplicated for a Rails app

	- [ ] Webpacker
		- [ ] install react
		- [ ] react-rails
	- [ ] copy all routes under subdomain
	- [ ] Add json responses (templates?) for all controllers
	- [ ] Create mobile-friendly standalone single page app under special subdomain

- **Flash messages are inconsistent**
- **And filters could use a tidying up too.**

- **Some where between these two, add integration tests (supporting javascript) and move all non-filter (accessibility) controller test code into them**

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
	- [ ] **What should be done about old (no longer relevant) suggestions after one is merged?**
	- [ ] Should merging favor trashed state after all? -- NO
		- Require restoring from trashcan to merge? -- YES
	- [ ] Get Documents into views (if possible)
		- This may be more of a hassle, and potential db overload than it's worth -- LIKELY
	- [ ] Versions
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


- Extra Things:

	- [ ] **ON VISUAL REDESIGN,** add some kind of eye catching animation (subtle, still) to
		encourage discovery and use of routing link chain

	- [ ] **Add a concern for documentable models**

	- [ ] Should MOTDs expire within a day?

	- [ ] Add catches (or conditionals) to each controller action for missing records (potential error 500)

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

	- [ ] Add pagination

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
