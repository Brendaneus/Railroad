# PLAN

## **PHASE ONE:** Create Architecture


- [ ] **Trash Can Update**
	- [ ] Add a 'Trash Can' archive for all deleted posts, comments, accounts (?), instead of just destroying the database entry ( just add an attribute )
	- [ ] Update views to check first for trashed state

- [ ] **Users Update**
	- [ ] Create RememberTokens table in database
	- Includes user_id, remember_token, and session_name
		- [ ] Controller
		- [ ] Views
	- [ ] Add avatars
	- [ ] Add bio section

- [ ] Add markup support to all content
	- [ ] ...with preview tab

- [ ] Add pagination

- [ ] **6.0 Release:**  Move old upload purging to _callback stack_(???) for document updates and deletes

- [ ] Clean up tests with helper methods
	- Controller tests could use helper for repetetive checks

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

- [ ] Fix the post control link sizing (???)

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