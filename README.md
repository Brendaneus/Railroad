# PLAN

## **PHASE ONE:** Create Architecture

- [ ] **Set seeded admin to require password change on first visit**

- Models need fixed testing with `assert_changes` method in Users controller, Blog_Posts controller, Users model

- [x] Rename BlogPost 'body' column to 'content'
	- [ ] ...on server too
	- [ ] Add markup support
		- [ ] ...with preview tab

- [x] Add smart redirects from unknown paths 
	- [ ] ...and domains?

- [ ] Create RememberTokens table in database
	- Includes user_id, remember_token, and session_name

- [ ] Add a 'Trash Can' archive for all deleted posts, comments, accounts (?), instead of just destroying the database entry ( just add an attribute )

## Nav Bar
- [x] **TESTS**
- [x] **Home Pages**
- [x] **Blog**
- [ ] **Archive**
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
	- [ ] Description
	- [ ] Styling
- [ ] **Road Map**
	- [ ] Plan
	- [ ] Graphic?

## Users
- [ ] **TESTS**
	- [ ] Model
	- [ ] Controller
	- [ ] Integration
- [ ] Link to RememberTokens table in database
- [ ] Add _'Logged in Sessions'_ control view
- [ ] Add _Email Confirmations_
	- [ ] Add 'Activated' column to table in database
- [ ] Add _MFA Multi-Factor Authentication_
- [ ] Filter admins or authenticated on _**database**_ actions
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
	- [ ] Controller
	- [ ] Integration
- [ ] Fix the post control link sizing
- [ ] Add timestamps to page display
- [ ] Filter admins on _**database**_ actions
- [x] Confirm on destructive actions

- [ ] **motd**
- [x] **index**
- [x] **show**
	- [ ] Comments
- [x] **new**
- [x] **create**
- [x] **edit**
- [x] **update**
- [x] **destroy**clear
	- [ ] VERY EXPLICIT CONFIRM
	- [ ] MFA / EMAIL CONFIRM

## Archive
- [ ] **TESTS**
	- [ ] Model
	- [ ] Controller
	- [ ] Integration
- [ ] Set up S3 Bucket
- [ ] Filter non-admins to proposals on _**database**_ actions
- [ ] Confirm on destructive actions

- [ ] **index**
- [ ] **show**
- [ ] **new**
- [ ] **new_proposal**
- [ ] **create**
- [ ] **create_proposal**
- [ ] **edit**
- [ ] **edit_proposal**
- [ ] **update**
- [ ] **destroy**
	- [ ] VERY EXPLICIT CONFIRM
	- [ ] MFA / EMAIL CONFIRM
- [ ] **destroy_proposal**

## Forum
- [ ] **TESTS**
	- [x] Model
	- [ ] Controller
	- [ ] Integration
- [ ] Filter admins or authenticated on _**database**_ actions
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
	- [ ] Controller
	- [ ] Integration
- [ ] Filter admins or authenticated on _**destructive**_ actions
- [x] Confirm on destructive actions

- [ ] **create**
- [ ] **update**
- [ ] **destroy**