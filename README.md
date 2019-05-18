# PLAN

## **PHASE ONE:** Create Architecture

- [ ] **6.0 Release:**  Move old upload purging for document updates and deletes to callback stack

- [ ] Fix Session Testing

- [ ] Move all Object html to object partials

- [ ] Move all error partials to shared directory

- [ ] Clean up Comments forms with :model_name params

- [ ] Clean up routes with _routing concerns_

- [ ] Add in-view error handling (missing attachments, etc)

- [ ] Minimize server load by reducing database queries

- [ ] Implement **FriendlyId**

- [ ] **Set seeded admin to require password change on first visit**

- Models need fixed testing with `assert_changes` method in Users controller, Blog_Posts controller, Users model

- [ ] Add markup support
	- [ ] Or at least newline
	- [ ] ...with preview tab

- [x] Add smart redirects from unknown paths
	- [ ] ...and domains?

- [ ] Add custom error pages

- [ ] Create RememberTokens table in database
	- Includes user_id, remember_token, and session_name
	- [ ] Add Remembered Sessions routes

- [ ] Add a 'Trash Can' archive for all deleted posts, comments, accounts (?), instead of just destroying the database entry ( just add an attribute )

- [ ] **Bundle clean --force**

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
- [ ] **Landing page**
	- [x] Redirect
	- [ ] Content
- [ ] **Dashboard**
	- [ ] Graphic
	- [ ] ???
- [x] **About**
	- [x] Description
	- [ ] Styling
- [ ] **Road Map**
	- [ ] Plan
	- [ ] Graphic?

## Users
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
- [ ] **TESTS**
	- [x] Model
	- [x] Controller
	- [ ] Integration
- [x] Document support
- [ ] Add timestamps to page display
- [x] Confirm on destructive actions

- [ ] Share upload partial with documents

- [ ] Fix the post control link sizing

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
- [ ] **TESTS**
	- [x] Model
	- [x] Controller
	- [ ] Integration
- [x] Document support
- [ ] Filter non-admins to proposals on _**database**_ actions
- [x] Confirm on destructive actions

- [ ] Share upload partial with documents

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
- [ ] **TESTS**
	- [x] Model
	- [x] Controller
	- [ ] Integration
- [x] Confirm on destructive actions

- [ ] Fix formatting

- [x] **create**
- [x] **update**
- [x] **destroy**

### Errors
- [ ] **TESTS**
	- [x] Controller
	- [ ] Integration