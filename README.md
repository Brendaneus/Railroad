# PLAN

## **PHASE ONE:** Create Architecture


- [x] **Trash Can Update**
	- [ ] Trash All Action for Users (???)

- [ ] **Users Update**
	- [ ] Create RememberTokens table in database
	- Includes user_id, remember_token, and session_name
		- [ ] Controller
		- [ ] Views
			- [ ] Document previews
				- [ ] Video Preview
				- [x] Dashboard
				- [x] Archivings
				- [x] BlogPosts
			- [ ] Users
				- [x] Index
					- [x] Avatar
				- [ ] Show
					- [x] Avatar
					- [x] Bio
					- [ ] Sessions
	- NOT POSSIBLE: In-view bucket-switching
	- CANNED: NavBar User Icon
	- [ ] **Future Update:**
		- [ ] Add custom crop editing

- [ ] Add sample files to fixtures

- [ ] Mirror upload database

- [ ] **Suggests Update**

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

- [ ] **6.0 Release:**  Move old upload purging to _callback stack_(???) for document updates and deletes
	- [ ] **6.1 Release:**
		- [ ] Replace multi-bucket hack with ActiveStorage native support
			- [ ] Avatar persistence + navbar
		- [ ] Documents -- uploads
		- [ ] Users -- avatars
		- Remove initializer
		- Remove ApplicationController method

- [ ] Clean up tests
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

- Minimize server load by reducing database queries


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
	- [ ] Integration

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
- **has_many Forum Posts**
- **has_many Comments**

- [ ] **TESTS**
	- [x] Model
		- [ ] Improve email regex tests
	- [x] Controller
	- [ ] Integration
- [ ] Add Avatars
- [ ] Add multiple sessions support
	- [ ] Create and link to RememberTokens table in database
	- [ ] Add _'Logged in Sessions'_ control view
- [ ] Add _Email Confirmations_
	- [ ] Add 'Activated' column to table in database
- [ ] Add _MFA Multi-Factor Authentication_
- [x] Confirm on destructive actions

- [ ] Add bio, avatar, etc

- [x] **index**
- [x] **show**
- [x] **new**
- [x] **create**
- [x] **edit**
- [x] **update**
- [x] **destroy**
	- [ ] VERY EXPLICIT CONFIRM
	- [ ] MFA / EMAIL CONFIRM

## Blog
- **has_many Documents**
- **has_many Comments**

- [ ] **TESTS**
	- [x] Model
	- [x] Controller
	- [ ] Integration
- [x] Document support
- [x] Confirm on destructive actions

- [ ] **motd**
- [x] **index**
- [x] **show**
	- [x] Comments
- [x] **new**
- [x] **create**
- [x] **edit**
	- [ ] Document support
- [x] **update**
- [x] **destroy**
	- [ ] VERY EXPLICIT CONFIRM
	- [ ] MFA / EMAIL CONFIRM

## Archive
- **has_many Documents**

- [ ] **TESTS**
	- [x] Model
	- [x] Controller
	- [ ] Integration
- [x] Document support
- [ ] Filter non-admins to proposals on _**database**_ actions
- [x] Confirm on destructive actions

- [x] **index**
- [x] **show**
- [x] **new**
- [ ] **new_proposal**
- [x] **create**
- [ ] **create_proposal**
- [x] **edit**
- [ ] **edit_proposal**
- [x] **update**
- [x] **destroy**
	- [ ] VERY EXPLICIT CONFIRM
	- [ ] MFA / EMAIL CONFIRM
- [ ] **destroy_proposal**

## Document
- **belongs_to Article (Archiving or Blog Post)**

- [ ] **TESTS**
	- [x] Model
		- [ ] Test for attachment presence (Unsupported, see below)
		- [ ] Test for attachment dependent purge (and replacement)
	- [x] Controller
		- [ ] Implement friendly_id support for local_id / other
			- ActiveStorage [and soon S3] doesn't support file hierarchies
	- [ ] Integration
- [ ] Filter non-admins to proposals on _**database**_ actions
- [ ] Confirm on destructive actions

- Attachments are needed for fixtures, currently unsupported

- [ ] Add create capabilities on Article create

- [ ] _Find a better solution for server-side raw, hierarchic storage (S3 soon won't support, ActiveStorage will never support)_

- [x] **show**
- [x] **new**
- [ ] **new_proposal**
- [x] **create**
- [ ] **create_proposal**
- [x] **edit**
- [ ] **edit_proposal**
- [x] **update**
- [x] **upload**
- [x] **destroy**
	- [ ] VERY EXPLICIT CONFIRM
	- [ ] MFA / EMAIL CONFIRM
- [ ] **destroy_proposal**

## Forum
- **belongs_to User (deletable)**
- **has_many Comments**

- [ ] **TESTS**
	- [x] Model
	- [x] Controller
	- [ ] Integration
- [x] Confirm on destructive actions

- [x] **index**
- [x] **show**
- [x] **new**
- [x] **create**
- [x] **edit**
- [x] **update**
- [x] **destroy**
	- [ ] VERY EXPLICIT CONFIRM

## Comments
- **belongs_to User (optional)**

- [ ] **TESTS**
	- [x] Model
	- [x] Controller
	- [ ] Integration
- [x] Confirm on destructive actions

- [ ] Add layouts for comment renders in user show

- [x] **create**
- [x] **update**
- [x] **destroy**

### Errors
- [ ] **TESTS**
	- [x] Controller
	- [ ] Integration