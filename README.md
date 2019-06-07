# PLAN

## **PHASE ONE:** Create Architecture


- [x] **Trash Can Update**
	- [ ] Trash All Action for Users (???)

- [x] **Users (& Sessions) Update**
	- CANNED: Video Preview
	- [ ] DELAYED: NavBar User Icon
	- [ ] DELAYED: In-view bucket-switching
	- [ ] **Future Update:**
		- [ ] Add custom crop editing
	- [ ] **Add helper tests (auto-logs, etc?)**

- [ ] **Suggests Update**
	- [ ] Archives
		- [ ] Show
	- [ ] Documents
		- [ ] Show
	- [ ] Suggestions
		- [ ] Controller
			- [ ] Index
			- [ ] Trashed
			- [ ] Show
			- [ ] New
			- [ ] Create
			- [ ] Edit
			- [ ] Update
			- [ ] Trash
			- [ ] Untrash
			- [ ] Destroy
		- [ ] Views
			- [ ] Index
			- [ ] Trashed
			- [ ] Show
				- [ ] Highlight and replace sections
					- **Needs a special format???**
			- [ ] New
			- [ ] Edit

- [ ] Put redundant model code into concerns
	- Posts' titles and content

- [ ] Add sample files to fixtures

- Reduce session and cookie clutter
	- [ ] Change user_id session to session_token
	- [ ] Change user_id and remember_token cookies to remember_token

- [ ] Mirror upload database

- [ ] **Tabs Update**
	- [ ] Add dropdowns to all sections
	- [ ] Add User Trashed tab support
	- [ ] Add Comment and Document Indexes and Trashed Tabs

- [ ] **Forums Update**
	- [ ] Add markup support to all content
		- [ ] ...with preview tab
	- [ ] Add Multiple Attachment support

- [ ] Change redirects in before_filters

- [ ] Add Guest-Mode option to layout

- [ ] Add pagination

- [ ] **6.1 Release:**
	- [ ] Replace multi-bucket hack with ActiveStorage native support
		- [ ] Avatar persistence + navbar
	- [ ] Documents -- uploads
	- [ ] Users -- avatars
	- Remove initializer
	- Remove ApplicationController method

- [ ] Clean up tests
	- [ ] **FIX THE DAMN COMMENTS CONTROLLER TESTS**
	- [ ] Speed up all tests
		- Testing groups?
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
		- [ ] **Break every similar loop into a helper call with contextual parameters (name: '...', modifiers: {...}, numbers: [...], etc)**
			- This will make bug tracking and code maintanence _a lot_ simpler.
	- [ ] Test Definition
		- [ ] Add error messages for each assertion, if possible
		- [ ] Test for filter-specific redirects
		- [ ] Add flash clears and assert_not undesired flashes
		- [ ] Test for proper formatting of all model partial renders
			- [ ] Doctypes
	- [ ] **FIXTURES**
		- [ ] **Use this to test loading, iterating, and referencial integrity of fixtures, instead of relying on model tests**
		- eg.- _forum_posts['user_one'].each { |post| post.user == users['user_one'] }_
	- [ ] Archivings
		- [ ] Model - 00:00:02
			- [ ] DRY/Speed-Up/Clean in a second pass
		- [ ] Controller - 00:00:04
			- [ ] DRY/Speed-Up/Clean in a second pass
	- [ ] BlogPosts
		- [ ] Model - 00:00:03
			- [ ] DRY/Speed-Up/Clean in a second pass
		- [ ] Controller - 00:00:16
			- [ ] DRY/Speed-Up/Clean in a second pass
	- [ ] ForumPosts
		- [ ] Model - 00:00:10
			- [ ] DRY/Speed-Up/Clean in a second pass
		- [ ] Controller - 00:01:04
			- [ ] DRY/Speed-Up/Clean in a second pass
	- [ ] Documents
		- Add Attachment + content typing support
		- [ ] Model - 00:00:04
			- [ ] DRY/Speed-Up/Clean in a second pass
		- [ ] Controller - 00:00:20
			- [ ] DRY/Speed-Up/Clean in a second pass
	- [ ] Comments
		- [ ] Model - 00:00:31
			- [ ] DRY/Speed-Up/Clean in a second pass
		- [ ] Controller - 00:09:16
			- [ ] DRY/Speed-Up/Clean in a second pass
	- [ ] Users
		- [ ] Model - 00:00:14
			- [ ] DRY/Speed-Up/Clean in a second pass
		- [ ] Controller - 00:00:12
			- [ ] DRY/Speed-Up/Clean in a second pass
	- [ ] Fix Login/Logout Testing

- [ ] Fix Session Testing (remembered check)

- [ ] Add document seeds

- [ ] **Set seeded admin to require password change on first visit**

- [ ] Clean up routes with _routing concerns_

- [ ] Implement **FriendlyId**

- [ ] **Bundle clean --force**

- [ ] Add in-view error handling (missing attachments, etc)
	- [ ] Extend missing attachements icon to failed s3 requests

- Minimize server load by reducing database queries

- **NOTES:**
	- Test Env has _cookies_with_metadata_ disabled


## Nav Bar
- [x] **TESTS**
- [x] **Home Pages**
- [x] **Blog**
- [x] **Archive**
- [x] **Forum**
- [x] **Users**
- [ ] **Account Functions**
	- [ ] Convert into dropdown with 'LED-style' status dot for login / remembering


## Home Pages
- [x] **TESTS**
	- [x] Controller

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
	- [x] Model
		- [ ] Improve email regex tests
	- [x] Controller

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
	- [x] Model
		- [ ] Add Token & Digest support
	- [x] Controller
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


## Blog
- **has_many Documents**
- **has_many Comments**

- [x] **TESTS**
	- [x] Model
	- [x] Controller

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


## Archive
- **has_many Documents**
- **has_many Suggestions**

- [x] **TESTS**
	- [x] Model
	- [x] Controller

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


## Document
- **belongs_to Article (Archiving or Blog Post)**
- **has_many Suggestions**

- [ ] **TESTS**
	- [x] Model
		- [ ] Test for attachment presence (Unsupported, see below)
		- [ ] Test for attachment dependent purge (and replacement)
	- [x] Controller

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

- [ ] **TESTS**
	- [ ] Model
		- [ ] Associations
		- [ ] Title
			- [ ] Uniqueness
			- [ ] Length
		- [ ] Content
			- [ ] Length
		- [ ] Trashed
			- Default to false
	- [ ] Controller
		- [ ] Index
		- [ ] Trashed
		- [ ] Show
		- [ ] New
		- [ ] Create
		- [ ] Edit
		- [ ] Update
		- [ ] Trash
		- [ ] Untrash
		- [ ] Destroy

- [ ] Confirm on destructive actions
- [ ] Add create capabilities on Article create
- Attachments are needed for fixtures, currently unsupported

- [ ] **index**
- [ ] **show**
- [ ] **new**
- [ ] **create**
- [ ] **edit**
- [ ] **update**
- [ ] **upload**
- [ ] **trashed**
- [ ] **trash**
- [ ] **destroy**
	- [ ] VERY EXPLICIT CONFIRM


## Forum
- **belongs_to User (deletable)**
- **has_many Comments**

- [x] **TESTS**
	- [x] Model
	- [x] Controller

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
	- [x] Model
	- [x] Controller

- [x] Confirm on destructive actions
- [ ] Add layouts for comment renders in user show

- [x] **create**
- [x] **update**
- [x] **destroy**


### Errors
- [x] **TESTS**
	- [x] Controller
